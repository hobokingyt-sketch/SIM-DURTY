class_name OsTokens
extends RefCounted

# Phase 6D.1: locked charcoal material hierarchy.
const CHASSIS: Color = Color("111315")
const BACKGROUND: Color = CHASSIS
const SURFACE: Color = Color("1b1f21")
const WELL: Color = Color("15181a")
const RAISED: Color = Color("272c2f")
const RAISED_HOVER: Color = Color("30363a")
const RAISED_PRESSED: Color = Color("202427")
const DISABLED: Color = Color("1a1d1f")
const EDGE_HIGHLIGHT: Color = Color("485055")
const EDGE_MID: Color = Color("30373b")
const EDGE_SHADOW: Color = Color("080a0b")
const TEXT: Color = Color("ecebe6")
const MUTED: Color = Color("a8adaf")
const ACCENT: Color = Color("cba45e")
const ACCENT_RECESS: Color = Color("5b4930")
const ERROR: Color = Color("d4927b")
const GAP: int = 20


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
		"icon": Color("d8ddda"),
		"accent": ACCENT,
		"accent_dark": ACCENT.darkened(0.28),
		"accent_light": ACCENT.lightened(0.16),
		"accent_text": Color("e4c47f"),
		"well": WELL,
		"raised": RAISED,
		"raised_hover": RAISED_HOVER,
		"raised_pressed": RAISED_PRESSED,
		"disabled": DISABLED,
		"selected": ACCENT_RECESS.darkened(0.16),
		"selected_hover": ACCENT_RECESS.lightened(0.02),
		"primary": ACCENT_RECESS,
		"primary_hover": ACCENT_RECESS.lightened(0.08),
		"primary_pressed": ACCENT_RECESS.darkened(0.13),
		"handle": WELL.lightened(0.035),
		"handle_hover": RAISED,
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
	result.default_font_size = 18
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
