class_name WidgetWorkspace
extends Node

signal inspect_requested(work_id: String)
signal record_requested
signal status_changed(message: String, failed: bool)

var widgets: Dictionary = {}
var storage_error: Error = OK
var _preferred: Dictionary = WidgetLayout.defaults()
var _resolved: Dictionary = {}
var _docks: Dictionary = {}
var _outer: WorkspaceContainer
var _shell: Control
var _preferences: WorkspacePreferences
var _gesture: Dictionary = {}
var _ghost: Panel
var _ghost_label: Label
var _pending: bool = false
var _swallow_release: bool = false


func setup(shell: Control, outer: WorkspaceContainer, bottom: WidgetDock, right: WidgetDock) -> void:
	_shell = shell
	_outer = outer
	_docks = {"bottom": bottom, "right": right}
	for id: String in WidgetLayout.IDS:
		var widget: WidgetView = WidgetView.new()
		widget.widget_id = id
		widget.name = id.to_pascal_case()
		bottom.canvas.add_child(widget)
		widgets[id] = widget
		widget.inspect_requested.connect(func(work_id: String) -> void: inspect_requested.emit(work_id))
		widget.record_requested.connect(func() -> void: record_requested.emit())
		widget.manipulation_requested.connect(begin_manipulation)
		widget.key_requested.connect(_key_action)
		widget.option_requested.connect(_option_action)
		widget.menu_requested.connect(_update_menu)
	_ghost = Panel.new()
	_ghost.z_index = 100
	_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghost.size = Vector2(240, 70)
	_ghost.hide()
	_shell.add_child(_ghost)
	_ghost_label = OsTokens.wrapped(_ghost, "", 16, OsTokens.TEXT)
	_ghost_label.position = Vector2(12, 8)
	_ghost_label.size = Vector2(216, 54)
	for dock: WidgetDock in _docks.values():
		dock.resized.connect(_geometry_changed)
		dock.visibility_changed.connect(_geometry_changed)
	_outer.model.changed.connect(_geometry_changed)
	_shell.resized.connect(_geometry_changed)
	get_window().focus_exited.connect(cancel_manipulation)
	request_layout()


func configure_profile(slot: String, enabled: bool) -> void:
	cancel_manipulation()
	_preferred = WidgetLayout.defaults()
	_preferences = null
	storage_error = OK
	if enabled:
		_preferences = WorkspacePreferences.new(profile_path(slot), "widgets")
		var result: Dictionary = _preferences.read_layout()
		storage_error = int(result["error"]) as Error
		if storage_error == OK: _preferred = WidgetLayout.normalize(result["layout"])
		elif storage_error == ERR_FILE_NOT_FOUND: storage_error = OK
	request_layout()


static func profile_path(slot: String) -> String:
	return WorkspacePreferences.path_for_slot(slot).trim_suffix(".json") + ".widgets.json"


func snapshot() -> Dictionary:
	return _preferred.duplicate(true)


func effective_snapshot() -> Dictionary:
	return _resolved.duplicate(true)


func manipulation_snapshot() -> Dictionary:
	return _gesture.duplicate(true)


func reset_widgets() -> void:
	cancel_manipulation()
	_commit(WidgetLayout.defaults())


func configure_work(definition: SkeletonWorkDefinition) -> void:
	(widgets["work_scan"] as WidgetView).bind_work(definition)


func show_state(state: Dictionary, available: bool) -> void:
	for widget: WidgetView in widgets.values(): widget.bind_state(state, available)


func show_events(events: Array[Dictionary]) -> void:
	(widgets["recent_activity"] as WidgetView).bind_events(events)


func set_selected(id: String) -> void:
	(widgets["work_scan"] as WidgetView).set_selected(id)


func _capacities(visible_only: bool = false) -> Dictionary:
	var result: Dictionary = {}
	for region: String in WidgetLayout.REGIONS:
		var dock: WidgetDock = _docks[region]
		result[region] = Vector2.ZERO if visible_only and not dock.is_visible_in_tree() else dock.capacity()
	return result


func _geometry_changed() -> void:
	cancel_manipulation()
	request_layout()


func request_layout() -> void:
	if _pending: return
	_pending = true
	call_deferred("_apply_layout")


