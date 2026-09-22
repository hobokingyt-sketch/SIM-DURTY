class_name OsDepth
extends RefCounted

const ROLE_CHASSIS: String = "chassis"
const ROLE_RAIL: String = "rail"
const ROLE_APP_WELL: String = "app_well"
const ROLE_CONTEXT_WELL: String = "context_well"
const ROLE_WORKBENCH_WELL: String = "workbench_well"
const ROLE_WIDGET: String = "widget"

static func fill(role: String) -> Color:
	match role:
		ROLE_CHASSIS: return OsTokens.CHASSIS
		ROLE_RAIL: return OsTokens.RAIL_SURFACE
		ROLE_APP_WELL: return OsTokens.APP_WELL
		ROLE_CONTEXT_WELL: return OsTokens.CONTEXT_WELL
		ROLE_WORKBENCH_WELL: return OsTokens.WORKBENCH_WELL
		ROLE_WIDGET: return OsTokens.WIDGET_SURFACE
	return OsTokens.SURFACE


static func spec(role: String) -> Dictionary:
	match role:
		ROLE_CHASSIS:
			return {"mode": "raised", "width": 4, "shadow": 0.10, "light": 0.025}
		ROLE_RAIL:
			return {"mode": "raised", "width": 5, "shadow": 0.15, "light": 0.045}
		ROLE_APP_WELL:
			return {"mode": "recessed", "width": 7, "shadow": 0.24, "light": 0.045}
		ROLE_CONTEXT_WELL:
			return {"mode": "recessed", "width": 5, "shadow": 0.18, "light": 0.035}
		ROLE_WORKBENCH_WELL:
			return {"mode": "recessed", "width": 5, "shadow": 0.17, "light": 0.035}
		ROLE_WIDGET:
			return {"mode": "raised", "width": 4, "shadow": 0.13, "light": 0.04}
	return spec(ROLE_RAIL)


static func fill_style(role: String) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill(role)
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	return style


static func frame_style(frame_role: String, depth_role: String, padding: int = 0) -> StyleBoxTexture:
	var edge_mode: String = OsFrames.EDGE_RECESSED if str(spec(depth_role)["mode"]) == "recessed" else OsFrames.EDGE_RAISED
	return OsFrames.frame_style(frame_role, fill(depth_role), padding, OsTokens.frame_palette(), edge_mode)


static func frame_role(depth_role: String) -> String:
	match depth_role:
		ROLE_CHASSIS: return OsFrames.ROLE_SHELL
		ROLE_RAIL: return OsFrames.ROLE_SURFACE
		ROLE_APP_WELL: return OsFrames.ROLE_APP
		ROLE_CONTEXT_WELL, ROLE_WORKBENCH_WELL: return OsFrames.ROLE_INSET
		ROLE_WIDGET: return OsFrames.ROLE_WIDGET
	return OsFrames.ROLE_WIDGET


static func attach(target: Control, role: String) -> OsDepthOverlay:
	for child: Node in target.get_children():
		if child is OsDepthOverlay:
			var existing: OsDepthOverlay = child as OsDepthOverlay
			if str(existing.get_meta("os_depth_role", "")) == role:
				return existing
	var overlay: OsDepthOverlay = OsDepthOverlay.new()
	overlay.name = "Depth_" + role.capitalize()
	overlay.set_meta("os_depth_role", role)
	overlay.setup(role)
	target.add_child(overlay)
	target.move_child(overlay, 0)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return overlay


static func apply_scroll(scroll: ScrollContainer, role: String, identity: String) -> void:
	scroll.set_meta("os_depth_role", role)
	scroll.add_theme_stylebox_override("panel", frame_style(frame_role(role), role))
	OsMaterials.apply_diffuse(scroll, OsMaterials.ROLE_WELL, identity)


static func role_of(target: Control) -> String:
	return str(target.get_meta("os_depth_role", ""))


static func contract() -> Dictionary:
	var result: Dictionary = {}
	for role: String in [ROLE_CHASSIS, ROLE_RAIL, ROLE_APP_WELL, ROLE_CONTEXT_WELL, ROLE_WORKBENCH_WELL, ROLE_WIDGET]:
		result[role] = {"fill": fill(role), "spec": spec(role)}
	return result
