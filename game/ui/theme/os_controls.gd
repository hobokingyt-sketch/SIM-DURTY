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


static func apply(button: Button, role: String, palette: Dictionary, height_override: float = -1.0) -> void:
	button.set_meta("os_control_role", role)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.mouse_force_pass_scroll_events = false
	button.flat = false
	var metrics: Dictionary = _metrics(role)
	button.custom_minimum_size.y = height_override if height_override > 0.0 else float(metrics["height"])
	if role == ROLE_LAUNCHER:
		button.custom_minimum_size.x = maxf(button.custom_minimum_size.x, 44.0)
	for state: String in STATES:
		button.add_theme_stylebox_override(state, style_for(role, state, palette))
	button.add_theme_stylebox_override("focus", focus_style(role, palette))
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


static func style_for(role: String, state: String, palette: Dictionary) -> StyleBoxTexture:
	var fill: Color = _fill(role, state, palette)
	var edge_palette: Dictionary = _edge_palette(role, state, palette)
	return OsFrames.frame_style(OsFrames.ROLE_CONTROL, fill, int(_metrics(role)["padding"]), edge_palette)


static func focus_style(role: String, palette: Dictionary) -> StyleBoxTexture:
	var focus_palette: Dictionary = {
		"shadow": palette["accent_dark"],
		"middle": palette["accent"],
		"highlight": palette["accent_light"],
	}
	return OsFrames.frame_style(OsFrames.ROLE_CONTROL, Color(0, 0, 0, 0), 0, focus_palette)


static func set_selected(button: Button, selected: bool) -> void:
	if not button.toggle_mode:
		button.toggle_mode = true
	button.set_pressed_no_signal(selected)


static func set_icon(button: Button, kind: String, max_width: int = 18) -> void:
	button.icon = WorkspaceIcons.texture(kind)
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", max_width)


static func role_of(button: Button) -> String:
	return str(button.get_meta("os_control_role", ""))


static func contract() -> Dictionary:
	var result: Dictionary = {}
	for role: String in [ROLE_STANDARD, ROLE_PRIMARY, ROLE_TAB, ROLE_LAUNCHER, ROLE_NAV, ROLE_COMPACT, ROLE_HANDLE, ROLE_FOLD]:
		result[role] = _metrics(role)
	return result


static func _metrics(role: String) -> Dictionary:
	match role:
		ROLE_PRIMARY:
			return {"height": 38, "padding": 12}
		ROLE_LAUNCHER:
			return {"height": 44, "padding": 4}
		ROLE_TAB:
			return {"height": 34, "padding": 7}
		ROLE_NAV:
			return {"height": 34, "padding": 7}
		ROLE_COMPACT:
			return {"height": 28, "padding": 5}
		ROLE_HANDLE:
			return {"height": 28, "padding": 4}
		ROLE_FOLD:
			return {"height": 30, "padding": 4}
	return {"height": 38, "padding": 8}


static func _fill(role: String, state: String, palette: Dictionary) -> Color:
	if state == "disabled":
		return palette["disabled"]
	var selected_state: bool = state in ["pressed", "hover_pressed"]
	if role == ROLE_PRIMARY:
		if selected_state:
			return palette["primary_pressed"]
		return palette["primary_hover"] if state == "hover" else palette["primary"]
	if role in [ROLE_TAB, ROLE_LAUNCHER]:
		if selected_state:
			return palette["selected_hover"] if state == "hover_pressed" else palette["selected"]
		return palette["raised_hover"] if state == "hover" else palette["raised"]
	if role == ROLE_HANDLE:
		if selected_state:
			return palette["raised_pressed"]
		return palette["handle_hover"] if state == "hover" else palette["handle"]
	if role == ROLE_FOLD:
		if selected_state:
			return palette["raised_pressed"]
		return palette["well"].lightened(0.06) if state == "hover" else palette["well"]
	if selected_state:
		return palette["raised_pressed"]
	return palette["raised_hover"] if state == "hover" else palette["raised"]


static func _edge_palette(role: String, state: String, palette: Dictionary) -> Dictionary:
	if role == ROLE_PRIMARY or (role in [ROLE_TAB, ROLE_LAUNCHER] and state in ["pressed", "hover_pressed"]):
		return {
			"shadow": palette["shadow"],
			"middle": palette["accent_dark"],
			"highlight": palette["accent_light"],
		}
	return {
		"shadow": palette["shadow"],
		"middle": palette["middle"],
		"highlight": palette["highlight"],
	}
