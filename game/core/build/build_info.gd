class_name BuildInfo
extends RefCounted

const MANIFEST_PATH: String = "res://game/core/build/generated/build_manifest.json"
const MANIFEST_SCHEMA: int = 1


static func snapshot() -> Dictionary:
	var info: Dictionary = _fallback_snapshot()

	if FileAccess.file_exists(MANIFEST_PATH):
		var raw_text: String = FileAccess.get_file_as_string(MANIFEST_PATH)
		var parsed: Variant = JSON.parse_string(raw_text)

		if parsed is Dictionary:
			var manifest: Dictionary = parsed
			for key: Variant in manifest.keys():
				info[key] = manifest[key]
			info["manifest_present"] = true

	info["game_version"] = str(
		ProjectSettings.get_setting("application/config/version", "unknown")
	)
	info["engine_version"] = str(Engine.get_version_info().get("string", "unknown"))

	return info


static func build_id() -> String:
	return str(snapshot().get("build_id", "local-dev"))


static func is_generated_build() -> bool:
	var info: Dictionary = snapshot()
	return bool(info.get("manifest_present", false)) \
		and int(info.get("manifest_schema", 0)) == MANIFEST_SCHEMA


static func _fallback_snapshot() -> Dictionary:
	return {
		"manifest_schema": 0,
		"manifest_present": false,
		"channel": "local",
		"build_id": "local-dev",
		"commit_sha": "local",
		"commit_short": "local",
		"source_sha": "local",
		"ref_name": "local",
		"build_number": "local",
		"workflow_run_id": "local",
		"pull_request": "none",
		"built_at_utc": "unknown",
	}
