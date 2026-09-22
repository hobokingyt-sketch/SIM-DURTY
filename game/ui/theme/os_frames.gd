class_name OsFrames
extends RefCounted

const ROLE_SHELL: String = "shell"
const ROLE_SURFACE: String = "surface"
const ROLE_APP: String = "app"
const ROLE_WIDGET: String = "widget"
const ROLE_CONTROL: String = "control"

const TEXTURE_SIZE: int = 36


static func spec(role: String) -> Dictionary:
	match role:
		ROLE_SHELL:
			return {"chamfer": 9, "outer": 2, "middle": 2, "inner": 1, "patch": 13, "seam": 36.0}
		ROLE_SURFACE:
			return {"chamfer": 7, "outer": 2, "middle": 1, "inner": 1, "patch": 11, "seam": 26.0}
		ROLE_APP:
			return {"chamfer": 8, "outer": 2, "middle": 1, "inner": 1, "patch": 12, "seam": 30.0}
		ROLE_WIDGET:
			return {"chamfer": 6, "outer": 1, "middle": 1, "inner": 1, "patch": 10, "seam": 18.0}
		ROLE_CONTROL:
			return {"chamfer": 4, "outer": 1, "middle": 1, "inner": 1, "patch": 7, "seam": 0.0}
	return spec(ROLE_WIDGET)


static func frame_style(role: String, fill: Color, padding: int, palette: Dictionary) -> StyleBoxTexture:
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = _frame_texture(role, fill, palette)
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
	overlay.setup(role, palette, full_frame)
	target.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return overlay


static func contract() -> Dictionary:
	var result: Dictionary = {}
	for role: String in [ROLE_SHELL, ROLE_SURFACE, ROLE_APP, ROLE_WIDGET, ROLE_CONTROL]:
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


static func _frame_texture(role: String, fill: Color, palette: Dictionary) -> Texture2D:
	var image: Image = Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var definition: Dictionary = spec(role)
	var outer_width: int = int(definition["outer"])
	var middle_width: int = int(definition["middle"])
	var inner_width: int = int(definition["inner"])
	var chamfer: int = int(definition["chamfer"])
	var outer_color: Color = palette["shadow"]
	var middle_color: Color = palette["middle"]
	var highlight_color: Color = fill.lerp(palette["highlight"], 0.42)
	for y: int in range(TEXTURE_SIZE):
		for x: int in range(TEXTURE_SIZE):
			var point: Vector2i = Vector2i(x, y)
			if not _inside(point, 0, chamfer):
				continue
			var color: Color = fill
			if not _inside(point, outer_width, maxi(1, chamfer - outer_width)):
				color = outer_color
			elif not _inside(point, outer_width + middle_width, maxi(1, chamfer - outer_width - middle_width)):
				color = middle_color
			elif not _inside(point, outer_width + middle_width + inner_width, maxi(1, chamfer - outer_width - middle_width - inner_width)):
				color = highlight_color
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


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
