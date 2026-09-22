class_name WorkspacePreferences
extends RefCounted

# One bounded IO implementation for independent rail and widget presentation profiles.
const FORMAT: String = "sim-durty.workspace"
const MAX_BYTES: int = 8192
var _path: String
var _kind: String


func _init(path: String, kind: String = "rails") -> void:
	_path = path
	_kind = kind


static func path_for_slot(slot: String) -> String:
	return "user://ui_workspaces/%s.json" % slot.sha256_text().substr(0, 24)


func read_layout() -> Dictionary:
	return _read(_path)


func _validate(layout: Variant) -> bool:
	return WidgetLayout.validate(layout) if _kind == "widgets" else WorkspaceLayout.validate(layout)


func _format() -> String:
	return "sim-durty.widgets" if _kind == "widgets" else FORMAT


func write_layout(layout: Dictionary) -> Error:
	if not _valid_path() or not _validate(layout): return ERR_INVALID_DATA
	var previous: Dictionary = read_layout()
	if int(previous["error"]) not in [OK, ERR_FILE_NOT_FOUND]: return int(previous["error"]) as Error
	var error: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_path.get_base_dir()))
	if error != OK: return error
	var staged: String = _path + ".tmp"
	var file: FileAccess = FileAccess.open(staged, FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	file.store_string(JSON.stringify({"format": _format(), "layout": layout}, "\t", true))
	file.flush()
	error = file.get_error()
	file.close()
	if error != OK: return error
	var checked: Dictionary = _read(staged)
	if int(checked["error"]) != OK or checked["layout"] != layout: return ERR_FILE_CORRUPT
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(staged), ProjectSettings.globalize_path(_path))


func _valid_path() -> bool:
	return _kind in ["rails", "widgets"] and _path.begins_with("user://ui_workspaces/") and _path.ends_with(".json") \
		and not _path.contains("..") and _path.get_file().length() <= 100


func _read(path: String) -> Dictionary:
	if not _valid_path(): return {"error": ERR_INVALID_PARAMETER, "layout": {}}
	if not FileAccess.file_exists(path): return {"error": ERR_FILE_NOT_FOUND, "layout": {}}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null: return {"error": FileAccess.get_open_error(), "layout": {}}
	if file.get_length() == 0 or file.get_length() > MAX_BYTES:
		file.close()
		return {"error": ERR_FILE_CORRUPT, "layout": {}}
	var parser: JSON = JSON.new()
	var text: String = file.get_as_text()
	file.close()
	if parser.parse(text) != OK or not parser.data is Dictionary: return {"error": ERR_FILE_CORRUPT, "layout": {}}
	var envelope: Dictionary = parser.data
	if envelope.size() != 2 or envelope.get("format") != _format() or not envelope.get("layout") is Dictionary:
		return {"error": ERR_FILE_CORRUPT, "layout": {}}
	var incoming: Dictionary = envelope["layout"]
	var version: Variant = incoming.get("version")
	var expected: int = WidgetLayout.VERSION if _kind == "widgets" else WorkspaceLayout.VERSION
	if typeof(version) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(version)) and float(version) > expected:
		return {"error": ERR_UNAVAILABLE, "layout": {}}
	if not _validate(incoming): return {"error": ERR_FILE_CORRUPT, "layout": {}}
	if _kind == "widgets": return {"error": OK, "layout": WidgetLayout.normalize(incoming)}
	# Normalize JSON numeric values before nested comparison and publishing.
	var normalized: Dictionary = incoming.duplicate(true)
	normalized["version"] = int(normalized["version"])
	normalized["scale_percent"] = int(normalized["scale_percent"])
	for side: String in WorkspaceLayout.SIDES:
		normalized["rails"][side]["extent"] = int(normalized["rails"][side]["extent"])
	return {"error": OK, "layout": normalized}
