class_name WorkspaceIcons
extends RefCounted

# Small functional launcher symbols. SVG is limited to iconography, not widget decoration.
static var _textures: Dictionary = {}
const PATHS: Dictionary = {
	"city": '<path d="M3 21V10h5v11M9 21V3h7v18M17 21V8h4v13M1 21h22M11 7h3M11 11h3M11 15h3"/>',
	"work": '<rect x="3" y="7" width="18" height="14" rx="2"/><path d="M8 7V3h8v4M3 12h18M10 12v3h4v-3"/>',
	"layout": '<rect x="2" y="3" width="20" height="18" rx="1"/><path d="M7 3v18M17 3v18M7 7h10M7 17h10"/>',
	"rail": '<path d="M4 3v18M9 5l-4 7 4 7M13 5h8M13 12h8M13 19h8"/>',
	"save": '<path d="M3 3h15l3 3v15H3zM7 3v6h10V3M7 21v-8h10v8"/>',
	"load": '<path d="M3 8V4h7l2 3h9v14H3zM12 10v8M9 15l3 3 3-3"/>',
	"tools": '<path d="M14 4a5 5 0 0 0-6 6L2 16l6 6 6-6a5 5 0 0 0 6-6l-4 2-4-4z"/>',
	"report": '<path d="M6 3h10l4 4v14H6zM16 3v5h4M9 12h8M9 16h8M3 6v16"/>',
}


static func texture(kind: String) -> Texture2D:
	if _textures.has(kind):
		return _textures[kind]
	var svg: String = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><g fill="none" stroke="#c9d1cf" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">%s</g></svg>' % str(PATHS.get(kind, PATHS["layout"]))
	var image: Image = Image.new()
	if image.load_svg_from_string(svg, 2.0) != OK:
		return null
	var result: ImageTexture = ImageTexture.create_from_image(image)
	_textures[kind] = result
	return result
