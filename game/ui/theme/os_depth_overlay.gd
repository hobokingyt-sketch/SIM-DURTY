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

	for step: int in range(width):
		var t: float = float(step) / maxf(1.0, float(width - 1))
		var falloff: float = (1.0 - t) * (1.0 - t)
		var dark: Color = OsTokens.EDGE_SHADOW
		dark.a = shadow_alpha * falloff
		var light: Color = OsTokens.EDGE_HIGHLIGHT
		light.a = light_alpha * falloff
		var inset: float = float(step) + 1.0
		if recessed:
			_draw_top(inset, dark)
			_draw_left(inset, dark)
			_draw_bottom(inset, light)
			_draw_right(inset, light)
		else:
			_draw_top(inset, light)
			_draw_left(inset, light)
			_draw_bottom(inset, dark)
			_draw_right(inset, dark)


func _draw_top(inset: float, color: Color) -> void:
	draw_rect(Rect2(Vector2(inset, inset), Vector2(maxf(0.0, size.x - inset * 2.0), 1.0)), color)


func _draw_bottom(inset: float, color: Color) -> void:
	draw_rect(Rect2(Vector2(inset, maxf(inset, size.y - inset - 1.0)), Vector2(maxf(0.0, size.x - inset * 2.0), 1.0)), color)


func _draw_left(inset: float, color: Color) -> void:
	draw_rect(Rect2(Vector2(inset, inset), Vector2(1.0, maxf(0.0, size.y - inset * 2.0))), color)


func _draw_right(inset: float, color: Color) -> void:
	draw_rect(Rect2(Vector2(maxf(inset, size.x - inset - 1.0), inset), Vector2(1.0, maxf(0.0, size.y - inset * 2.0))), color)
