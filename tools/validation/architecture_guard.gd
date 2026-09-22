extends SceneTree

const REQUIRED_MEMORY_FILES: PackedStringArray = [
	"res://AGENTS.md",
	"res://docs/START_HERE.md",
	"res://docs/state.md",
	"res://docs/roadmap.md",
	"res://docs/design/master_vision.md",
	"res://docs/design/canon.md",
	"res://docs/architecture/overview.md",
	"res://docs/architecture/dependency_rules.md",
	"res://docs/architecture/state_ownership.md",
	"res://docs/architecture/build_pipeline.md",
	"res://docs/debug_report.md",
	"res://export_presets.cfg",
]

const SIMULATION_FORBIDDEN: PackedStringArray = [
	"res://game/ui/",
	"res://game/app/",
	"get_tree().root",
	"get_node(\"/root",
	"randomize(",
	"randf(",
	"randi(",
	"Time.get_ticks_",
	"Time.get_unix_time_",
]

const CORE_FORBIDDEN: PackedStringArray = [
	"res://game/ui/",
	"res://game/simulation/",
	"res://game/features/",
]

var failures: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("[architecture] SIM-DURTY guard")

	_validate_required_memory()
	_scan_scope("res://game/core", CORE_FORBIDDEN)
	_scan_scope("res://game/simulation", SIMULATION_FORBIDDEN)

	if failures == 0:
		print("[architecture] PASS")
		quit(0)
		return

	push_error("[architecture] FAIL: %d violation(s)" % failures)
	quit(1)


func _validate_required_memory() -> void:
	for path: String in REQUIRED_MEMORY_FILES:
		if FileAccess.file_exists(path):
			continue
		_fail("required project-memory file missing: %s" % path)


func _scan_scope(root_path: String, forbidden_patterns: PackedStringArray) -> void:
	var directory: DirAccess = DirAccess.open(root_path)
	if directory == null:
		return

	_scan_directory(root_path, forbidden_patterns)


func _scan_directory(path: String, forbidden_patterns: PackedStringArray) -> void:
	var directory: DirAccess = DirAccess.open(path)
	if directory == null:
		_fail("unable to scan architecture scope: %s" % path)
		return

	for file_name: String in directory.get_files():
		if not file_name.ends_with(".gd"):
			continue
		_scan_file(path.path_join(file_name), forbidden_patterns)

	for directory_name: String in directory.get_directories():
		_scan_directory(path.path_join(directory_name), forbidden_patterns)


func _scan_file(path: String, forbidden_patterns: PackedStringArray) -> void:
	var source: String = FileAccess.get_file_as_string(path)
	var lines: PackedStringArray = source.split("\n")

	for line_index: int in range(lines.size()):
		var line: String = lines[line_index]
		var stripped: String = line.strip_edges()

		if stripped.begins_with("#"):
			continue

		for pattern: String in forbidden_patterns:
			if not line.contains(pattern):
				continue
			_fail("%s:%d contains forbidden dependency/pattern: %s" % [
				path,
				line_index + 1,
				pattern,
			])


func _fail(message: String) -> void:
	failures += 1
	push_error("[architecture] %s" % message)
