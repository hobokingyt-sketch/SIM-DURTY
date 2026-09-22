class_name OsTokens
extends RefCounted

# Phase 6D.1: locked charcoal material hierarchy.
const CHASSIS: Color = Color("111416")
const BACKGROUND: Color = CHASSIS
const SURFACE: Color = Color("23282b")
const RAIL_SURFACE: Color = Color("202427")
const APP_WELL: Color = Color("191d1f")
const CONTEXT_WELL: Color = Color("1b1f21")
const WORKBENCH_WELL: Color = Color("1a1e20")
const WIDGET_SURFACE: Color = Color("202528")
const WELL: Color = Color("1b1f21")
const RAISED: Color = Color("2a3033")
const RAISED_HOVER: Color = Color("333a3e")
const RAISED_PRESSED: Color = Color("22272a")
const DISABLED: Color = Color("202427")
const EDGE_HIGHLIGHT: Color = Color("474e51")
const EDGE_MID: Color = Color("30363a")
const EDGE_SHADOW: Color = Color("0a0c0d")
const TEXT: Color = Color("e7e6e1")
const MUTED: Color = Color("a9afb1")
const ACCENT: Color = Color("c59d57")
const ACCENT_RECESS: Color = Color("55462f")
const ERROR: Color = Color("d4927b")

# 6D.4: one spacing rhythm for product surfaces. All values sit on the 4 px
# baseline; callers choose density by role instead of inventing local gaps.
const SPACE_XXS: int = 4
const SPACE_XS: int = 8
const SPACE_SM: int = 12
const SPACE_MD: int = 16
const SPACE_LG: int = 24
const SPACE_XL: int = 32
const GAP: int = SPACE_MD


static func frame_palette() -> Dictionary:
	return {
		"shadow": EDGE_SHADOW,
		"middle": EDGE_MID,
		"highlight": EDGE_HIGHLIGHT,
	}


static func control_palette() -> Dictionary:
	return {
		"shadow": EDGE_SHADOW,
		"middle": EDGE_MID,
		"highlight": EDGE_HIGHLIGHT,
		"text": TEXT,
		"muted": MUTED,
		"icon": Color("c7cecc"),
		"accent": ACCENT,
		"accent_dark": ACCENT.darkened(0.25),
		"accent_light": ACCENT.lightened(0.12),
		"accent_text": Color("d9b66c"),
		"well": WELL,
		"disabled": DISABLED,
		"control_housing": Color("171b1d"),
		"control_face": Color("292f32"),
		"control_face_hover": Color("31383b"),
		"control_face_pressed": Color("202528"),
		"disabled_face": Color("202427"),
		"selected_face": Color("2a2821"),
		"selected_face_hover": Color("302d24"),
		"primary_face": Color("3a3124"),
		"primary_face_hover": Color("433829"),
		"primary_face_pressed": Color("2b251d"),
		"handle_face": Color("202427"),
		"handle_face_hover": Color("292f32"),
		"fold_face": Color("1d2123"),
		"fold_face_hover": Color("282e31"),
	}


static func box(color: Color, padding: int = 12) -> StyleBoxFlat:
	var result: StyleBoxFlat = StyleBoxFlat.new()
	result.bg_color = color
	result.set_corner_radius_all(3)
	result.content_margin_left = padding
	result.content_margin_right = padding
	result.content_margin_top = padding
	result.content_margin_bottom = padding
	return result


static func make_theme() -> Theme:
	var result: Theme = Theme.new()
	result.default_font_size = OsTypography.font_size(OsTypography.ROLE_BODY)
	result.set_color("font_color", "Label", TEXT)
	for name: String in ["font_color", "font_hover_color", "font_pressed_color"]:
		result.set_color(name, "Button", TEXT)
	result.set_color("font_disabled_color", "Button", MUTED.darkened(0.35))
	result.set_stylebox("panel", "PanelContainer", box(SURFACE))
	OsControls.install_default_theme(result, control_palette())
	var hline: StyleBoxLine = StyleBoxLine.new()
	hline.color = EDGE_MID
	hline.thickness = 1
	result.set_stylebox("separator", "HSeparator", hline)
	var vline: StyleBoxLine = StyleBoxLine.new()
	vline.color = EDGE_MID
	vline.thickness = 1
	vline.vertical = true
	result.set_stylebox("separator", "VSeparator", vline)
	result.set_constant("separation", "VBoxContainer", GAP)
	result.set_constant("separation", "HBoxContainer", GAP)
	return result


static func spacing_contract() -> Dictionary:
	return {
		"xxs": SPACE_XXS,
		"xs": SPACE_XS,
		"sm": SPACE_SM,
		"md": SPACE_MD,
		"lg": SPACE_LG,
		"xl": SPACE_XL,
	}


static func type_label(parent: Node, text: String, role: String, color: Color = TEXT) -> Label:
	var node: Label = Label.new()
	node.text = text
	OsTypography.apply(node, role, color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node


static func type_wrapped(parent: Node, text: String, role: String = OsTypography.ROLE_BODY, color: Color = MUTED) -> Label:
	var node: Label = type_label(parent, text, role, color)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node


static func label(parent: Node, text: String, font_size: int = 18, color: Color = TEXT) -> Label:
	var node: Label = Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node


static func wrapped(parent: Node, text: String, font_size: int = 18, color: Color = MUTED) -> Label:
	var node: Label = label(parent, text, font_size, color)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node


static func button(parent: Node, text: String, action: Callable) -> Button:
	var node: Button = Button.new()
	node.text = text
	OsControls.apply(node, OsControls.ROLE_STANDARD, control_palette())
	parent.add_child(node)
	if action.is_valid():
		node.pressed.connect(action)
	return node


static func column(parent: Node, gap: int = GAP) -> VBoxContainer:
	var node: VBoxContainer = VBoxContainer.new()
	node.add_theme_constant_override("separation", gap)
	parent.add_child(node)
	return node


static func row(parent: Node, gap: int = GAP) -> HBoxContainer:
	var node: HBoxContainer = HBoxContainer.new()
	node.add_theme_constant_override("separation", gap)
	parent.add_child(node)
	return node


static func spacer(parent: Node) -> Control:
	var node: Control = Control.new()
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(node)
	return node
