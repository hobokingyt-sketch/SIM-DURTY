extends Control

const WORK: SkeletonWorkDefinition = preload("res://game/content/work/skeleton_errand.tres")

@export var save_path: String = "user://walking_skeleton/slot_v1.json"
@export var auto_load: bool = true
@onready var view: SkeletonView = %SkeletonView

var session: SkeletonSession
var save_slot: SkeletonSave
var last_storage_error: Error = OK
var _saved_checkpoint: Dictionary = {}
var _storage_info: Dictionary = {}
var _recovery_note: String = "none"
var _widget_probe: RefCounted


func _ready() -> void:
	var probe_mode: String = ""
	var recovery_mode: String = ""
	var os_mode: String = ""
	var workspace_mode: String = ""
	var widget_mode: String = ""
	var app_mode: String = ""
	get_window().min_size = Vector2i(1280, 800)
	if OS.is_debug_build():
		for argument: String in OS.get_cmdline_user_args():
			if argument.begins_with("--skeleton-probe="):
				probe_mode = argument.trim_prefix("--skeleton-probe=")
			if argument.begins_with("--recovery-probe="):
				recovery_mode = argument.trim_prefix("--recovery-probe=")
			if argument.begins_with("--os-probe="):
				os_mode = argument.trim_prefix("--os-probe=")
			if argument.begins_with("--widget-probe="):
				widget_mode = argument.trim_prefix("--widget-probe=")
			if argument.begins_with("--workspace-probe="):
				workspace_mode = argument.trim_prefix("--workspace-probe=")
			if argument.begins_with("--app-probe="):
				app_mode = argument.trim_prefix("--app-probe=")
		if not probe_mode.is_empty():
			save_path = "user://_ci_walking_skeleton/probe_slot_v1.json"
			auto_load = false
		if not recovery_mode.is_empty():
			save_path = "user://_ci_recovery/probe_slot_v1.json"
			auto_load = recovery_mode == "read"
		if not os_mode.is_empty():
			save_path = "user://_ci_os_shell/slot_v1.json"
			auto_load = false
		if not workspace_mode.is_empty():
			save_path = "user://_ci_workspace/slot_v1.json"
			auto_load = workspace_mode == "read"
		if not widget_mode.is_empty():
			save_path = "user://_ci_widgets/slot.json"
			auto_load = widget_mode == "read"
		if not app_mode.is_empty():
			save_path = "user://_ci_apps/slot.json"
			auto_load = false
	session = SkeletonSession.new(WORK)
	save_slot = SkeletonSave.new(save_path)
	session.changed.connect(_refresh)
	view.work_requested.connect(_work)
	view.save_requested.connect(_save)
	view.load_requested.connect(_load)
	view.reset_requested.connect(_reset)
	view.debug_report_requested.connect(_copy_debug_report)
	view.advance_requested.connect(_advance)
	view.sample_requested.connect(_sample)
	view.inspection_requested.connect(_inspect_storage)
	view.recovery_requested.connect(_recover)
	view.configure_work(WORK)
	view.configure_workspace(save_path, not workspace_mode.is_empty() or not widget_mode.is_empty() or not app_mode.is_empty())
	view.show_build(BuildInfo.snapshot())
	_refresh()
	_inspect_storage()
	if auto_load and int(_storage_info["primary"]["error"]) != ERR_FILE_NOT_FOUND:
		_load()
	elif bool(_storage_info["can_recover"]):
		view.show_status("Saved slot is missing. A previous save is available in the right rail.", true)
	else:
		view.show_status("Save when you want to keep this session.")
	print("[SIM-DURTY] Controls 6D.3 boot OK | build=%s" % BuildInfo.build_id())
	print(debug_report())
	if not app_mode.is_empty():
		var app_probe_script: Script = load("res://game/devtools/app_probe.gd") as Script
		_widget_probe = app_probe_script.new()
		_widget_probe.call_deferred("run", self, app_mode)
	elif not widget_mode.is_empty():
		var probe_script: Script = load("res://game/devtools/widget_probe.gd") as Script
		_widget_probe = probe_script.new()
		_widget_probe.call_deferred("run", self, widget_mode)
	elif not workspace_mode.is_empty():
		var probe: Script = load("res://game/devtools/workspace_probe.gd") as Script
		probe.call_deferred("run", self, workspace_mode)
	elif not os_mode.is_empty():
		var probe: Script = load("res://game/devtools/os_shell_probe.gd") as Script
		probe.call_deferred("run", self, os_mode)
	elif not recovery_mode.is_empty():
		var probe: Script = load("res://game/devtools/recovery_probe.gd") as Script
		probe.call_deferred("run", self, recovery_mode)
	elif not probe_mode.is_empty():
		var probe: Script = load("res://game/devtools/skeleton_probe.gd") as Script
		probe.call_deferred("run", self, probe_mode)


func _work() -> void:
	var error: Error = session.perform_work()
	view.show_status("Errand complete. +%s; %d minutes passed." % [SkeletonView.money_text(WORK.payout_cents), WORK.duration_minutes] \
		if error == OK else "This test session has reached its supported limit.", error != OK)