func _apply_layout() -> void:
	_pending = false
	if not is_inside_tree() or _docks.is_empty(): return
	_resolved = WidgetLayout.solve(_preferred, _capacities())
	var focused: Control = get_viewport().gui_get_focus_owner()
	for region: String in WidgetLayout.REGIONS:
		var dock: WidgetDock = _docks[region]
		dock.canvas.custom_minimum_size = _resolved["regions"][region]["content_size"]
	for id: String in WidgetLayout.IDS:
		var item: Dictionary = _resolved["items"][id]
		var widget: WidgetView = widgets[id]
		var dock: WidgetDock = _docks[item["region"]]
		if widget.get_parent() != dock.canvas:
			widget.reparent(dock.canvas, false)
		widget.position = item["rect"].position
		widget.size = item["rect"].size
		if widget.effective_form != item["form"]: widget.apply_form(item["form"])
	if is_instance_valid(focused) and focused.is_visible_in_tree() and get_viewport().gui_get_focus_owner() == null:
		focused.grab_focus()


func move_widget(id: String, region: String, index: int) -> bool:
	cancel_manipulation()
	var candidate: Dictionary = WidgetLayout.propose_move(_preferred, _capacities(true), id, region, index)
	return _accept(candidate)


func resize_widget(id: String, form: String) -> bool:
	cancel_manipulation()
	return _accept(WidgetLayout.propose_form(_preferred, _capacities(true), id, form))


func _accept(candidate: Dictionary) -> bool:
	if candidate.is_empty():
		status_changed.emit("That placement does not fit. Expand the destination rail or choose a smaller form.", true)
		return false
	_commit(candidate)
	return true


func _commit(candidate: Dictionary) -> void:
	if not WidgetLayout.validate(candidate): return
	var normalized: Dictionary = WidgetLayout.normalize(candidate)
	if normalized == _preferred: return
	_preferred = normalized
	if _preferences != null: storage_error = _preferences.write_layout(_preferred)
	request_layout()
	status_changed.emit("Widget arrangement saved." if storage_error == OK else "Widget arrangement is temporary. The saved profile was preserved; copy report for details.", storage_error != OK)


func begin_manipulation(id: String, kind: String, point: Vector2) -> void:
	if not _gesture.is_empty() or not _outer.model.active_side().is_empty() \
			or id not in widgets or kind not in ["move", "resize"] or not point.is_finite(): return
	var widget: WidgetView = widgets[id]
	if not widget.is_visible_in_tree(): return
	var current: Dictionary = WidgetLayout.placement(_preferred, id)
	_gesture = {"id": id, "kind": kind, "origin": point, "point": point, "moved": false,
		"region": current["region"], "start_form": widget.effective_form, "candidate": {}, "valid": false}
	_swallow_release = false
	widget.modulate.a = 0.5
	_ghost.show()
	_preview_at(point)


func _target_region(point: Vector2) -> String:
	for region: String in WidgetLayout.REGIONS:
		var dock: WidgetDock = _docks[region]
		if dock.is_visible_in_tree() and dock.get_global_rect().has_point(point): return region
	return ""


func _preview_at(point: Vector2) -> void:
	if _gesture.is_empty(): return
	_gesture["point"] = point
	var delta: Vector2 = (point - Vector2(_gesture["origin"])) / _outer.scale.x
	_gesture["moved"] = bool(_gesture["moved"]) or delta.length() >= 5.0
	var id: String = _gesture["id"]
	var candidate: Dictionary = {}
	var region: String = _gesture["region"]
	if _gesture["kind"] == "move":
		region = _target_region(point)
		if not region.is_empty():
			var dock: WidgetDock = _docks[region]
			var local: Vector2 = dock.canvas.get_global_transform().affine_inverse() * point
			var index: int = 0
			for entry: Dictionary in WidgetLayout.in_region(_preferred, region):
				if entry["id"] == id: continue
				var rect: Rect2 = _resolved["items"][entry["id"]]["rect"]
				if WidgetLayout._axis(local, region) > WidgetLayout._axis(rect.get_center(), region): index += 1
			candidate = WidgetLayout.propose_move(_preferred, _capacities(true), id, region, index)
	else:
		var wanted: Vector2 = WidgetLayout.minimum(_gesture["start_form"], region) + delta
		var nearest: String = "compact"
		var distance: float = INF
		for form: String in WidgetLayout.FORMS:
			var measured: float = wanted.distance_squared_to(WidgetLayout.minimum(form, region))
			if measured < distance:
				distance = measured
				nearest = form
		candidate = WidgetLayout.propose_form(_preferred, _capacities(true), id, nearest)
	_gesture["candidate"] = candidate
	_gesture["valid"] = not candidate.is_empty()
	for dock: WidgetDock in _docks.values(): dock.clear_preview()
	var caption: String = "Not a valid widget region" if region.is_empty() else "Does not fit · expand rail"
	if not candidate.is_empty():
		var resolved: Dictionary = WidgetLayout.solve(candidate, _capacities())
		for dock: WidgetDock in _docks.values(): dock.show_preview(resolved, id)
		caption = "%s · %s" % [region.capitalize(), resolved["items"][id]["form"]]
	var style: StyleBoxFlat = OsTokens.box(Color("26302f"), 0)
	style.border_color = OsTokens.ACCENT if not candidate.is_empty() else OsTokens.ERROR
	style.set_border_width_all(2)
	_ghost.add_theme_stylebox_override("panel", style)
	_ghost_label.text = "%s\n%s" % [WidgetLayout.TITLES[id], caption]
	_ghost.position = (point + Vector2(18, 18)).clamp(Vector2.ZERO, (_shell.size - _ghost.size).max(Vector2.ZERO))


