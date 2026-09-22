class_name OsTokens
extends RefCounted

# One small visual vocabulary for the native OS, not a second UI framework.
const BACKGROUND: Color = Color("11161a")
const SURFACE: Color = Color("1b2228")
const RAISED: Color = Color("252e35")
const TEXT: Color = Color("e6e8e5")
const MUTED: Color = Color("a4afb6")
const ACCENT: Color = Color("c6ac7b")
const ERROR: Color = Color("efab94")
const GAP: int = 20


static func box(color: Color, padding: int = 24) -> StyleBoxFlat:
	var result: StyleBoxFlat = StyleBoxFlat.new()
	result.bg_color = color
	result.set_corner_radius_all(8)
	result.content_margin_left = padding
	result.content_margin_right = padding
	result.content_margin_top = padding
	result.content_margin_bottom = padding
	return result


static func make_theme() -> Theme:
	var result: Theme = Theme.new()
	result.default_font_size = 24
	result.set_color("font_color", "Label", TEXT)
	result.set_color("font_color", "Button", TEXT)
	result.set_color("font_hover_color", "Button", TEXT)
	result.set_color("font_pressed_color", "Button", TEXT)
	result.set_color("font_disabled_color", "Button", MUTED.darkened(0.3))
	result.set_stylebox("panel", "PanelContainer", box(SURFACE))
	result.set_stylebox("normal", "Button", box(RAISED, 16))
	result.set_stylebox("hover", "Button", box(Color("34414a"), 16))
	result.set_stylebox("pressed", "Button", box(Color("49483c"), 16))
	result.set_stylebox("disabled", "Button", box(Color("20262b"), 16))
	var focus: StyleBoxFlat = box(Color(0, 0, 0, 0), 0)
	focus.border_color = ACCENT
	focus.set_border_width_all(2)
	result.set_stylebox("focus", "Button", focus)
	result.set_constant("separation", "VBoxContainer", GAP)
	result.set_constant("separation", "HBoxContainer", GAP)
	return result


static func label(parent: Node, text: String, font_size: int = 24, color: Color = TEXT) -> Label:
	var node: Label = Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node


static func wrapped(parent: Node, text: String, font_size: int = 24, color: Color = MUTED) -> Label:
	var node: Label = label(parent, text, font_size, color)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node


static func button(parent: Node, text: String, action: Callable) -> Button:
	var node: Button = Button.new()
	node.text = text
	node.mouse_force_pass_scroll_events = false
	node.custom_minimum_size.y = 56
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


static func card(parent: Node, padding: int = 28) -> VBoxContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", box(SURFACE, padding))
	parent.add_child(panel)
	return column(panel)


static func spacer(parent: Node) -> Control:
	var node: Control = Control.new()
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(node)
	return node
