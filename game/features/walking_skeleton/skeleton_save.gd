class_name SkeletonSave
extends RefCounted

const SCHEMA_VERSION: int = 2
const FORMAT_ID: String = "sim-durty.walking-skeleton"
const ACTIVITY_ID: String = "skeleton_errand"
const MAX_FILE_BYTES: int = 16384

var _path: String


func _init(path: String) -> void:
	_path = path


func read_state() -> Dictionary:
	return _read_path(_path)


func write_state(state: Dictionary, spine: Dictionary = {}) -> Error:
	if not _valid_path() or not SkeletonSession.is_valid_snapshot(state):
		return ERR_INVALID_DATA
	var simulation: Dictionary = SkeletonSession.default_spine(state) if spine.is_empty() else spine
	var error: Error = SkeletonSession.validate_spine(simulation, state)
	if error != OK:
		return error
	# Never replace an unreadable/corrupt/newer save, including incompatible RNG contracts.
	if FileAccess.file_exists(_path):
		var existing: Dictionary = read_state()
		if int(existing["error"]) != OK:
			return int(existing["error"]) as Error
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_path.get_base_dir()))
	if directory_error != OK:
		return directory_error
	var temporary_path: String = _path + ".tmp"
	var file: FileAccess = FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(envelope(state, simulation), "\t", true))
	file.flush()
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		return write_error
	var verification: Dictionary = _read_path(temporary_path)
	if int(verification["error"]) != OK or verification["state"] != state \
			or verification["spine"] != simulation:
		return ERR_FILE_CORRUPT
	if FileAccess.file_exists(_path):
		var backup_error: Error = DirAccess.copy_absolute(
			ProjectSettings.globalize_path(_path), ProjectSettings.globalize_path(_path + ".bak")
		)
		if backup_error != OK:
			return backup_error
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary_path), ProjectSettings.globalize_path(_path))


func _valid_path() -> bool:
	return _path.begins_with("user://") and not _path.contains("..") and _path.ends_with(".json")


func _read_path(path: String) -> Dictionary:
	if not _valid_path():
		return {"error": ERR_INVALID_PARAMETER, "state": {}}
	if not FileAccess.file_exists(path):
		return {"error": ERR_FILE_NOT_FOUND, "state": {}}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"error": FileAccess.get_open_error(), "state": {}}
	if file.get_length() == 0 or file.get_length() > MAX_FILE_BYTES:
		file.close()
		return {"error": ERR_FILE_CORRUPT, "state": {}}
	var text: String = file.get_as_text()
	file.close()
	return decode(text)


static func envelope(state: Dictionary, spine: Dictionary = {}) -> Dictionary:
	return {
		"format_id": FORMAT_ID, "schema_version": SCHEMA_VERSION,
		"activity_id": ACTIVITY_ID, "state": state.duplicate(true),
		"spine": SkeletonSession.default_spine(state) if spine.is_empty() else spine.duplicate(true),
	}


static func decode(text: String) -> Dictionary:
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return {"error": ERR_FILE_CORRUPT, "state": {}}
	var data: Dictionary = parser.data
	if data.get("format_id") != FORMAT_ID:
		return {"error": ERR_FILE_CORRUPT, "state": {}}
	var version: Variant = data.get("schema_version")
	if not SkeletonSession.is_bounded_integer(version, 1000000):
		return {"error": ERR_FILE_CORRUPT, "state": {}}
	if int(version) not in [1, SCHEMA_VERSION]:
		return {"error": ERR_UNAVAILABLE, "state": {}}
	if data.get("activity_id") != ACTIVITY_ID or not SkeletonSession.is_valid_snapshot(data.get("state")):
		return {"error": ERR_FILE_CORRUPT, "state": {}}
	var source: Dictionary = data["state"]
	var state: Dictionary = {
		"cash_cents": int(source["cash_cents"]),
		"elapsed_minutes": int(source["elapsed_minutes"]),
		"completed_actions": int(source["completed_actions"]),
	}
	# Schema 1 has no seed/history; initialize the documented default without inventing past events.
	var spine: Variant = SkeletonSession.default_spine(state) if int(version) == 1 else data.get("spine")
	var error: Error = SkeletonSession.validate_spine(spine, state)
	if error != OK:
		return {"error": ERR_UNAVAILABLE if error == ERR_UNAVAILABLE else ERR_FILE_CORRUPT, "state": {}}
	var normalized: Dictionary = spine.duplicate(true)
	for key: String in ["version", "tick", "next_id", "next_command", "last_roll"]:
		normalized[key] = int(normalized[key])
	normalized["rng"]["seed"] = int(normalized["rng"]["seed"])
	normalized["rng"]["draws"] = int(normalized["rng"]["draws"])
	return {"error": OK, "state": state, "spine": normalized, "source_schema": int(version)}
