class_name OsAppNavigation
extends RefCounted

var _route: Dictionary = {"kind": "city"}
var _remembered_views: Dictionary = {}
var _back_stacks: Dictionary = {}

func open_app(app_id: String, requested_view: String = "") -> Error:
	if not OsAppManifest.has_app(app_id):
		return ERR_INVALID_PARAMETER
	var view_id: String = requested_view
	if view_id.is_empty():
		view_id = str(_remembered_views.get(app_id, OsAppManifest.default_view(app_id)))
	if not OsAppManifest.has_view(app_id, view_id):
		return ERR_INVALID_PARAMETER
	if _route.get("kind") == "app" and _route.get("app_id") == app_id:
		var current: String = str(_route.get("view_id", ""))
		if current != view_id:
			_push_back(app_id, current)
	_route = {"kind": "app", "app_id": app_id, "view_id": view_id}
	_remembered_views[app_id] = view_id
	return OK

func navigate_view(view_id: String) -> Error:
	if _route.get("kind") != "app":
		return ERR_UNAVAILABLE
	var app_id: String = str(_route.get("app_id", ""))
	if not OsAppManifest.has_view(app_id, view_id):
		return ERR_INVALID_PARAMETER
	var current: String = str(_route.get("view_id", ""))
	if current == view_id:
		return OK
	_push_back(app_id, current)
	_route = {"kind": "app", "app_id": app_id, "view_id": view_id}
	_remembered_views[app_id] = view_id
	return OK

func back() -> bool:
	if _route.get("kind") != "app":
		return false
	var app_id: String = str(_route.get("app_id", ""))
	var stack: Array = (_back_stacks.get(app_id, []) as Array).duplicate()
	if stack.is_empty():
		return false
	var view_id: String = str(stack.pop_back())
	_back_stacks[app_id] = stack
	_route = {"kind": "app", "app_id": app_id, "view_id": view_id}
	_remembered_views[app_id] = view_id
	return true

func return_to_city() -> void:
	_route = {"kind": "city"}

func snapshot() -> Dictionary:
	var active_app: String = "city"
	var active_view: String = ""
	var host: String = "city"
	var depth: int = 0
	if _route.get("kind") == "app":
		active_app = str(_route.get("app_id", ""))
		active_view = str(_route.get("view_id", ""))
		host = OsAppManifest.host_mode(active_app)
		depth = (_back_stacks.get(active_app, []) as Array).size()
	return {"route": _route.duplicate(true), "active_app": active_app, "active_view": active_view,
		"host_mode": host, "back_depth": depth, "remembered_views": _remembered_views.duplicate(true)}

func _push_back(app_id: String, view_id: String) -> void:
	if view_id.is_empty():
		return
	var stack: Array = (_back_stacks.get(app_id, []) as Array).duplicate()
	if stack.is_empty() or str(stack.back()) != view_id:
		stack.append(view_id)
	if stack.size() > 16:
		stack.pop_front()
	_back_stacks[app_id] = stack
