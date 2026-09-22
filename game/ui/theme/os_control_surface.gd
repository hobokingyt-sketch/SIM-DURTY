class_name OsControlSurface
extends RefCounted

const TEXTURE_SIZE: int = 44


static func style(
	role: String,
	state: String,
	palette: Dictionary,
	padding: int
) -> StyleBoxTexture:
	var definition: Dictionary = spec(role)
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = _texture(role, state, palette)
	var patch: float = float(definition["patch"])
	for side: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, patch)
		style.set_content_margin(side, float(padding))
	style.draw_center = true
	return style


static func focus_style(role: String, palette: Dictionary) -> StyleBoxTexture:
	var image: Image = Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var definition: Dictionary = spec(role)
	var chamfer: int = int(definition["chamfer"])
	for y: int in range(TEXTURE_SIZE):
		for x: int in range(TEXTURE_SIZE):
			var point: Vector2i = Vector2i(x, y)
			if not _inside(point, 0, chamfer):
				continue
			if _inside(point, 2, maxi(1, chamfer - 2)):
				continue
			var edge: Color = palette["accent"]
			if _bottom_right_side(point, 0):
				edge = palette["accent_dark"]
			elif _top_left_side(point, 0):
				edge = palette["accent_light"]
			image.set_pixel(x, y, edge)
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = ImageTexture.create_from_image(image)
	var patch: float = float(definition["patch"])
	for side: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, patch)
		style.set_content_margin(side, 0.0)
	style.draw_center = true
	return style


static func spec(role: String) -> Dictionary:
	match role:
		OsControls.ROLE_PRIMARY:
			return {"chamfer": 4, "face_inset": 4, "face_bevel": 2, "patch": 8}
		OsControls.ROLE_LAUNCHER:
			return {"chamfer": 4, "face_inset": 4, "patch": 8}
		OsControls.ROLE_TAB:
			return {"chamfer": 4, "face_inset": 3, "face_bevel": 2, "patch": 7}
		OsControls.ROLE_NAV:
			return {"chamfer": 4, "face_inset": 3, "face_bevel": 2, "patch": 7}
		OsControls.ROLE_HANDLE, OsControls.ROLE_COMPACT:
			return {"chamfer": 3, "face_inset": 3, "face_bevel": 1, "patch": 6}
		OsControls.ROLE_FOLD:
			return {"chamfer": 3, "face_inset": 3, "patch": 6}
	return {"chamfer": 4, "face_inset": 3, "patch": 7}


static func contract() -> Dictionary:
	var result: Dictionary = {}
	for role: String in [
		OsControls.ROLE_STANDARD,
		OsControls.ROLE_PRIMARY,
		OsControls.ROLE_TAB,
		OsControls.ROLE_LAUNCHER,
		OsControls.ROLE_NAV,
		OsControls.ROLE_COMPACT,
		OsControls.ROLE_HANDLE,
		OsControls.ROLE_FOLD,
	]:
		result[role] = spec(role)
	return result


static func _texture(role: String, state: String, palette: Dictionary) -> Texture2D:
	var image: Image = Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var definition: Dictionary = spec(role)
	var chamfer: int = int(definition["chamfer"])
	var face_inset: int = int(definition["face_inset"])
	var face_bevel: int = int(definition["face_bevel"])
	var face_chamfer: int = maxi(1, chamfer - 1)
	var accent_edge: bool = _uses_accent_edge(role, state)
	var pressed: bool = state in ["pressed", "hover_pressed"]
	var disabled: bool = state == "disabled"
	var housing: Color = palette["control_housing"]
	var structure: Color = palette["accent_dark"] if accent_edge else palette["middle"]
	var structure_high: Color = palette["accent"] if accent_edge else palette["highlight"]
	var face: Color = _face_color(role, state, palette)

	if disabled:
		housing = palette["disabled"].darkened(0.08)
		structure = palette["middle"].darkened(0.18)

	for y: int in range(TEXTURE_SIZE):
		for x: int in range(TEXTURE_SIZE):
			var point: Vector2i = Vector2i(x, y)
			if not _inside(point, 0, chamfer):
				continue

			var color: Color = housing
			if not _inside(point, 1, maxi(1, chamfer - 1)):
				color = palette["shadow"]
			elif not _inside(point, 2, maxi(1, chamfer - 2)):
				if _top_left_side(point, 1):
					color = structure_high
				elif _bottom_right_side(point, 1):
					color = structure.darkened(0.16)
				else:
					color = structure
			elif _inside(point, face_inset, face_chamfer):
				color = face
				if not _inside(point, face_inset + face_bevel, maxi(1, face_chamfer - face_bevel)):
					color = _face_bevel(point, face_inset, face, palette, pressed)

			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)


static func _face_color(role: String, state: String, palette: Dictionary) -> Color:
	if state == "disabled":
		return palette["disabled_face"]

	var pressed: bool = state in ["pressed", "hover_pressed"]
	var hovered: bool = state in ["hover", "hover_pressed"]

	if role == OsControls.ROLE_PRIMARY:
		if pressed:
			return palette["primary_face_pressed"]
		return palette["primary_face_hover"] if hovered else palette["primary_face"]

	if role in [OsControls.ROLE_TAB, OsControls.ROLE_LAUNCHER] and pressed:
		return palette["selected_face_hover"] if hovered else palette["selected_face"]

	if role == OsControls.ROLE_HANDLE:
		if pressed:
			return palette["control_face_pressed"]
		return palette["handle_face_hover"] if hovered else palette["handle_face"]

	if role == OsControls.ROLE_FOLD:
		if pressed:
			return palette["control_face_pressed"]
		return palette["fold_face_hover"] if hovered else palette["fold_face"]

	if pressed:
		return palette["control_face_pressed"]
	return palette["control_face_hover"] if hovered else palette["control_face"]


static func _uses_accent_edge(role: String, state: String) -> bool:
	if role == OsControls.ROLE_PRIMARY and state != "disabled":
		return true
	return role in [OsControls.ROLE_TAB, OsControls.ROLE_LAUNCHER] and state in ["pressed", "hover_pressed"]


static func _face_bevel(
	point: Vector2i,
	inset: int,
	face: Color,
	palette: Dictionary,
	pressed: bool
) -> Color:
	var high: Color = face.lerp(palette["highlight"], 0.24)
	var low: Color = face.lerp(palette["shadow"], 0.46)
	var top_left: bool = _top_left_side(point, inset)
	var bottom_right: bool = _bottom_right_side(point, inset)
	if pressed:
		var swap: bool = top_left
		top_left = bottom_right
		bottom_right = swap
	if top_left:
		return high
	if bottom_right:
		return low
	return face


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


static func _top_left_side(point: Vector2i, inset: int) -> bool:
	var low: int = inset
	var high: int = TEXTURE_SIZE - 1 - inset
	var near_top_left: int = mini(point.y - low, point.x - low)
	var near_bottom_right: int = mini(high - point.y, high - point.x)
	return near_top_left < near_bottom_right


static func _bottom_right_side(point: Vector2i, inset: int) -> bool:
	var low: int = inset
	var high: int = TEXTURE_SIZE - 1 - inset
	var near_top_left: int = mini(point.y - low, point.x - low)
	var near_bottom_right: int = mini(high - point.y, high - point.x)
	return near_bottom_right < near_top_left
