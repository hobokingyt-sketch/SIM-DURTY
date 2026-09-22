class_name RuntimeHealth
extends RefCounted

const FOUNDATION_VERSION: int = 0


static func foundation_report() -> Dictionary:
	var version_info: Dictionary = Engine.get_version_info()

	return {
		"ok": true,
		"foundation_version": FOUNDATION_VERSION,
		"engine_version": str(version_info.get("string", "unknown")),
	}
