extends RefCounted

const WORK: SkeletonWorkDefinition = preload("res://game/content/work/skeleton_errand.tres")
const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_recovery/slot.json"
const DAMAGED: String = "{damaged-save-fixture"
var failures: int = 0
var checks: int = 0


func run(tree: SceneTree) -> int:
	_test_inspection_and_recovery()
	_test_refusal_paths()
	_test_legacy_and_missing()
	await _test_ui(tree)
	_cleanup()
	print("[recovery-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_inspection_and_recovery() -> void:
	_cleanup()
	var store: SkeletonSave = SkeletonSave.new(SLOT)
	var info: Dictionary = store.inspect_slot()
	_check(info["primary"]["status"] == "missing" and info["backup"]["status"] == "missing", "empty slot is inspected without setup")
	_check(not info["can_recover"] and _files().is_empty(), "inspection creates no files")
	var pair: Dictionary = _prepare_pair()
	var before: Dictionary = _files()
	info = store.inspect_slot()
	_check(info["primary"]["status"] == "ready" and info["backup"]["schema"] == 2, "current and backup saves inspected separately")
	_check(not info["can_recover"] and _files() == before, "valid primary cannot be rolled back")
	_check(store.recover_backup("anything")["error"] != OK and _files() == before, "recovery refuses a healthy primary")
	info["backup"]["status"] = "tampered"
	_check(store.inspect_slot()["backup"]["status"] == "ready", "inspection returns detached values")
	_put(SLOT, DAMAGED)
	info = store.inspect_slot()
	_check(info["can_recover"] and not str(info["recovery_token"]).is_empty(), "damaged primary exposes a verified recovery candidate")
	before = _files()
	_check(store.write_state(pair["state"], pair["spine"]) == ERR_FILE_CORRUPT and _files() == before, "normal Save still protects corrupt files")
	_check(store.recover_backup("")["error"] == ERR_BUSY and _files() == before, "unconfirmed recovery does not write")
	var result: Dictionary = store.recover_backup(info["recovery_token"])
	_check(result["error"] == OK and result["state"] == pair["state"] and result["spine"] == pair["spine"], "recovery returns the full previous checkpoint")
	_check(FileAccess.get_file_as_string(SLOT) == pair["original"], "recovered primary is exact original bytes")
	_check(FileAccess.get_file_as_string(SLOT + ".bak") == pair["original"], "recovery does not consume or overwrite backup")
	_check(FileAccess.get_file_as_string(SLOT + ".rejected-001") == DAMAGED, "damaged original retained byte-for-byte")
	_check(result["preserved_copy"] == "slot.json.rejected-001", "recovery reports only a safe filename")
	_check(not FileAccess.file_exists(SLOT + ".recover.tmp"), "successful recovery removes staging path")
	var restored: SkeletonSession = SkeletonSession.new(WORK)
	_check(restored.restore(result["state"], result["spine"]) == OK and restored.state_hash() == pair["hash"], "restored checkpoint retains simulation identity")
	before = _files()
	_check(store.recover_backup(info["recovery_token"])["error"] != OK and _files() == before, "double recovery cannot overwrite a repaired save")


func _test_refusal_paths() -> void:
	var pair: Dictionary = _prepare_pair()
	var store: SkeletonSave = SkeletonSave.new(SLOT)
	_put(SLOT, DAMAGED)
	var token: String = str(store.inspect_slot()["recovery_token"])
	_put(SLOT + ".bak", pair["latest"])
	var before: Dictionary = _files()
	_check(store.recover_backup(token)["error"] == ERR_BUSY and _files() == before, "changed backup rejects stale recovery intent")
	_put(SLOT + ".bak", pair["original"])
	token = str(store.inspect_slot()["recovery_token"])
	_put(SLOT, "{different-damage")
	before = _files()
	_check(store.recover_backup(token)["error"] == ERR_BUSY and _files() == before, "changed primary rejects stale recovery intent")
	var future: Dictionary = SkeletonSave.envelope(pair["state"], pair["spine"])
	future["schema_version"] = 99
	_put(SLOT, JSON.stringify(future))
	before = _files()
	_check(store.inspect_slot()["primary"]["status"] == "incompatible" and not store.inspect_slot()["can_recover"], "newer schema never falls back automatically")
	_check(store.recover_backup(token)["error"] != OK and _files() == before, "future primary is protected from backup recovery")
	future = SkeletonSave.envelope(pair["state"], pair["spine"])
	future["spine"]["version"] = 99
	_put(SLOT, JSON.stringify(future))
	_check(not store.inspect_slot()["can_recover"], "incompatible spine cannot be downgraded")
	_put(SLOT, DAMAGED)
	for text: String in ["{broken-backup", JSON.stringify(future)]:
		_put(SLOT + ".bak", text)
		before = _files()
		_check(not store.inspect_slot()["can_recover"] and store.recover_backup(token)["error"] != OK and _files() == before, "invalid or incompatible backup cannot replace primary")
	_put(SLOT + ".bak", pair["original"])
	_put(SLOT, "x".repeat(SkeletonSave.MAX_FILE_BYTES + 1))
	_check(not store.inspect_slot()["can_recover"], "oversized damage is not copied or hashed without bound")
	_put(SLOT, DAMAGED)
	_put(SLOT + ".rejected-001", "older evidence")
	var result: Dictionary = store.recover_backup(store.inspect_slot()["recovery_token"])
	_check(result["error"] == OK and result["preserved_copy"] == "slot.json.rejected-002", "archive naming skips existing evidence")
	_check(FileAccess.get_file_as_string(SLOT + ".rejected-001") == "older evidence", "older rejection evidence is never overwritten")
	_put(SLOT, DAMAGED)
	for index: int in range(1, SkeletonSave.MAX_REJECTED_COPIES + 1):
		_put(SLOT + ".rejected-%03d" % index, "occupied")
	before = _files()
	result = store.recover_backup(store.inspect_slot()["recovery_token"])
	_check(result["error"] == ERR_ALREADY_EXISTS and _files() == before, "full evidence allowance fails closed without growing forever")
	var invalid: SkeletonSave = SkeletonSave.new("res://not-a-player-slot.json")
	_check(not invalid.inspect_slot()["can_recover"] and invalid.recover_backup(token)["error"] != OK, "recovery is restricted to the save namespace")


func _test_legacy_and_missing() -> void:
	var pair: Dictionary = _prepare_pair()
	var store: SkeletonSave = SkeletonSave.new(SLOT)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SLOT))
	var info: Dictionary = store.inspect_slot()
	_check(info["can_recover"] and info["primary"]["status"] == "missing", "missing primary can recover a valid backup")
	var before: Dictionary = _files()
	_check(store.write_state(pair["state"], pair["spine"]) != OK and _files() == before, "Save cannot hide a recoverable missing primary")
	var result: Dictionary = store.recover_backup(info["recovery_token"])
	_check(result["error"] == OK and FileAccess.get_file_as_string(SLOT) == pair["original"], "missing primary recovered without file browsing")
	_check(result["preserved_copy"] == "" and not FileAccess.file_exists(SLOT + ".rejected-001"), "missing original does not invent an evidence file")
	var legacy: String = FileAccess.get_file_as_string("res://tests/fixtures/saves/skeleton_v1.json")
	_put(SLOT, DAMAGED)
	_put(SLOT + ".bak", legacy)
	before = _files()
	info = store.inspect_slot()
	_check(info["backup"]["schema"] == 1 and _files() == before, "legacy backup inspection does not migrate files on disk")
	result = store.recover_backup(info["recovery_token"])
	_check(result["error"] == OK and result["source_schema"] == 1 and FileAccess.get_file_as_string(SLOT) == legacy, "legacy backup recovered without implicit rewrite")
	_check(store.write_state(result["state"], result["spine"]) == OK and FileAccess.get_file_as_string(SLOT + ".bak") == legacy, "explicit Save upgrades a recovered v1 file and preserves its bytes")


