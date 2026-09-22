class_name WorkspaceIcons
extends RefCounted

# One outlined icon family for launchers and compact OS controls.
static var _textures: Dictionary = {}
const STROKE_WIDTH: float = 1.8
# Optical caps compensate for sparse small glyphs without changing the shared
# 24x24 drawing grid. Large launcher symbols retain their requested size.
const OPTICAL_MAX: Dictionary = {
	"back": 16,
	"fold_left": 15,
	"fold_right": 15,
	"fold_up": 15,
	"fold_down": 15,
	"zoom_in": 16,
	"zoom_out": 16,
	"reset": 16,
	"move": 15,
	"resize": 16,
	"menu": 14,
}
const PATHS: Dictionary = {
	"city": '<path d="M3 21V10h5v11M9 21V3h7v18M17 21V8h4v13M1 21h22M11 7h3M11 11h3M11 15h3"/>',
	"work": '<rect x="3" y="7" width="18" height="14" rx="1"/><path d="M8 7V3h8v4M3 12h18M10 12v3h4v-3"/>',
	"layout": '<rect x="2" y="3" width="20" height="18" rx="1"/><path d="M7 3v18M17 3v18M7 7h10M7 17h10"/>',
	"rail": '<path d="M4 3v18M9 5l-4 7 4 7M13 5h8M13 12h8M13 19h8"/>',
	"save": '<path d="M3 3h15l3 3v15H3zM7 3v6h10V3M7 21v-8h10v8"/>',
	"load": '<path d="M3 8V4h7l2 3h9v14H3zM12 10v8M9 15l3 3 3-3"/>',
	"tools": '<path d="M14 4a5 5 0 0 0-6 6L2 16l6 6 6-6a5 5 0 0 0 6-6l-4 2-4-4z"/>',
	"report": '<path d="M6 3h10l4 4v14H6zM16 3v5h4M9 12h8M9 16h8M3 6v16"/>',
	"back": '<path d="M19 12H5M11 6l-6 6 6 6"/>',
	"fold_left": '<path d="M15 5l-7 7 7 7"/>',
	"fold_right": '<path d="M9 5l7 7-7 7"/>',
	"fold_up": '<path d="M5 15l7-7 7 7"/>',
	"fold_down": '<path d="M5 9l7 7 7-7"/>',
	"zoom_in": '<circle cx="10" cy="10" r="6"/><path d="M14.5 14.5L21 21M10 7v6M7 10h6"/>',
	"zoom_out": '<circle cx="10" cy="10" r="6"/><path d="M14.5 14.5L21 21M7 10h6"/>',
	"reset": '<path d="M5 7V3M5 3h4M5 3a9 9 0 1 1-2 10"/>',
	"move": '<path d="M12 3v18M3 12h18M12 3l-3 3M12 3l3 3M12 21l-3-3M12 21l3-3M3 12l3-3M3 12l3 3M21 12l-3-3M21 12l-3 3"/>',
	"resize": '<path d="M5 19L19 5M11 19h8v-8M5 13v6h6"/>',
	"menu": '<path d="M5 12h.01M12 12h.01M19 12h.01"/>',
}


static func texture(kind: String) -> Texture2D:
	if _textures.has(kind):
		return _textures[kind]
	var svg: String = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><g fill="none" stroke="#d8ddda" stroke-width="%.1f" stroke-linecap="round" stroke-linejoin="round">%s</g></svg>' % [STROKE_WIDTH, str(PATHS.get(kind, PATHS["layout"]))]
	var image: Image = Image.new()
	if image.load_svg_from_string(svg, 2.0) != OK:
		return null
	var result: ImageTexture = ImageTexture.create_from_image(image)
	_textures[kind] = result
	return result


static func optical_width(kind: String, requested: int) -> int:
	return mini(requested, int(OPTICAL_MAX.get(kind, requested)))


static func contract() -> Dictionary:
	return {
		"stroke_width": STROKE_WIDTH,
		"kinds": PATHS.keys(),
		"optical_max": OPTICAL_MAX.duplicate(),
	}
