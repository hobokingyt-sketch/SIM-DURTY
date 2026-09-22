class_name OsControls
extends RefCounted

const ROLE_STANDARD: String = "standard"
const ROLE_PRIMARY: String = "primary"
const ROLE_TAB: String = "tab"
const ROLE_LAUNCHER: String = "launcher"
const ROLE_NAV: String = "nav"
const ROLE_COMPACT: String = "compact"
const ROLE_HANDLE: String = "handle"
const ROLE_FOLD: String = "fold"

const STATES: PackedStringArray = ["normal", "hover", "pressed", "hover_pressed", "disabled"]


static func apply(button: Button, role: String, palette: Dictionary, height_override: float = -1.0, padding_override: int = -1, join: String = OsControlSurface.JOIN_SINGLE) -> void:
	button.set_meta("os_control_role", role)
	button.set_meta("os_control_join", join)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.mouse_force_pass_scroll_events = false
	button.flat = false
	button.add_theme_font_size_override("font_size", OsTypography.button_font_size(role))
	var metrics: Dictionary = _metrics(role)
	button.custom_minimum_size.y = height_override if height_override > 0.0 else float(metrics["height"])
	if role == ROLE_LAUNCHER:
		button.custom_minimum_size.x = maxf(button.custom_minimum_size.x, 44.0)
	for state: String in STATES:
		button.add_theme_stylebox_override(state, style_for(role, state, palette, padding_override, join))
	button.add_theme_stylebox_override("focus", focus_style(role, palette, join))
	var text_normal: Color = palette["text"]
	var text_selected: Color = palette["accent_text"] if role in [ROLE_TAB, ROLE_LAUNCHER] else palette["text"]
	button.add_theme_color_override("font_color", text_normal)
	button.add_theme_color_override("font_hover_color", text_normal)
	button.add_theme_color_override("font_pressed_color", text_selected)
	button.add_theme_color_override("font_hover_pressed_color", text_selected)
	button.add_theme_color_override("font_disabled_color", palette["muted"].darkened(0.25))
	for state_name: String in ["icon_normal_color", "icon_hover_color"]:
		button.add_theme_color_override(state_name, palette["icon"])
	for state_name: String in ["icon_pressed_color", "icon_hover_pressed_color", "icon_focus_color"]:
		button.add_theme_color_override(state_name, palette["accent_text"])
	button.add_theme_color_override("icon_disabled_color", palette["muted"].darkened(0.2))


static func install_default_theme(theme: Theme, palette: Dictionary) -> void:
	for state: String in STATES:
		theme.set_stylebox(state, "Button", style_for(ROLE_STANDARD, state, palette))
	theme.set_stylebox("focus", "Button", focus_style(ROLE_STANDARD, palette))
	theme.set_color("font_color", "Button", palette["text"])
	theme.set_color("font_hover_color", "Button", palette["text"])
	theme.set_color("font_pressed_color", "Button", palette["text"])
	theme.set_color("font_hover_pressed_color", "Button", palette["text"])
	theme.set_color("font_disabled_color", "Button", palette["muted"].darkened(0.25))


static func style_for(role: String, state: String, palette: Dictionary, padding_override: int = -1, join: String = OsControlSurface.JOIN_SINGLE) -> StyleBoxTexture:
	var padding: int = padding_override if padding_override >= 0 else int(_metrics(role)["padding"])
	return OsControlSurface.style(role, state, palette, padding, join)


static func focus_style(role: String, palette: Dictionary, join: String = OsControlSurface.JOIN_SINGLE) -> StyleBoxTexture:
	return OsControlSurface.focus_style(role, palette, join)


static func set_selected(button: Button, selected: bool) -> void:
	if not button.toggle_mode:
		button.toggle_mode = true
	button.set_pressed_no_signal(selected)


static func set_icon(button: Button, kind: String, max_width: int = 18) -> void:
	button.set_meta("os_icon_kind", kind)
	button.icon = WorkspaceIcons.texture(kind)
	button.expand_icon = true
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER if button.text.is_empty() else HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_constant_override("h_separation", 0 if button.text.is_empty() else 6)
	button.add_theme_constant_override("icon_max_width", WorkspaceIcons.optical_width(kind, max_width))


static func role_of(button: Button) -> String:
	return str(button.get_meta("os_control_role", ""))


static func join_of(button: Button) -> String:
	return str(button.get_meta("os_control_join", OsControlSurface.JOIN_SINGLE))


static func contract() -> Dictionary:
	var result: Dictionary = {}
	for role: String in [ROLE_STANDARD, ROLE_PRIMARY, ROLE_TAB, ROLE_LAUNCHER, ROLE_NAV, ROLE_COMPACT, ROLE_HANDLE, ROLE_FOLD]:
		result[role] = _metrics(role)
	return result


static func _metrics(role: String) -> Dictionary:
	match role:
		ROLE_PRIMARY:
			return {"height": 38, "padding": 3}
		ROLE_LAUNCHER:
			return {"height": 44, "padding": 3}
		ROLE_TAB:
			return {"height": 34, "padding": 3}
		ROLE_NAV:
			return {"height": 34, "padding": 3}
		ROLE_COMPACT:
			return {"height": 28, "padding": 5}
		ROLE_HANDLE:
			return {"height": 28, "padding": 5}
		ROLE_FOLD:
			return {"height": 30, "padding": 3}
	return {"height": 38, "padding": 3}


