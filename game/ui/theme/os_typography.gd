class_name OsTypography
extends RefCounted

# Phase 6D.4 semantic type scale. Persistent UI text never drops below 14 px.
const ROLE_APP_TITLE: String = "app_title"
const ROLE_TASK_TITLE: String = "task_title"
const ROLE_REGION_TITLE: String = "region_title"
const ROLE_SYSTEM_LABEL: String = "system_label"
const ROLE_BODY: String = "body"
const ROLE_META: String = "meta"
const ROLE_DATA: String = "data"
const ROLE_DATA_COMPACT: String = "data_compact"
const ROLE_VALUE_LARGE: String = "value_large"
const ROLE_VALUE_MEDIUM: String = "value_medium"
const ROLE_WIDGET_PRIMARY: String = "widget_primary"

const SPECS: Dictionary = {
	ROLE_APP_TITLE: {"size": 30, "line_spacing": 2},
	ROLE_TASK_TITLE: {"size": 36, "line_spacing": 3},
	ROLE_REGION_TITLE: {"size": 22, "line_spacing": 2},
	ROLE_SYSTEM_LABEL: {"size": 14, "line_spacing": 1},
	ROLE_BODY: {"size": 17, "line_spacing": 4},
	ROLE_META: {"size": 15, "line_spacing": 3},
	ROLE_DATA: {"size": 22, "line_spacing": 2},
	ROLE_DATA_COMPACT: {"size": 16, "line_spacing": 2},
	ROLE_VALUE_LARGE: {"size": 38, "line_spacing": 2},
	ROLE_VALUE_MEDIUM: {"size": 32, "line_spacing": 2},
	ROLE_WIDGET_PRIMARY: {"size": 18, "line_spacing": 2},
}

const PERSISTENT_ROLES: PackedStringArray = [
	ROLE_APP_TITLE,
	ROLE_TASK_TITLE,
	ROLE_REGION_TITLE,
	ROLE_SYSTEM_LABEL,
	ROLE_BODY,
	ROLE_META,
	ROLE_DATA,
	ROLE_DATA_COMPACT,
	ROLE_VALUE_LARGE,
	ROLE_VALUE_MEDIUM,
	ROLE_WIDGET_PRIMARY,
]


static func contract() -> Dictionary:
	return SPECS.duplicate(true)


static func font_size(role: String) -> int:
	var spec: Dictionary = SPECS.get(role, SPECS[ROLE_BODY])
	return int(spec["size"])


static func apply(label: Label, role: String, color: Color) -> Label:
	var spec: Dictionary = SPECS.get(role, SPECS[ROLE_BODY])
	label.set_meta("os_type_role", role)
	label.add_theme_font_size_override("font_size", int(spec["size"]))
	label.add_theme_constant_override("line_spacing", int(spec["line_spacing"]))
	label.add_theme_color_override("font_color", color)
	return label


static func stabilize_numeric(label: Label, minimum_width: float) -> void:
	label.set_meta("os_stable_numeric", true)
	label.custom_minimum_size.x = maxf(label.custom_minimum_size.x, minimum_width)


static func minimum_persistent_size() -> int:
	var result: int = 1000
	for role: String in PERSISTENT_ROLES:
		result = mini(result, font_size(role))
	return result


static func button_font_size(control_role: String) -> int:
	match control_role:
		"primary":
			return 17
		"standard":
			return 16
		"tab", "nav":
			return 15
		"compact", "handle", "fold", "launcher":
			return 14
	return 16
