extends RefCounted

const WORK: SkeletonWorkDefinition = preload("res://game/content/work/skeleton_errand.tres")
const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_walking_skeleton/slot_v1.json"

var failures: int = 0
var checks: int = 0
var notifications: int = 0


func run(tree: SceneTree) -> int:
	_test_session()
	_test_save()
	await _test_ui(tree)
	_cleanup()
	print("[skeleton-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_session() -> void:
	var session: SkeletonSession = SkeletonSession.new(WORK)
	session.changed.connect(func() -> void: notifications += 1)
	_check(session.snapshot()["cash_cents"] == 1000, "initial cash is integer cents")
	_check(session.perform_work() == OK, "authored activity is accepted")
	_check(session.snapshot() == {"cash_cents": 1500, "elapsed_minutes": 15, "completed_actions": 1}, "one command updates all three fields")
	_check(notifications == 1, "one successful command emits one change")
	var detached: Dictionary = session.snapshot()
	detached["cash_cents"] = 9999
	_check(session.snapshot()["cash_cents"] == 1500, "snapshot cannot mutate authority")
	var before: Dictionary = session.snapshot()
	for invalid: Variant in [-1, 0.5, true, "100", null, INF, NAN, 1000000000001]:
		var bad: Dictionary = before.duplicate()
		bad["cash_cents"] = invalid
		_check(session.restore(bad) != OK and session.snapshot() == before, "invalid amount rejected without partial mutation")
	_check(notifications == 1, "failed restores emit no state change")
	var missing: Dictionary = before.duplicate()
	missing.erase("elapsed_minutes")
	_check(session.restore(missing) != OK, "missing state field rejected")
	var extra: Dictionary = before.duplicate()
	extra["unknown"] = 1
	_check(session.restore(extra) != OK, "unrecognized state field rejected")
	var upper: Dictionary = {"cash_cents": SkeletonSession.MAX_CASH_CENTS, "elapsed_minutes": 0, "completed_actions": 0}
	_check(session.restore(upper) == OK and session.perform_work() != OK and session.snapshot() == upper, "bounds reject whole command")
	var invalid_work: SkeletonWorkDefinition = WORK.duplicate(true) as SkeletonWorkDefinition
	invalid_work.duration_minutes = 0
	_check(SkeletonSession.new(invalid_work).perform_work() != OK, "invalid authored data rejected")
	var editable: SkeletonWorkDefinition = WORK.duplicate(true) as SkeletonWorkDefinition
	var isolated: SkeletonSession = SkeletonSession.new(editable)
	editable.payout_cents = 1000000
	isolated.perform_work()
	_check(isolated.snapshot()["cash_cents"] == 1500, "session owns copied command inputs")
	var first: SkeletonSession = SkeletonSession.new(WORK)
	var second: SkeletonSession = SkeletonSession.new(WORK)
	for index: int in range(100):
		first.perform_work()
		second.perform_work()
	_check(first.snapshot() == second.snapshot(), "same ordered commands produce same state")


func _test_save() -> void:
	_cleanup()
	var store: SkeletonSave = SkeletonSave.new(SLOT)
	_check(store.read_state()["error"] == ERR_FILE_NOT_FOUND, "missing slot reported without creating one")
	var fixture: String = FileAccess.get_file_as_string("res://tests/fixtures/saves/skeleton_v1.json")
	var result: Dictionary = SkeletonSave.decode(fixture)
	_check(result["error"] == OK, "shipped schema-one fixture loads")
	var saved: Dictionary = result.get("state", {})
	if saved.is_empty():
		return
	_check(store.write_state(saved) == OK, "first disk save succeeds")
	_check(SkeletonSave.new(SLOT).read_state()["state"] == saved, "new store instance reads same disk state")
	var updated: Dictionary = saved.duplicate()
	updated["cash_cents"] = 3000
	_check(store.write_state(updated) == OK, "existing primary can be replaced on this platform")
	_check(SkeletonSave.new(SLOT).read_state()["state"] == updated, "replacement reads latest snapshot")
	_check(SkeletonSave.decode(FileAccess.get_file_as_string(SLOT + ".bak"))["state"] == saved, "previous valid save retained as backup")
	_check(not FileAccess.file_exists(SLOT + ".tmp"), "successful save leaves no staging file")
	var stable_bytes: String = FileAccess.get_file_as_string(SLOT)
	var invalid: Dictionary = updated.duplicate()
	invalid["completed_actions"] = -2
	_check(store.write_state(invalid) != OK and FileAccess.get_file_as_string(SLOT) == stable_bytes, "invalid write cannot replace primary")
	for bad_text: String in ["{", "null", "[]", fixture.replace("2500", "-1"), fixture.replace("skeleton_errand", "unknown")]:
		_check(SkeletonSave.decode(bad_text)["error"] != OK, "malformed or incompatible save rejected")
	var future: Dictionary = SkeletonSave.envelope(updated)
	future["schema_version"] = 2
	var future_text: String = JSON.stringify(future)
	_write_fixture(future_text)
	_check(store.read_state()["error"] == ERR_UNAVAILABLE, "newer schema is distinguished from corruption")
	_check(store.write_state(updated) == ERR_UNAVAILABLE and FileAccess.get_file_as_string(SLOT) == future_text, "newer save cannot be overwritten")
	_write_fixture("{broken")
	_check(store.write_state(updated) == ERR_FILE_CORRUPT and FileAccess.get_file_as_string(SLOT) == "{broken", "corrupt primary is preserved")
	_write_fixture("x".repeat(SkeletonSave.MAX_FILE_BYTES + 1))
	_check(store.read_state()["error"] == ERR_FILE_CORRUPT, "oversized file rejected")
	_cleanup()


func _test_ui(tree: SceneTree) -> void:
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	app.set("auto_load", false)
	tree.root.add_child(app)
	await tree.process_frame
	var view: SkeletonView = app.get("view") as SkeletonView
	for index: int in range(3):
		view.work_button.pressed.emit()
	_check(view.cash_label.text == "$25.00" and view.time_label.text == "Day 1 · 08:45" and view.count_label.text == "3", "UI signal reaches state and refreshes labels")
	_check(str(app.call("debug_report")).contains("cash_cents: 2500"), "debug report uses current state, not startup cache")
	view.save_button.pressed.emit()
	_check(int(app.get("last_storage_error")) == OK, "Save button writes the slot")
	view.reset_button.pressed.emit()
	_check(view.cash_label.text == "$10.00", "Reset changes only live session")
	view.load_button.pressed.emit()
	_check(view.cash_label.text == "$25.00", "Load restores the saved values")
	_check(view.dirty_label.text == "Matches saved slot", "saved-state indicator matches restored state")
	app.queue_free()
	await tree.process_frame
	app = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	tree.root.add_child(app)
	await tree.process_frame
	view = app.get("view") as SkeletonView
	_check(view.cash_label.text == "$25.00", "fresh application automatically loads existing slot")
	_write_fixture("{broken")
	view.load_button.pressed.emit()
	_check(view.cash_label.text == "$25.00" and int(app.get("last_storage_error")) == ERR_FILE_CORRUPT, "bad Load leaves live state unchanged")
	view.save_button.pressed.emit()
	_check(FileAccess.get_file_as_string(SLOT) == "{broken", "bad slot is not silently replaced via UI")
	app.queue_free()
	await tree.process_frame


func _write_fixture(text: String) -> void:
	var file: FileAccess = FileAccess.open(SLOT, FileAccess.WRITE)
	if file == null:
		_check(false, "fixture write available")
		return
	file.store_string(text)
	file.close()


func _cleanup() -> void:
	for suffix: String in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(SLOT + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(SLOT + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("[skeleton-tests] PASS: %s" % label)
	else:
		failures += 1
		push_error("[skeleton-tests] FAIL: %s" % label)
