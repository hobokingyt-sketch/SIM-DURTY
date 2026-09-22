extends SceneTree

const OUTPUT_DIRECTORY: String = "res://game/core/build/generated"
const OUTPUT_PATH: String = OUTPUT_DIRECTORY + "/build_manifest.json"
const MANIFEST_SCHEMA: int = 1


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var commit_sha: String = _required_environment("SIM_DURTY_BUILD_SHA")
	var channel: String = _required_environment("SIM_DURTY_BUILD_CHANNEL")
	var build_number: String = _required_environment("SIM_DURTY_BUILD_NUMBER")
	var ref_name: String = _required_environment("SIM_DURTY_BUILD_REF")
	var built_at_utc: String = _required_environment("SIM_DURTY_BUILD_TIME_UTC")

	if commit_sha.is_empty() \
			or channel.is_empty() \
			or build_number.is_empty() \
			or ref_name.is_empty() \
			or built_at_utc.is_empty():
		quit(1)
		return

	var commit_short: String = commit_sha.substr(0, mini(12, commit_sha.length()))
	var manifest: Dictionary = {
		"manifest_schema": MANIFEST_SCHEMA,
		"channel": channel,
		"build_id": "%s-%s-%s" % [channel, build_number, commit_short],
		"commit_sha": commit_sha,
		"commit_short": commit_short,
		"source_sha": OS.get_environment("SIM_DURTY_SOURCE_SHA"),
		"ref_name": ref_name,
		"build_number": build_number,
		"workflow_run_id": OS.get_environment("SIM_DURTY_BUILD_RUN_ID"),
		"pull_request": OS.get_environment("SIM_DURTY_BUILD_PR"),
		"built_at_utc": built_at_utc,
		"game_version": str(ProjectSettings.get_setting("application/config/version", "unknown")),
		"engine_version": str(Engine.get_version_info().get("string", "unknown")),
	}

	if str(manifest["source_sha"]).is_empty():
		manifest["source_sha"] = commit_sha
	if str(manifest["workflow_run_id"]).is_empty():
		manifest["workflow_run_id"] = "local"
	if str(manifest["pull_request"]).is_empty():
		manifest["pull_request"] = "none"

	var absolute_directory: String = ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(absolute_directory)
	if directory_error != OK:
		push_error("[build] unable to create build metadata directory: %s" % directory_error)
		quit(1)
		return

	var file: FileAccess = FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[build] unable to open build manifest for writing")
		quit(1)
		return

	file.store_string(JSON.stringify(manifest, "\t"))
	file.close()

	print("[build] wrote %s" % OUTPUT_PATH)
	print("[build] build_id=%s" % str(manifest["build_id"]))
	quit(0)


func _required_environment(name: String) -> String:
	var value: String = OS.get_environment(name).strip_edges()
	if value.is_empty():
		push_error("[build] required environment variable missing: %s" % name)
	return value
