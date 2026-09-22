class_name WidgetHandle
extends Button

signal manipulation_requested(id: String, kind: String, point: Vector2)
signal key_requested(id: String, kind: String, direction: int, transfer: bool)
var widget_id: String
var kind: String = "move"


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_force_pass_scroll_events = false
	mouse_default_cursor_shape = Control.CURSOR_MOVE if kind == "move" else Control.CURSOR_FDIAGSIZE
	text = ""
	OsControls.set_icon(self, "move" if kind == "move" else "resize", 16)
	tooltip_text = "Move widget. Arrows reorder; Enter changes rail." if kind == "move" else "Resize widget. Arrows choose form."
	accessibility_name = str(WidgetLayout.TITLES.get(widget_id, widget_id)) + ": " + tooltip_text


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		grab_focus()
		manipulation_requested.emit(widget_id, kind, get_global_transform() * event.position)
		accept_event()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_LEFT, KEY_UP, KEY_RIGHT, KEY_DOWN]:
			key_requested.emit(widget_id, kind, -1 if event.keycode in [KEY_LEFT, KEY_UP] else 1, false)
			accept_event()
		elif event.keycode in [KEY_ENTER, KEY_KP_ENTER] and kind == "move":
			key_requested.emit(widget_id, kind, 0, true)
			accept_event()
