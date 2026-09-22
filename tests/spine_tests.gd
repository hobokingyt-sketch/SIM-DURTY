extends RefCounted

const WORK: SkeletonWorkDefinition = preload("res://game/content/work/skeleton_errand.tres")
const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_simulation_spine/slot.json"
var checks: int = 0
var failures: int = 0
var reentrant_error: Error = OK


func run(tree: SceneTree) -> int:
	_test_primitives()
	_test_commands()
	_test_replay()
	_test_persistence()
	await _test_ui(tree)
	_cleanup()
	print("[spine-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_primitives() -> void:
	var clock: GameClock = GameClock.new()
	_check(clock.tick() == 0 and clock.advance(15) == OK and clock.tick() == 15, "integer clock advances explicitly")
	for invalid: int in [0, -1, GameClock.MAX_TICK]:
		_check(clock.advance(invalid) != OK and clock.tick() == 15, "invalid clock step leaves time unchanged")
	for invalid: Variant in [true, -1, 0.5, "15", INF, NAN]:
		_check(clock.restore(invalid) != OK and clock.tick() == 15, "invalid restored tick rejected")
	clock.restore(GameClock.MAX_TICK - 1)
	_check(clock.advance(1) == OK and clock.advance(1) != OK, "clock exhaustion does not overflow")
	var ids: IdFactory = IdFactory.new()
	_check(ids.allocate() == "event_0000000001" and ids.allocate() == "event_0000000002", "stable sequential IDs")
	var restored_ids: IdFactory = IdFactory.new()
	restored_ids.restore(ids.next_value())
	_check(restored_ids.allocate() == ids.allocate(), "ID allocation resumes at saved cursor")
	ids.restore(IdFactory.MAX_ID)
	_check(not ids.allocate().is_empty() and ids.allocate().is_empty(), "ID exhaustion never wraps")
	_check(ids.restore(false) != OK and ids.next_value() == IdFactory.MAX_ID + 1, "invalid ID cursor leaves allocator intact")
	for valid: String in ["0", "-1", "9223372036854775807", "-9223372036854775808"]:
		_check(StateCodec.signed_integer_text(valid), "lossless signed integer text accepted")
	for invalid: Variant in ["+1", "01", "-0", " 1", "9223372036854775808", "-9223372036854775809", 12, true]:
		_check(not StateCodec.signed_integer_text(invalid), "noncanonical or overflowing RNG state rejected")
	var rng: SimulationRng = SimulationRng.new()
	var other: SimulationRng = SimulationRng.new()
	var first_values: Array[int] = []
	var same: bool = true
	for index: int in range(32):
		var number: int = rng.draw_u32()
		first_values.append(number)
		same = same and number == other.draw_u32()
	_check(same, "same seed generates identical RNG sequence")
	other.reseed(19)
	var differs: bool = false
	for index: int in range(32):
		differs = differs or other.draw_u32() != first_values[index]
	_check(differs, "different seed changes RNG sequence")
	var saved: Dictionary = rng.snapshot()
	var decoded: Variant = JSON.parse_string(JSON.stringify(saved))
	_check(other.restore(decoded) == OK and other.snapshot() == saved, "RNG state survives JSON without 64-bit precision loss")
	same = true
	for index: int in range(32):
		same = same and rng.draw_u32() == other.draw_u32()
	_check(same, "saved RNG resumes the next 32 results exactly")
	var before: Dictionary = rng.snapshot()
	for invalid: Variant in [-1, true, "17", 0.25]:
		_check(rng.reseed(invalid) != OK and rng.snapshot() == before, "invalid seed never resets a stream")
	var incompatible: Dictionary = before.duplicate(true)
	incompatible["engine"] = "another-engine"
	_check(rng.restore(incompatible) == ERR_UNAVAILABLE and rng.snapshot() == before, "engine RNG mismatch is explicit and nonmutating")
	_check(StateCodec.fingerprint({"a": 1, "b": 2}) == StateCodec.fingerprint({"b": 2, "a": 1}), "hash ignores dictionary insertion order")


func _test_commands() -> void:
	var session: SkeletonSession = SkeletonSession.new(WORK)
	var before: Dictionary = session.checkpoint()
	var bad_commands: Array[Dictionary] = [
		{}, {"sequence": 2, "type": "work", "amount": 0},
		{"sequence": 1, "type": "unknown", "amount": 0},
		{"sequence": 1, "type": "advance", "amount": -1},
		{"sequence": 1, "type": "advance", "amount": 1441},
		{"sequence": true, "type": "work", "amount": 0},
		{"sequence": 1, "type": "work", "amount": 0.0},
		{"sequence": 1, "type": "work", "amount": 0, "extra": true},
	]
	for command: Dictionary in bad_commands:
		_check(session.execute(command) != OK and session.checkpoint() == before and session.recent_events().is_empty(), "invalid command has no time, RNG, ID or event side effects")
	session.perform_work()
	before = session.checkpoint()
	_check(session.execute({"sequence": 1, "type": "work", "amount": 0}) != OK and session.checkpoint() == before, "duplicate sequence cannot pay twice")
	_check(session.advance_minutes(1) == OK and session.snapshot() == {"cash_cents": 1500, "elapsed_minutes": 16, "completed_actions": 1}, "wait command changes only authoritative time")
	var handler: Callable = func() -> void: reentrant_error = session.perform_work()
	session.changed.connect(handler)
	session.sample_random()
	session.changed.disconnect(handler)
	_check(reentrant_error == ERR_BUSY and session.next_command_sequence() == 4, "reentrant command is rejected during notification")
	var copy: Dictionary = session.spine_snapshot()
	copy["rng"]["seed"] = 999
	var events: Array[Dictionary] = session.recent_events()
	events[0]["type"] = "changed-by-view"
	_check(session.spine_snapshot()["rng"]["seed"] == SimulationRng.DEFAULT_SEED and session.recent_events()[0]["type"] == "work", "nested snapshots and journal are detached")
	before = session.checkpoint()
	for field: String in ["tick", "next_id", "next_command", "last_roll"]:
		var broken: Dictionary = before["spine"].duplicate(true)
		broken[field] = -2
		_check(session.restore(before["state"], broken) != OK and session.checkpoint() == before, "malformed spine restore is atomic")
	var wrong_rng: Dictionary = before["spine"].duplicate(true)
	wrong_rng["rng"]["state"] = "9223372036854775808"
	_check(session.restore(before["state"], wrong_rng) != OK and session.checkpoint() == before, "bad RNG cannot partially restore cash or clock")
	for index: int in range(100):
		session.advance_minutes(1)
	_check(session.recent_events().size() == SkeletonSession.EVENT_LIMIT, "diagnostic journal remains bounded")


func _test_replay() -> void:
	var first: SkeletonSession = SkeletonSession.new(WORK)
	var second: SkeletonSession = SkeletonSession.new(WORK)
	var resumed: SkeletonSession = SkeletonSession.new(WORK)
	var commands: Array[Dictionary] = []
	for index: int in range(1000):
		var kind: String = ["work", "advance", "rng_probe"][index % 3]
		commands.append({"sequence": index + 1, "type": kind, "amount": 1 if kind == "advance" else 0})
	var all_ok: bool = true
	for index: int in range(commands.size()):
		all_ok = first.execute(commands[index]) == OK and all_ok
		if index == 499:
			var encoded: String = JSON.stringify(SkeletonSave.envelope(first.snapshot(), first.spine_snapshot()))
			var save: Dictionary = SkeletonSave.decode(encoded)
			all_ok = int(save["error"]) == OK and resumed.restore(save["state"], save["spine"]) == OK and all_ok
		elif index > 499:
			all_ok = resumed.execute(commands[index]) == OK and all_ok
	for command: Dictionary in commands:
		all_ok = second.execute(command) == OK and all_ok
	_check(all_ok, "1000 mixed ordered commands accepted")
	_check(first.state_hash() == second.state_hash() and first.recent_events() == second.recent_events(), "full replay preserves hash and event ordering")
	_check(first.state_hash() == resumed.state_hash() and first.recent_events() == resumed.recent_events(), "mid-replay save resumes RNG, IDs, clock and command order")
	print("[spine-tests] replay_hash=%s" % first.state_hash())
	first.reset()
	second.reset()
	_check(first.state_hash() == second.state_hash() and first.spine_snapshot()["rng"]["draws"] == 0, "reset restarts same seeded timeline")
	var grouped: SkeletonSession = SkeletonSession.new(WORK)
	first.advance_minutes(15)
	for index: int in range(15):
		grouped.advance_minutes(1)
	_check(first.snapshot() == grouped.snapshot(), "clock result independent of explicit step grouping")
	_check(first.state_hash() != grouped.state_hash(), "different command histories retain distinct identity")


func _test_persistence() -> void:
	_cleanup()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SLOT.get_base_dir()))
	var old_text: String = FileAccess.get_file_as_string("res://tests/fixtures/saves/skeleton_v1.json")
	var file: FileAccess = FileAccess.open(SLOT, FileAccess.WRITE)
	file.store_string(old_text)
	file.close()
	var store: SkeletonSave = SkeletonSave.new(SLOT)
	var migrated: Dictionary = store.read_state()
	_check(migrated["error"] == OK and migrated["source_schema"] == 1 and FileAccess.get_file_as_string(SLOT) == old_text, "v1 migration reads without rewriting original")
	var session: SkeletonSession = SkeletonSession.new(WORK)
	_check(session.restore(migrated["state"], migrated["spine"]) == OK and session.spine_snapshot()["tick"] == 45 and session.spine_snapshot()["rng"]["draws"] == 0, "v1 retains time and initializes an unused documented seed")
	_check(session.recent_events().is_empty(), "v1 migration invents no historical events")
	session.sample_random()
	session.advance_minutes(1)
	_check(store.write_state(session.snapshot(), session.spine_snapshot()) == OK and FileAccess.get_file_as_string(SLOT + ".bak") == old_text, "first v2 save preserves original v1 bytes as backup")
	var loaded: Dictionary = store.read_state()
	var resumed: SkeletonSession = SkeletonSession.new(WORK)
	resumed.restore(loaded["state"], loaded["spine"])
	_check(loaded["source_schema"] == 2 and session.state_hash() == resumed.state_hash(), "disk v2 restores full authoritative fingerprint")
	session.sample_random()
	resumed.sample_random()
	_check(session.state_hash() == resumed.state_hash(), "disk resume preserves next random draw and event ID")
	var valid_bytes: String = FileAccess.get_file_as_string(SLOT)
	var corrupt: Dictionary = session.spine_snapshot()
	corrupt["tick"] = -1
	_check(store.write_state(session.snapshot(), corrupt) != OK and FileAccess.get_file_as_string(SLOT) == valid_bytes, "invalid spine cannot replace a good disk slot")
	var foreign: Dictionary = SkeletonSave.envelope(session.snapshot(), session.spine_snapshot())
	foreign["spine"]["rng"]["engine"] = "future-engine"
	_check(SkeletonSave.decode(JSON.stringify(foreign))["error"] == ERR_UNAVAILABLE, "incompatible saved RNG engine is not silently reseeded")
	_cleanup()


