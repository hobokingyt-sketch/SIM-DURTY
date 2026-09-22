extends SceneTree

const BuildInfoScript = preload("res://game/core/build/build_info.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var info: Dictionary = BuildInfoScript.snapshot()
	var failures: PackedStringArray = PackedStringArray()

	if not bool(info.get("manifest_present", false)):
		failures.append("generated build manifest is missing")
	if int(info.get("manifest_schema", 0)) != BuildInfoScript.MANIFEST_SCHEMA:
		failures.append("build manifest schema is not supported")
	if str(info.get("build_id", "")).is_empty():
		failures.append("build_id is empty")
	if str(info.get("commit_sha", "")).is_empty() or str(info.get("commit_sha", "")) == "local":
		failures.append("commit_sha is not a generated build identity")
	if str(info.get("channel", "")) == "local":
		failures.append("build channel is still local fallback")

	if failures.is_empty():
		print("[build] manifest verified: %s" % str(info.get("build_id", "unknown")))
		quit(0)
		return

	for failure: String in failures:
		push_error("[build] %s" % failure)
	quit(1)
