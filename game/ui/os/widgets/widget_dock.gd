class_name WidgetDock
extends ScrollContainer

var region: String
var canvas: Control
var outlines: Dictionary = {}


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_force_pass_scroll_events = false
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas = Control.new()
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	for id: String in WidgetLayout.IDS:
		var outline: Panel = Panel.new()
		outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		outline.visible = false
		outline.z_index = 10
		canvas.add_child(outline)
		outlines[id] = outline


func capacity() -> Vector2:
	# Reserve scroll-bar space once, avoiding fit/scrollbar feedback loops.
	return (size - Vector2(14, 14)).max(Vector2.ZERO)


func clear_preview() -> void:
	for outline: Panel in outlines.values(): outline.hide()


func show_preview(result: Dictionary, moving: String) -> void:
	clear_preview()
	for id: String in result.get("items", {}):
		var item: Dictionary = result["items"][id]
		if item["region"] != region: continue
		var outline: Panel = outlines[id]
		var style: StyleBoxFlat = OsTokens.box(Color(0.7, 0.62, 0.44, 0.08), 0)
		style.border_color = OsTokens.ACCENT if id == moving else OsTokens.MUTED
		style.set_border_width_all(2 if id == moving else 1)
		outline.add_theme_stylebox_override("panel", style)
		outline.position = item["rect"].position
		outline.size = item["rect"].size
		outline.show()