func _test_ui(tree: SceneTree) -> void:
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	app.set("auto_load", false)
	tree.root.add_child(app)
	await tree.process_frame
	var view: SkeletonView = app.get("view") as SkeletonView
	var session: SkeletonSession = app.get("session") as SkeletonSession
	view.work_button.pressed.emit()
	_check(not view.work_button.disabled, "work remains clickable after synchronous state notification")
	view.spine_panel.step_one.pressed.emit()
	_check(view.time_label.text == "Day 1 · 08:16" and view.cash_label.text == "$15.00", "step control reaches clock without adding money")
	view.spine_panel.sample_button.pressed.emit()
	_check(session.spine_snapshot()["rng"]["draws"] == 1 and view.dirty_label.text == "Unsaved session", "RNG-only change is visible and marks session dirty")
	var expected: String = session.state_hash()
	view.save_button.pressed.emit()
	view.spine_panel.sample_button.pressed.emit()
	view.load_button.pressed.emit()
	_check(session.state_hash() == expected and view.dirty_label.text == "Matches saved slot", "UI Save and Load restore the whole spine, not just displayed cash")
	_check(str(app.call("debug_report")).contains("simulation_tick: 16") and str(app.call("debug_report")).contains(expected), "debug report exposes real tick and complete state hash")
	app.queue_free()
	await tree.process_frame


func _cleanup() -> void:
	for suffix: String in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(SLOT + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(SLOT + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("[spine-tests] PASS: %s" % label)
	else:
		failures += 1
		push_error("[spine-tests] FAIL: %s" % label)
