extends RefCounted

const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_frames/slot.json"
var failures: int = 0
var checks: int = 0


func run(tree: SceneTree) -> int:
	_test_role_contract()
	_test_style_contract()
	_test_geometry_contract()
	await _test_live_frames(tree)
	print("[frame-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_role_contract() -> void:
	var contract: Dictionary = OsFrames.contract()
	_check(contract.size() == 6, "frame grammar exposes six existing-surface roles")
	_check(int(contract[OsFrames.ROLE_SHELL]["chamfer"]) > int(contract[OsFrames.ROLE_WIDGET]["chamfer"]), "shell chamfer is stronger than widget chamfer")
	_check(int(contract[OsFrames.ROLE_APP]["patch"]) > int(contract[OsFrames.ROLE_CONTROL]["patch"]), "app frame preserves larger corner patch than control frame")
	_check(int(contract[OsFrames.ROLE_SURFACE]["chamfer"]) == int(contract[OsFrames.ROLE_APP]["chamfer"]), "rail and app use the same major chamfer family")
	_check(int(contract[OsFrames.ROLE_INSET]["chamfer"]) == int(contract[OsFrames.ROLE_WIDGET]["chamfer"]), "insets and widgets share the secondary chamfer family")
	_check(not contract[OsFrames.ROLE_SURFACE].has("seam"), "R2 removes decorative seam-tick geometry from structural frames")


func _test_style_contract() -> void:
	var style: StyleBoxTexture = OsFrames.frame_style(OsFrames.ROLE_WIDGET, OsTokens.WELL, 9, OsTokens.frame_palette(), OsFrames.EDGE_RAISED)
	_check(style.texture != null, "widget frame produces a scalable texture")
	_check(style.get_texture_margin(SIDE_LEFT) > 0.0 and style.get_texture_margin(SIDE_TOP) > 0.0, "nine-patch frame protects corner geometry")
	_check(is_equal_approx(style.get_content_margin(SIDE_LEFT), 9.0), "frame preserves caller content padding")
	var image: Image = style.texture.get_image()
	_check(image.get_pixel(0, 0).a == 0.0, "outer corner is truly clipped/transparent")
	_check(image.get_pixel(22, 22).a > 0.99, "frame center remains opaque")
	_check(image.get_pixel(22, 0).is_equal_approx(OsTokens.EDGE_SHADOW), "outer containment edge uses the deep edge color")
	var raised_top: Color = image.get_pixel(22, 2)
	var raised_bottom: Color = image.get_pixel(22, image.get_height() - 3)
	_check(raised_top.get_luminance() > raised_bottom.get_luminance(), "raised frame lights the top edge and seats the bottom edge")
	var recessed: Image = OsFrames.frame_style(OsFrames.ROLE_APP, OsTokens.APP_WELL, 0, OsTokens.frame_palette(), OsFrames.EDGE_RECESSED).texture.get_image()
	_check(recessed.get_pixel(22, 3).get_luminance() < recessed.get_pixel(22, recessed.get_height() - 4).get_luminance(), "recessed frame inverts the bevel direction")


func _test_geometry_contract() -> void:
	var points: PackedVector2Array = OsFrames.chamfer_points(Vector2(300, 120), 8.0, 2.0)
	_check(points.size() == 9, "chamfer path is closed and deterministic")
	_check(points[0].x > 2.0 and is_equal_approx(points[0].y, 2.0), "top-left corner is clipped rather than rounded")
	_check(points[2].x < 300.0 and points[2].y > 2.0, "top-right diagonal remains inside bounds")
	for point: Vector2 in points:
		_check(point.x >= 0.0 and point.y >= 0.0 and point.x <= 300.0 and point.y <= 120.0, "frame path stays inside target bounds")


func _test_live_frames(tree: SceneTree) -> void:
	_cleanup()
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	app.set("auto_load", false)
	tree.root.add_child(app)
	await tree.process_frame
	await tree.process_frame
	var view: SkeletonView = app.get("view") as SkeletonView
	var session: SkeletonSession = app.get("session") as SkeletonSession
	var before: Dictionary = session.checkpoint()
	_check(_has_overlay(view, OsFrames.ROLE_SHELL), "shell keeps one structural outer reinforcement")
	for side: String in ["LeftRail", "RightRail", "TopRail", "BottomRail"]:
		var rail: Control = view.workspace.get_node_or_null(side) as Control
		_check(is_instance_valid(rail) and not _has_overlay(rail, OsFrames.ROLE_SURFACE), side + " relies on its crafted frame instead of extra seam decoration")
		var rail_style: StyleBox = rail.get_theme_stylebox("panel")
		_check(rail_style is StyleBoxTexture, side + " uses scalable chamfered frame texture")
	_check(not _has_overlay(view.center_app_surface, OsFrames.ROLE_APP), "center app uses recessed border construction without extra overlay lines")
	_check(not _has_overlay(view.right_app_surface, OsFrames.ROLE_APP), "rail app uses recessed border construction without extra overlay lines")
	for widget: WidgetView in view.widget_workspace.widgets.values():
		_check(not _has_overlay(widget, OsFrames.ROLE_WIDGET), widget.widget_id + " uses frame construction without decorative seam ticks")
		_check(widget.get_theme_stylebox("panel") is StyleBoxTexture, widget.widget_id + " uses scalable widget frame")
	var dummy: Panel = Panel.new()
	dummy.custom_minimum_size = Vector2(123, 45)
	var minimum_before: Vector2 = dummy.get_combined_minimum_size()
	OsFrames.attach_overlay(dummy, OsFrames.ROLE_WIDGET, OsTokens.frame_palette())
	_check(dummy.get_combined_minimum_size() == minimum_before, "frame overlay does not change layout minimums")
	dummy.free()
	_check(session.checkpoint() == before, "frame rendering remains presentation-only")
	app.queue_free()
	await tree.process_frame
	_cleanup()


func _has_overlay(target: Control, role: String) -> bool:
	for child: Node in target.get_children():
		if child is OsFrameOverlay and str(child.get_meta("os_frame_role", "")) == role:
			return child.mouse_filter == Control.MOUSE_FILTER_IGNORE
	return false


func _cleanup() -> void:
	for suffix: String in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(SLOT + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(SLOT + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("[frame-tests] PASS: " + label)
	else:
		failures += 1
		push_error("[frame-tests] FAIL: " + label)
