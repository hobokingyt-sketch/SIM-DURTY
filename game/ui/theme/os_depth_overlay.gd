class_name OsDepthOverlay
extends Control

var _role: String = OsDepth.ROLE_RAIL


func setup(role: String) -> void:
	_role = role
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	set_process(false)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 12.0 or size.y < 12.0:
		return
	var definition: Dictionary = OsDepth.spec(_role)
	var width: int = int(definition["width"])
	var shadow_alpha: float = float(definition["shadow"])
	var light_alpha: float = float(definition["light"])
	var recessed: bool = str(definition["mode"]) == "recessed"
	var frame_role: String = OsDepth.frame_role(_role)
	var chamfer: float = float(OsFrames.spec(frame_role)["chamfer"])

	for step: int in range(width):
		var t: float = float(step) / maxf(1.0, float(width - 1))
		var falloff: float = (1.0 - t) * (1.0 - t)
		var dark: Color = OsTokens.EDGE_SHADOW
		dark.a = shadow_alpha * falloff
		var light: Color = OsTokens.EDGE_HIGHLIGHT
		light.a = light_alpha * falloff
		var inset: float = float(step) + 1.0
		var points: PackedVector2Array = OsFrames.chamfer_points(
			size,
			maxf(1.0, chamfer - float(step)),
			inset
		)
		if points.size() < 9:
			continue
		if recessed:
			_draw_path_segments(points, dark, light)
		else:
			_draw_path_segments(points, light, dark)


func _draw_path_segments(points: PackedVector2Array, top_left: Color, bottom_right: Color) -> void:
	# top, top-right diagonal, right, bottom-right diagonal, bottom,
	# bottom-left diagonal, left, top-left diagonal.
	var light_segments: PackedInt32Array = PackedInt32Array([0, 7])
	var dark_segments: PackedInt32Array = PackedInt32Array([2, 3, 4])
	var mid_light: Color = top_left
	mid_light.a *= 0.65
	var mid_dark: Color = bottom_right
	mid_dark.a *= 0.65

	for index: int in light_segments:
		draw_line(points[index], points[index + 1], top_left, 1.0)
	draw_line(points[1], points[2], mid_light, 1.0)
	for index: int in dark_segments:
		draw_line(points[index], points[index + 1], bottom_right, 1.0)
	draw_line(points[5], points[6], mid_dark, 1.0)
	draw_line(points[6], points[7], top_left, 1.0)