func _advance(minutes: int) -> void:
	var error: Error = session.advance_minutes(minutes)
	view.show_status("Advanced %d minutes. Cash and completed work are unchanged." % minutes \
		if error == OK else "That clock step was rejected.", error != OK)


func _sample() -> void:
	var error: Error = session.sample_random()
	view.show_status("Test draw updated. Save and Load preserve its continuation." \
		if error == OK else "Random test rejected at this session's limit.", error != OK)


func _inspect_storage() -> void:
	_storage_info = save_slot.inspect_slot()
	view.show_storage(_storage_info)
	view.spine_panel.show_inspection(_storage_info, session.recent_events())


func _save() -> void:
	last_storage_error = save_slot.write_state(session.snapshot(), session.spine_snapshot())
	_inspect_storage()
	if last_storage_error == OK:
		_saved_checkpoint = session.checkpoint()
		_refresh()
		view.show_status("Saved. Ready to continue next time.")
	else:
		view.show_status(_storage_message(last_storage_error, "save"), true)


func _load() -> void:
	var result: Dictionary = save_slot.read_state()
	last_storage_error = int(result["error"]) as Error
	_inspect_storage()
	if last_storage_error != OK:
		view.show_status(_storage_message(last_storage_error, "load"), true)
		return
	last_storage_error = session.restore(result["state"], result["spine"])
	if last_storage_error == OK:
		_saved_checkpoint = session.checkpoint()
		_refresh()
		view.show_status("Loaded your saved session." if int(result["source_schema"]) == 2 else \
			"Loaded your earlier save. It will upgrade safely on your next Save.")
	else:
		view.show_status("Save rejected. Your current session has not changed.", true)


func _recover() -> void:
	var result: Dictionary = save_slot.recover_backup(str(_storage_info.get("recovery_token", "")))
	last_storage_error = int(result["error"]) as Error
	if last_storage_error == OK:
		last_storage_error = session.restore(result["state"], result["spine"])
		if last_storage_error == OK:
			_saved_checkpoint = session.checkpoint()
			_recovery_note = str(result.get("preserved_copy", ""))
			if _recovery_note.is_empty():
				_recovery_note = "missing primary restored"
		_inspect_storage()
		_refresh()
		view.show_status("Previous save recovered. Original file and backup kept.", last_storage_error != OK)
	else:
		_inspect_storage()
		view.show_status("Recovery stopped safely. Files may have changed; no session data was loaded.", true)


func _reset() -> void:
	session.reset()
	view.show_status("Session reset. Your saved slot is untouched.")


func _refresh() -> void:
	var state: Dictionary = session.snapshot()
	view.show_state(state, session.can_work(), session.checkpoint() != _saved_checkpoint)
	view.show_events(session.recent_events())
	view.spine_panel.show_spine(session.spine_snapshot(), session.state_hash(), GameClock.MAX_TICK, IdFactory.MAX_ID, SimulationRng.MAX_DRAWS)
	view.spine_panel.show_inspection(_storage_info, session.recent_events())


func debug_report() -> String:
	var state: Dictionary = session.snapshot()
	var spine: Dictionary = session.spine_snapshot()
	return DebugReport.compose({
		"milestone": "6D.3 Control and icon kit", "save_schema": SkeletonSave.SCHEMA_VERSION,
		"simulation_seed": spine["rng"]["seed"], "simulation_tick": spine["tick"],
		"clock_mode": "command-driven; one tick = one minute",
		"next_command": spine["next_command"], "next_event_id": spine["next_id"],
		"rng_draws": spine["rng"]["draws"], "last_test_draw": spine["last_roll"],
		"state_hash": session.state_hash(), "cash_cents": state["cash_cents"],
		"elapsed_minutes": state["elapsed_minutes"], "completed_actions": state["completed_actions"],
		"unsaved_session": session.checkpoint() != _saved_checkpoint,
		"last_storage_error": int(last_storage_error),
		"save_inspection": _storage_info.get("primary", {}), "backup_inspection": _storage_info.get("backup", {}),
		"recovery": _recovery_note, "recent_events": session.recent_events(), "presentation": view.ui_snapshot(),
	})


func _copy_debug_report() -> void:
	_inspect_storage()
	if not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		view.show_status("Clipboard is unavailable in this display session.", true)
		return
	DisplayServer.clipboard_set(debug_report())
	view.show_status("Debug report copied.")


func _storage_message(error: Error, operation: String) -> String:
	if bool(_storage_info.get("can_recover", false)):
		return "Saved slot needs recovery. A verified previous save is available in the right rail."
	if error == ERR_FILE_NOT_FOUND:
		return "No saved slot yet. Your current session is unchanged."
	if error == ERR_UNAVAILABLE:
		return "Save or backup needs a compatible build. Nothing was overwritten."
	if error == ERR_FILE_CORRUPT:
		return "Save file needs attention. Nothing was overwritten. Copy the debug report."
	return "Could not %s (error %d). Copy the debug report." % [operation, int(error)]