func _test_ui(tree: SceneTree) -> void:
	var pair: Dictionary = _prepare_pair()
	_put(SLOT, DAMAGED)
	var before: Dictionary = _files()
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	tree.root.add_child(app)
	await tree.process_frame
	var view: SkeletonView = app.get("view") as SkeletonView
	var session: SkeletonSession = app.get("session") as SkeletonSession
	_check(not view.developer_scroll.visible and not view.developer_toggle.button_pressed, "developer controls are hidden by default")
	_check(view.recovery_button.is_visible_in_tree() and not view.recovery_button.disabled, "startup offers one contextual recovery action")
	_check(_files() == before, "startup inspection does not modify player files")
	view.recovery_button.pressed.emit()
	_check(int(app.get("last_storage_error")) == OK and session.state_hash() == pair["hash"], "native recovery action restores the whole session")
	_check(view.cash_label.text == "$25.00" and view.dirty_label.text == "Matches saved slot", "recovery refreshes the existing interface")
	_check(not view.recovery_button.is_visible_in_tree(), "recovery action disappears after success")
	before = _files()
	var checkpoint: Dictionary = session.checkpoint()
	view.developer_toggle.button_pressed = true
	_check(view.developer_scroll.visible and session.checkpoint() == checkpoint and _files() == before, "opening the inspector cannot mutate or save the game")
	_check(view.spine_panel.storage_label.text.contains("ready") and view.spine_panel.events_label.text.contains("No events"), "inspector reads actual storage and does not invent history")
	view.work_button.pressed.emit()
	_check(view.spine_panel.events_label.text.contains("work"), "inspector shows real local commands")
	var report: String = str(app.call("debug_report"))
	_check(report.contains("backup_inspection:") and report.contains("rejected-001") and report.contains("recent_events:"), "one report includes storage, recovery and bounded event context")
	_check(not report.contains("user://") and not report.contains("recovery_token"), "reports exclude local paths and internal recovery tokens")
	view.developer_toggle.button_pressed = false
	_check(not view.developer_scroll.visible, "tools collapse without interrupting play")
	_check(_files() == before, "work and inspection still respect manual saving")
	app.queue_free()
	await tree.process_frame


