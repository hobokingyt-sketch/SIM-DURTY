class_name OsFrameOverlay
extends Control

var _role: String = OsFrames.ROLE_WIDGET
var _palette: Dictionary = {}
var _full_frame: bool = false


func setup(role: String, palette: Dictionary, full_frame: bool) -> void:
	_role = role
	_palette = palette.duplicate()
	_full_frame = full_frame
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	z_index = 90
	set_process(false)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 8.0 or size.y < 8.0 or _palette.is_empty():
		return
	var definition: Dictionary = OsFrames.spec(_role)
	var chamfer: float = float(definition["chamfer"])
	var seam: float = float(definition["seam"])
	if _full_frame:
		_draw_layer(1.0, chamfer, _palette["shadow"], 2.0)
		_draw_layer(3.5, maxf(1.0, chamfer - 2.0), _palette["middle"], 1.0)
		var highlight: Color = _palette["highlight"]
		highlight.a = 0.72
		_draw_layer(6.0, maxf(1.0, chamfer - 4.0), highlight, 1.0)
	if seam <= 0.0:
		return
	var center: float = size.x * 0.5
	var half: float = minf(seam * 0.5, maxf(0.0, size.x * 0.18))
	if half <= 2.0:
		return
	var hi: Color = _palette["highlight"]
	hi.a = 0.62
	var shadow: Color = _palette["shadow"]
	shadow.a = 0.92
	draw_line(Vector2(center - half, 3.0), Vector2(center + half, 3.0), hi, 1.0)
	draw_line(Vector2(center - half, size.y - 3.0), Vector2(center + half, size.y - 3.0), shadow, 1.0)


func _draw_layer(inset: float, chamfer: float, color: Color, width: float) -> void:
	var points: PackedVector2Array = OsFrames.chamfer_points(size, chamfer, inset)
	if points.size() >= 2:
		draw_polyline(points, color, width, true)
