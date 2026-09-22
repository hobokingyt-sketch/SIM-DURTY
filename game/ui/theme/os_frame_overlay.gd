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
	# R2 removes decorative seam ticks. Only the outer shell gets one structural
	# reinforcement line; all other border craft lives in the actual frame texture.
	if not _full_frame or size.x < 8.0 or size.y < 8.0 or _palette.is_empty():
		return
	var chamfer: float = float(OsFrames.spec(_role)["chamfer"])
	var outer: Color = _palette["shadow"]
	outer.a = 0.82
	var points: PackedVector2Array = OsFrames.chamfer_points(size, chamfer, 1.0)
	if points.size() >= 2:
		draw_polyline(points, outer, 1.0, true)
