class_name OsAppManifest
extends RefCounted

const HOST_CENTER: String = "center"
const HOST_RIGHT: String = "right"
const APPS: Dictionary = {
	"operations": {"title": "Operations", "host": HOST_CENTER, "default_view": "work", "views": ["work", "record"]},
	"record": {"title": "Session Record", "host": HOST_RIGHT, "default_view": "activity", "views": ["activity", "storage"]},
}

static func has_app(app_id: String) -> bool:
	return APPS.has(app_id)

static func host_mode(app_id: String) -> String:
	return str(APPS.get(app_id, {}).get("host", ""))

static func default_view(app_id: String) -> String:
	return str(APPS.get(app_id, {}).get("default_view", ""))

static func views(app_id: String) -> PackedStringArray:
	var result: PackedStringArray = []
	for view_id: Variant in APPS.get(app_id, {}).get("views", []):
		result.append(str(view_id))
	return result

static func has_view(app_id: String, view_id: String) -> bool:
	return has_app(app_id) and views(app_id).has(view_id)
