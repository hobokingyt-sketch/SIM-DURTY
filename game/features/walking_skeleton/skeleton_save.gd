class_name SkeletonSave
extends RefCounted

const SCHEMA_VERSION: int = 2
const FORMAT_ID: String = "sim-durty.walking-skeleton"
const ACTIVITY_ID: String = "skeleton_errand"
const MAX_FILE_BYTES: int = 16384
const MAX_REJECTED_COPIES: int = 32

var _path: String


func _init(path: String) -> void:
	_path = path


func read_state() -> Dictionary:
	return _read_path(_path)


func inspect_slot() -> Dictionary:
	# Read-only. Called on storage operations or inspection, never every simulation tick.
	var primary: Dictionary = _read_path(_path)
	var backup: Dictionary = _read_path(_path + ".bak")
	var eligible: bool = int(primary["error"]) in [ERR_FILE_NOT_FOUND, ERR_FILE_CORRUPT] \
		and int(backup["error"]) == OK
	var token: String = _recovery_token() if eligible else ""
	return {
		"primary": _summary(primary), "backup": _summary(backup),
		"can_recover": eligible and not token.is_empty(), "recovery_token": token,
	}


func recover_backup(expected_token: String) -> Dictionary:
	# Explicit recovery only. Never roll a valid or incompatible primary backward.
	var inspection: Dictionary = inspect_slot()
	if not bool(inspection["can_recover"]):
		return {"error": ERR_UNAVAILABLE, "state": {}}
	if expected_token.is_empty() or expected_token != str(inspection["recovery_token"]):
		return {"error": ERR_BUSY, "state": {}}
	var backup: Dictionary = _read_path(_path + ".bak")
	var stage: String = _path + ".recover.tmp"
	var error: Error = DirAccess.copy_absolute(
		ProjectSettings.globalize_path(_path + ".bak"), ProjectSettings.globalize_path(stage)
	)
	if error != OK:
		return {"error": error, "state": {}}
	var candidate: Dictionary = _read_path(stage)
	if int(candidate["error"]) != OK or candidate.get("state") != backup.get("state") \
			or candidate.get("spine") != backup.get("spine") \
			or _bounded_digest(stage) != _bounded_digest(_path + ".bak"):
		return _recovery_failure(stage, ERR_FILE_CORRUPT)
	if _recovery_token() != expected_token:
		return _recovery_failure(stage, ERR_BUSY)
	var preserved: String = ""
	if FileAccess.file_exists(_path):
		preserved = _unused_rejected_path()
		if preserved.is_empty():
			return _recovery_failure(stage, ERR_ALREADY_EXISTS)
		error = DirAccess.copy_absolute(ProjectSettings.globalize_path(_path), ProjectSettings.globalize_path(preserved))
		if error != OK:
			return _recovery_failure(stage, error)
		if _bounded_digest(preserved).is_empty() or _bounded_digest(preserved) != _bounded_digest(_path):
			return _recovery_failure(stage, ERR_FILE_CORRUPT)
	# Recheck after preserving the rejected file. One writer per slot is still required.
	if _recovery_token() != expected_token:
		return _recovery_failure(stage, ERR_BUSY)
	error = DirAccess.rename_absolute(ProjectSettings.globalize_path(stage), ProjectSettings.globalize_path(_path))
	if error != OK:
		return _recovery_failure(stage, error)
	candidate["preserved_copy"] = preserved.get_file()
	return candidate


func _recovery_failure(stage: String, error: Error) -> Dictionary:
	var cleanup_error: Error = OK
	if FileAccess.file_exists(stage):
		cleanup_error = DirAccess.remove_absolute(ProjectSettings.globalize_path(stage))
	return {"error": error, "cleanup_error": cleanup_error, "state": {}}


func _unused_rejected_path() -> String:
	for index: int in range(1, MAX_REJECTED_COPIES + 1):
		var candidate: String = "%s.rejected-%03d" % [_path, index]
		if not FileAccess.file_exists(candidate) and not DirAccess.dir_exists_absolute(candidate):
			return candidate
	return ""


func _recovery_token() -> String:
	if not _valid_path():
		return ""
	var primary: String = _bounded_digest(_path)
	var backup: String = _bounded_digest(_path + ".bak")
	if primary.is_empty() or backup.is_empty() or backup == "missing":
		return ""
	return (primary + ":" + backup).sha256_text()


static func _bounded_digest(path: String) -> String:
	if not FileAccess.file_exists(path):
		return "missing"
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var length: int = file.get_length()
	if length > MAX_FILE_BYTES:
		file.close()
		return ""
	var bytes: PackedByteArray = file.get_buffer(length)
	file.close()
	if bytes.size() != length:
		return ""
	# A bounded content token, not a timestamp or a simulation RNG draw.
	return bytes.hex_encode().sha256_text()


static func _summary(result: Dictionary) -> Dictionary:
	var error: int = int(result["error"])
	var status: String = "unreadable"
	match error:
		OK: status = "ready"
		ERR_FILE_NOT_FOUND: status = "missing"
		ERR_FILE_CORRUPT: status = "damaged"
		ERR_UNAVAILABLE: status = "incompatible"
	var summary: Dictionary = {"error": error, "status": status, "schema": int(result.get("source_schema", 0))}
	if error == OK:
		summary["cash_cents"] = result["state"]["cash_cents"]
		summary["elapsed_minutes"] = result["state"]["elapsed_minutes"]
		summary["completed_actions"] = result["state"]["completed_actions"]
	return summary


func write_state(state: Dictionary, spine: Dictionary = {}) -> Error:
	if not _valid_path() or not SkeletonSession.is_valid_snapshot(state):
		return ERR_INVALID_DATA
	var simulation: Dictionary = SkeletonSession.default_spine(state) if spine.is_empty() else spine
	var error: Error = SkeletonSession.validate_spine(simulation, state)
	if error != OK:
		return error
	# A missing primary with a backup is a recovery case, not a fresh slot.
	if not FileAccess.file_exists(_path) and FileAccess.file_exists(_path + ".bak"):
		return ERR_UNAVAILABLE
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
