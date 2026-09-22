class_name OsFrames
extends RefCounted

const ROLE_SHELL: String = "shell"
const ROLE_SURFACE: String = "surface"
const ROLE_APP: String = "app"
const ROLE_INSET: String = "inset"
const ROLE_WIDGET: String = "widget"
const ROLE_CONTROL: String = "control"

const EDGE_RAISED: String = "raised"
const EDGE_RECESSED: String = "recessed"
const EDGE_NEUTRAL: String = "neutral"

const TEXTURE_SIZE: int = 44


static func spec(role: String) -> Dictionary:
	match role:
		ROLE_SHELL:
			return {"chamfer": 10, "outer": 2, "structure": 2, "bevel": 2, "patch": 15}
		ROLE_SURFACE:
			return {"chamfer": 8, "outer": 1, "structure": 2, "bevel": 1, "patch": 12}
		ROLE_APP:
			return {"chamfer": 8, "outer": 1, "structure": 2, "bevel": 2, "patch": 13}
		ROLE_INSET:
			return {"chamfer": 6, "outer": 1, "structure": 1, "bevel": 2, "patch": 10}
		ROLE_WIDGET:
			return {"chamfer": 6, "outer": 1, "structure": 1, "bevel": 1, "patch": 9}
		ROLE_CONTROL:
			return {"chamfer": 4, "outer": 1, "structure": 1, "bevel": 1, "patch": 6}
	return spec(ROLE_WIDGET)


static func frame_style(
	role: String,
	fill: Color,
	padding: int,
	palette: Dictionary,
	edge_mode: String = EDGE_RAISED
) -> StyleBoxTexture:
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = _frame_texture(role, fill, palette, edge_mode)
	var patch: float = float(spec(role)["patch"])
	for side: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, patch)
		style.set_content_margin(side, float(padding))
	style.draw_center = true
	return style


static func attach_overlay(target: Control, role: String, palette: Dictionary, full_frame: bool = false) -> OsFrameOverlay:
	for child: Node in target.get_children():
		if child is OsFrameOverlay and str(child.get_meta("os_frame_role", "")) == role:
			return child as OsFrameOverlay
	var overlay: OsFrameOverlay = OsFrameOverlay.new()
	overlay.name = "EngineeredFrame_" + role.capitalize()
	overlay.set_meta("os_frame_role", role)
	overlay.setup(role, palette, full_frame)
	target.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return overlay


static func contract() -> Dictionary:
	var result: Dictionary = {}
	for role: String in [ROLE_SHELL, ROLE_SURFACE, ROLE_APP, ROLE_INSET, ROLE_WIDGET, ROLE_CONTROL]:
		result[role] = spec(role)
	return result


static func chamfer_points(size: Vector2, chamfer: float, inset: float = 0.0) -> PackedVector2Array:
	var max_x: float = maxf(inset, size.x - inset)
	var max_y: float = maxf(inset, size.y - inset)
	var usable: float = minf(max_x - inset, max_y - inset)
	var cut: float = clampf(chamfer, 0.0, maxf(0.0, usable * 0.5 - 0.5))
	return PackedVector2Array([
		Vector2(inset + cut, inset),
		Vector2(max_x - cut, inset),
		Vector2(max_x, inset + cut),
		Vector2(max_x, max_y - cut),
		Vector2(max_x - cut, max_y),
		Vector2(inset + cut, max_y),
		Vector2(inset, max_y - cut),
		Vector2(inset, inset + cut),
		Vector2(inset + cut, inset),
	])


static func _frame_texture(role: String, fill: Color, palette: Dictionary, edge_mode: String) -> Texture2D:
	var image: Image = Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var definition: Dictionary = spec(role)
	var outer_width: int = int(definition["outer"])
	var structure_width: int = int(definition["structure"])
	var bevel_width: int = int(definition["bevel"])
	var chamfer: int = int(definition["chamfer"])
	var structure_inset: int = outer_width
	var bevel_inset: int = outer_width + structure_width
	var fill_inset: int = bevel_inset + bevel_width

	for y: int in range(TEXTURE_SIZE):
		for x: int in range(TEXTURE_SIZE):
			var point: Vector2i = Vector2i(x, y)
			if not _inside(point, 0, chamfer):
				continue

			var color: Color = fill
			if not _inside(point, outer_width, maxi(1, chamfer - outer_width)):
				color = palette["shadow"]
			elif not _inside(point, bevel_inset, maxi(1, chamfer - bevel_inset)):
				color = _directional_edge_color(point, structure_inset, fill, palette, edge_mode, false)
			elif not _inside(point, fill_inset, maxi(1, chamfer - fill_inset)):
				color = _directional_edge_color(point, bevel_inset, fill, palette, edge_mode, true)
			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)


static func _directional_edge_color(
	point: Vector2i,
	inset: int,
	fill: Color,
	palette: Dictionary,
	edge_mode: String,
	inner_bevel: bool
) -> Color:
	if edge_mode == EDGE_NEUTRAL:
		return fill.lerp(palette["middle"], 0.55 if inner_bevel else 0.8)

	var high: Color = fill.lerp(palette["highlight"], 0.34 if inner_bevel else 0.44)
	var low: Color = fill.lerp(palette["shadow"], 0.46 if inner_bevel else 0.62)
	var neutral: Color = fill.lerp(palette["middle"], 0.68)

	var high_side: bool = _top_left_side(point, inset)
	var low_side: bool = _bottom_right_side(point, inset)
	if edge_mode == EDGE_RECESSED:
		var swap: bool = high_side
		high_side = low_side
		low_side = swap

	if high_side:
		return high
	if low_side:
		return low
	return neutral


static func _top_left_side(point: Vector2i, inset: int) -> bool:
	var low: int = inset
	var top_distance: int = point.y - low
	var left_distance: int = point.x - low
	var high: int = TEXTURE_SIZE - 1 - inset
	var bottom_distance: int = high - point.y
	var right_distance: int = high - point.x
	return mini(top_distance, left_distance) < mini(bottom_distance, right_distance)


static func _bottom_right_side(point: Vector2i, inset: int) -> bool:
	var low: int = inset
	var top_distance: int = point.y - low
	var left_distance: int = point.x - low
	var high: int = TEXTURE_SIZE - 1 - inset
	var bottom_distance: int = high - point.y
	var right_distance: int = high - point.x
	return mini(bottom_distance, right_distance) < mini(top_distance, left_distance)


static func _inside(point: Vector2i, inset: int, chamfer: int) -> bool:
	var low: int = inset
	var high: int = TEXTURE_SIZE - 1 - inset
	if point.x < low or point.y < low or point.x > high or point.y > high:
		return false
	var left: int = point.x - low
	var right: int = high - point.x
	var top: int = point.y - low
	var bottom: int = high - point.y
	if left < chamfer and top < chamfer and left + top < chamfer:
		return false
	if right < chamfer and top < chamfer and right + top < chamfer:
		return false
	if left < chamfer and bottom < chamfer and left + bottom < chamfer:
		return false
	if right < chamfer and bottom < chamfer and right + bottom < chamfer:
		return false
	return true
