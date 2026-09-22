class_name OsTokens
extends RefCounted

const BACKGROUND: Color = Color("111619")
const SURFACE: Color = Color("1b2226")
const RAISED: Color = Color("283135")
const TEXT: Color = Color("e5e8e4")
const MUTED: Color = Color("a2adae")
const ACCENT: Color = Color("c6ac7b")
const ERROR: Color = Color("efab94")
const GAP: int = 20


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
	result.set_color("font_disabled_color", "Button", MUTED.darkened(0.3))
	result.set_stylebox("panel", "PanelContainer", box(SURFACE))
	result.set_stylebox("normal", "Button", box(RAISED, 8))
	result.set_stylebox("hover", "Button", box(Color("344148"), 8))
	result.set_stylebox("pressed", "Button", box(Color("49483c"), 8))
	result.set_stylebox("disabled", "Button", box(Color("20262b"), 8))
	var focus: StyleBoxFlat = box(Color(0, 0, 0, 0), 0)
	focus.border_color = ACCENT
	focus.set_border_width_all(2)
	result.set_stylebox("focus", "Button", focus)
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
	node.mouse_force_pass_scroll_events = false
	node.custom_minimum_size.y = 38
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
