class_name OsAppSurface
extends PanelContainer

var app_id: String = ""
var host_mode: String = ""
var _views: Dictionary = {}
var _active_view: String = ""
var _active: bool = false
var _focus_by_view: Dictionary = {}
var _host: Control

func setup(id: String, host: String) -> void:
	app_id = id
	host_mode = host
	_ensure_host()
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func register_view(view_id: String, control: Control) -> void:
	_ensure_host()
	if _views.has(view_id):
		return
	_views[view_id] = control
	_host.add_child(control)
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	control.hide()
	control.process_mode = Node.PROCESS_MODE_DISABLED

func activate(view_id: String) -> void:
	if not _views.has(view_id):
		return
	if _active and _active_view != view_id:
		_remember_focus()
	_active = true
	_active_view = view_id
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	mouse_filter = Control.MOUSE_FILTER_STOP
	for id: String in _views:
		var control: Control = _views[id]
		var selected: bool = id == view_id
		control.visible = selected
		control.process_mode = Node.PROCESS_MODE_INHERIT if selected else Node.PROCESS_MODE_DISABLED
	call_deferred("_restore_focus", view_id)

func suspend() -> void:
	if _active:
		_remember_focus()
	_active = false
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for control: Control in _views.values():
		control.process_mode = Node.PROCESS_MODE_DISABLED

func snapshot() -> Dictionary:
	return {"app_id": app_id, "host_mode": host_mode, "active": _active,
		"active_view": _active_view, "mounted_views": _views.size(), "remembered_focus": _focus_by_view.duplicate(true)}

func _ensure_host() -> void:
	if is_instance_valid(_host):
		return
	_host = Control.new()
	_host.name = "ViewHost"
	add_child(_host)
	_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _remember_focus() -> void:
	if _active_view.is_empty() or not is_inside_tree():
		return
	var owner: Control = get_viewport().gui_get_focus_owner()
	if is_instance_valid(owner) and is_ancestor_of(owner):
		_focus_by_view[_active_view] = get_path_to(owner)

func _restore_focus(view_id: String) -> void:
	if not _active or _active_view != view_id or not is_inside_tree():
		return
	var path: Variant = _focus_by_view.get(view_id)
	if path == null:
		return
	var target: Node = get_node_or_null(path)
	if target is Control and target.is_visible_in_tree():
		(target as Control).grab_focus()