func _prepare_pair() -> Dictionary:
	_cleanup()
	var session: SkeletonSession = SkeletonSession.new(WORK)
	for index: int in range(3):
		session.perform_work()
	for index: int in range(2):
		session.sample_random()
	var store: SkeletonSave = SkeletonSave.new(SLOT)
	var result: Dictionary = session.checkpoint()
	result["hash"] = session.state_hash()
	_check(store.write_state(session.snapshot(), session.spine_snapshot()) == OK, "scenario checkpoint saved")
	result["original"] = FileAccess.get_file_as_string(SLOT)
	session.perform_work()
	_check(store.write_state(session.snapshot(), session.spine_snapshot()) == OK, "scenario previous-save backup prepared")
	result["latest"] = FileAccess.get_file_as_string(SLOT)
	return result


func _put(path: String, text: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_check(false, "fixture write available")
		return
	file.store_string(text)
	file.close()


func _suffixes() -> PackedStringArray:
	var result: PackedStringArray = ["", ".bak", ".tmp", ".recover.tmp"]
	for index: int in range(1, SkeletonSave.MAX_REJECTED_COPIES + 1):
		result.append(".rejected-%03d" % index)
	return result


func _files() -> Dictionary:
	var result: Dictionary = {}
	for suffix: String in _suffixes():
		if FileAccess.file_exists(SLOT + suffix):
			result[suffix] = FileAccess.get_file_as_bytes(SLOT + suffix)
	return result


func _cleanup() -> void:
	for suffix: String in _suffixes():
		if FileAccess.file_exists(SLOT + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(SLOT + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("[recovery-tests] PASS: %s" % label)
	else:
		failures += 1
		push_error("[recovery-tests] FAIL: %s" % label)
