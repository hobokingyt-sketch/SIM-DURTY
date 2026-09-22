class_name DebugReport
extends RefCounted


static func compose(runtime_state: Dictionary = {}) -> String:
	var build: Dictionary = BuildInfo.snapshot()
	var lines: PackedStringArray = PackedStringArray()

	lines.append("SIM-DURTY DEBUG REPORT")
	lines.append("======================")
	lines.append("game_version: %s" % str(build.get("game_version", "unknown")))
	lines.append("build_id: %s" % str(build.get("build_id", "unknown")))
	lines.append("build_channel: %s" % str(build.get("channel", "unknown")))
	lines.append("commit_sha: %s" % str(build.get("commit_sha", "unknown")))
	lines.append("source_sha: %s" % str(build.get("source_sha", "unknown")))
	lines.append("ref_name: %s" % str(build.get("ref_name", "unknown")))
	lines.append("build_number: %s" % str(build.get("build_number", "unknown")))
	lines.append("workflow_run_id: %s" % str(build.get("workflow_run_id", "unknown")))
	lines.append("pull_request: %s" % str(build.get("pull_request", "none")))
	lines.append("built_at_utc: %s" % str(build.get("built_at_utc", "unknown")))
	lines.append("godot_version: %s" % str(build.get("engine_version", "unknown")))
	lines.append("platform: %s" % OS.get_name())
	lines.append("reference_viewport: 2560x1440")
	lines.append("")
	lines.append("RUNTIME STATE")
	lines.append("-------------")
	lines.append("milestone: %s" % str(runtime_state.get("milestone", "Infrastructure 2")))
	lines.append("save_schema: %s" % str(runtime_state.get("save_schema", "none")))
	lines.append("simulation_seed: %s" % str(runtime_state.get("simulation_seed", "none")))
	lines.append("simulation_tick: %s" % str(runtime_state.get("simulation_tick", "none")))

	var reserved: PackedStringArray = PackedStringArray([
		"milestone",
		"save_schema",
		"simulation_seed",
		"simulation_tick",
	])
	var extra_keys: Array = runtime_state.keys()
	extra_keys.sort()

	for key: Variant in extra_keys:
		var key_text: String = str(key)
		if reserved.has(key_text):
			continue
		lines.append("%s: %s" % [key_text, str(runtime_state[key])])

	return "\n".join(lines)
