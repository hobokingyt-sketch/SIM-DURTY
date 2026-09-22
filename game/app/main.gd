extends Control

const WORK: SkeletonWorkDefinition = preload("res://game/content/work/skeleton_errand.tres")

@export var save_path: String = "user://walking_skeleton/slot_v1.json"
@export var auto_load: bool = true

@onready var view: SkeletonView = %SkeletonView

var session: SkeletonSession
var save_slot: SkeletonSave
var last_storage_error: Error = OK
var _saved_snapshot: Dictionary = {}


func _ready() -> void:
	var probe_mode: String = ""
	if OS.is_debug_build():
		for argument: String in OS.get_cmdline_user_args():
			if argument.begins_with("--skeleton-probe="):
				probe_mode = argument.trim_prefix("--skeleton-probe=")
				save_path = "user://_ci_walking_skeleton/probe_slot_v1.json"
				auto_load = false
	session = SkeletonSession.new(WORK)
	save_slot = SkeletonSave.new(save_path)
	session.changed.connect(_refresh)
	view.work_requested.connect(_work)
	view.save_requested.connect(_save)
	view.load_requested.connect(_load)
	view.reset_requested.connect(_reset)
	view.debug_report_requested.connect(_copy_debug_report)
	view.configure_work(WORK)
	view.show_build(BuildInfo.snapshot())
	_refresh()
	if auto_load and FileAccess.file_exists(save_path):
		_load()
	else:
		view.show_status("No save yet. Save when you want to keep this session.")
	print("[SIM-DURTY] Walking Skeleton boot OK | build=%s" % BuildInfo.build_id())
	print(debug_report())
	if not probe_mode.is_empty():
		var probe: Script = load("res://game/devtools/skeleton_probe.gd") as Script
		probe.call_deferred("run", self, probe_mode)


func _work() -> void:
	var error: Error = session.perform_work()
	view.show_status(
		"Errand complete. +%s; %d minutes passed." % [
			SkeletonView.money_text(WORK.payout_cents), WORK.duration_minutes,
		] if error == OK else "This test session has reached its supported limit.",
		error != OK
	)


func _save() -> void:
	last_storage_error = save_slot.write_state(session.snapshot())
	if last_storage_error == OK:
		_saved_snapshot = session.snapshot()
		_refresh()
		view.show_status("Saved. This slot will load automatically when you reopen the game.")
	else:
		view.show_status(_storage_message(last_storage_error, "save"), true)


func _load() -> void:
	var result: Dictionary = save_slot.read_state()
	last_storage_error = int(result["error"]) as Error
	if last_storage_error != OK:
		view.show_status(_storage_message(last_storage_error, "load"), true)
		return
	last_storage_error = session.restore(result["state"])
	if last_storage_error == OK:
		_saved_snapshot = session.snapshot()
		_refresh()
		view.show_status("Loaded your saved session.")
	else:
		view.show_status("Save rejected. Your current session has not changed.", true)


func _reset() -> void:
	session.reset()
	view.show_status("Session reset. Your saved slot is untouched; Load brings it back.")


func _refresh() -> void:
	var state: Dictionary = session.snapshot()
	view.show_state(state, session.can_work(), state != _saved_snapshot)


func debug_report() -> String:
	var state: Dictionary = session.snapshot()
	return DebugReport.compose({
		"milestone": "Walking Skeleton",
		"save_schema": SkeletonSave.SCHEMA_VERSION,
		"simulation_seed": "none",
		"simulation_tick": "none",
		"cash_cents": state["cash_cents"],
		"elapsed_minutes": state["elapsed_minutes"],
		"completed_actions": state["completed_actions"],
		"unsaved_session": state != _saved_snapshot,
		"last_storage_error": int(last_storage_error),
	})


func _copy_debug_report() -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		view.show_status("Clipboard is unavailable in this display session.", true)
		return
	DisplayServer.clipboard_set(debug_report())
	view.show_status("Debug report copied. Paste it into chat with what went wrong.")


func _storage_message(error: Error, operation: String) -> String:
	if error == ERR_FILE_NOT_FOUND:
		return "No saved slot yet. Your current session is unchanged."
	if error == ERR_UNAVAILABLE:
		return "This slot uses another save version. It was not loaded or overwritten."
	if error == ERR_FILE_CORRUPT:
		return "Save file rejected. Session and saved slot are unchanged. Copy the debug report."
	return "Could not %s (error %d). Your session is unchanged. Copy the debug report." % [
		operation, int(error),
	]
