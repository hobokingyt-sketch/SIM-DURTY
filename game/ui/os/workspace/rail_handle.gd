class_name RailHandle
extends Control

signal resize_started(side: String, viewport_position: Vector2)
signal step_requested(side: String, delta: int)
signal fold_requested(side: String)
var side: String = "left"
var _hovered: bool = false


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_force_pass_scroll_events = false
	mouse_default_cursor_shape = Control.CURSOR_HSIZE if side in ["left", "right"] else Control.CURSOR_VSIZE
	tooltip_text = "%s rail: drag to resize; arrows step 20; Enter folds; Escape cancels." % side.capitalize()
	mouse_entered.connect(func() -> void: _hovered = true; queue_redraw())
	mouse_exited.connect(func() -> void: _hovered = false; queue_redraw())
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			grab_focus()
			if mouse.double_click:
				fold_requested.emit(side)
			else:
				resize_started.emit(side, get_global_transform() * mouse.position)
		accept_event()
	elif event is InputEventKey and event.pressed:
		var key: InputEventKey = event
		var direction: int = 0
		if side in ["left", "right"] and key.keycode in [KEY_LEFT, KEY_RIGHT]:
			direction = 1 if key.keycode == KEY_RIGHT else -1
		elif side in ["top", "bottom"] and key.keycode in [KEY_UP, KEY_DOWN]:
			direction = 1 if key.keycode == KEY_DOWN else -1
		if direction != 0:
			step_requested.emit(side, direction * (-1 if side in ["right", "bottom"] else 1) * WorkspaceLayout.STEP)
			accept_event()
		elif key.keycode in [KEY_ENTER, KEY_KP_ENTER] and not key.echo:
			fold_requested.emit(side)
			accept_event()


func _draw() -> void:
	var active: bool = _hovered or has_focus()
	var color: Color = OsTokens.ACCENT if active else Color("3c454b")
	draw_rect(Rect2(Vector2.ZERO, size), Color("151a1e"))
	if side in ["left", "right"]:
		draw_line(Vector2(size.x * 0.5, size.y * 0.5 - 24), Vector2(size.x * 0.5, size.y * 0.5 + 24), color, 2)
	else:
		draw_line(Vector2(size.x * 0.5 - 24, size.y * 0.5), Vector2(size.x * 0.5 + 24, size.y * 0.5), color, 2)
	if has_focus():
		draw_rect(Rect2(Vector2.ZERO, size).grow(-1), OsTokens.ACCENT, false, 1)