func cancel_manipulation() -> void:
	if _gesture.is_empty(): return
	_swallow_release = true
	_finish_visuals()


func _finish_visuals() -> void:
	for widget: WidgetView in widgets.values(): widget.modulate.a = 1.0
	for dock: WidgetDock in _docks.values(): dock.clear_preview()
	if is_instance_valid(_ghost): _ghost.hide()
	_gesture.clear()


func _input(event: InputEvent) -> void:
	if _swallow_release and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_swallow_release = false
		if not event.pressed:
			get_viewport().set_input_as_handled()
			return
	if _gesture.is_empty(): return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE: cancel_manipulation()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		_preview_at(event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_preview_at(event.position)
			var candidate: Dictionary = _gesture["candidate"].duplicate(true)
			var moved: bool = _gesture["moved"]
			_finish_visuals()
			if moved: _accept(candidate)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_manipulation()
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var region: String = _target_region(event.position)
			if not region.is_empty():
				var dock: WidgetDock = _docks[region]
				dock.scroll_vertical += 40 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -40
				_preview_at(event.position)
		get_viewport().set_input_as_handled()


func _key_action(id: String, kind: String, direction: int, transfer: bool) -> void:
	var entry: Dictionary = WidgetLayout.placement(_preferred, id)
	if entry.is_empty(): return
	if transfer:
		move_widget(id, "right" if entry["region"] == "bottom" else "bottom", 99)
	elif kind == "move":
		move_widget(id, entry["region"], int(entry["order"]) + direction)
	else:
		var form_index: int = WidgetLayout.FORMS.find((widgets[id] as WidgetView).effective_form)
		resize_widget(id, WidgetLayout.FORMS[clampi(form_index + direction, 0, WidgetLayout.FORMS.size() - 1)])


func _option_action(id: String, option: int) -> void:
	var current: Dictionary = WidgetLayout.placement(_preferred, id)
	if option == 0 or option == 1: move_widget(id, "bottom" if option == 0 else "right", 99)
	elif option == 2 or option == 3: move_widget(id, current["region"], int(current["order"]) + (-1 if option == 2 else 1))
	elif option >= 10 and option < 14: resize_widget(id, WidgetLayout.FORMS[option - 10])


func _update_menu(id: String) -> void:
	var popup: PopupMenu = (widgets[id] as WidgetView).menu_button.get_popup()
	var current: Dictionary = WidgetLayout.placement(_preferred, id)
	for index: int in range(2):
		var region: String = "bottom" if index == 0 else "right"
		popup.set_item_disabled(popup.get_item_index(index), WidgetLayout.propose_move(_preferred, _capacities(true), id, region, 99).is_empty())
	popup.set_item_disabled(popup.get_item_index(2), int(current["order"]) == 0)
	popup.set_item_disabled(popup.get_item_index(3), int(current["order"]) >= WidgetLayout.in_region(_preferred, current["region"]).size() - 1)
	for index: int in range(4):
		popup.set_item_disabled(popup.get_item_index(10 + index), WidgetLayout.propose_form(_preferred, _capacities(true), id, WidgetLayout.FORMS[index]).is_empty())


func _exit_tree() -> void:
	if is_instance_valid(get_window()) and get_window().focus_exited.is_connected(cancel_manipulation):
		get_window().focus_exited.disconnect(cancel_manipulation)
