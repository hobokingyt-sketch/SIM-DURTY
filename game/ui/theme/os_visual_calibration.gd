class_name OsVisualCalibration
extends RefCounted

# R4 is a visual calibration contract only. These values document relationships
# extracted from the locked north-star comparison; they do not own layout.
static func contract() -> Dictionary:
	return {
		"surface_order": [
			OsTokens.CHASSIS,
			OsTokens.APP_WELL,
			OsTokens.WORKBENCH_WELL,
			OsTokens.RAIL_SURFACE,
			OsTokens.WIDGET_SURFACE,
			OsTokens.SURFACE,
		],
		"icon": OsTokens.control_palette()["icon"],
		"text": OsTokens.TEXT,
		"muted": OsTokens.MUTED,
		"accent": OsTokens.ACCENT,
		"selected_face": OsTokens.control_palette()["selected_face"],
		"primary_face": OsTokens.control_palette()["primary_face"],
		"grain_strength": OsMaterials.GRAIN_STRENGTH,
		"mottle_strength": OsMaterials.MOTTLE_STRENGTH,
	}


static func luminance(color: Color) -> float:
	return color.get_luminance()
