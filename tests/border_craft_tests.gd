extends RefCounted

const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_border_craft/slot.json"
var failures: int = 0
var checks: int = 0


func run(tree: SceneTree) -> int:
	_test_shape_family()
	_test_edge_direction()
	await _test_live_craft(tree)
	print("[border-craft-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_shape_family() -> void:
	var contract: Dictionary = OsFrames.contract()
	_check(int(contract[OsFrames.ROLE_SHELL]["chamfer"]) == 10, "outer chassis owns the strongest 10-unit chamfer")
	_check(int(contract[OsFrames.ROLE_SURFACE]["chamfer"]) == 8, "major rail surface uses the 8-unit chamfer")
	_check(int(contract[OsFrames.ROLE_APP]["chamfer"]) == 8, "major app well uses the same 8-unit chamfer family")
	_check(int(contract[OsFrames.ROLE_INSET]["chamfer"]) == 6, "inset well uses the 6-unit secondary chamfer")
	_check(int(contract[OsFrames.ROLE_WIDGET]["chamfer"]) == 6, "widget module uses the 6-unit secondary chamfer")
	_check(int(contract[OsFrames.ROLE_CONTROL]["chamfer"]) == 4, "controls keep the compact 4-unit chamfer")
	for role: String in contract:
		var item: Dictionary = contract[role]
		_check(int(item["outer"]) >= 1 and int(item["structure"]) >= 1 and int(item["bevel"]) >= 1, role + " has containment, structure and bevel layers")
		_check(int(item["patch"]) > int(item["chamfer"]), role + " protects its corner join inside the nine-patch")


func _test_edge_direction() -> void:
	var palette: Dictionary = OsTokens.frame_palette()
	var raised: Image = OsFrames.frame_style(OsFrames.ROLE_SURFACE, OsTokens.RAIL_SURFACE, 0, palette, OsFrames.EDGE_RAISED).texture.get_image()
	var recessed: Image = OsFrames.frame_style(OsFrames.ROLE_APP, OsTokens.APP_WELL, 0, palette, OsFrames.EDGE_RECESSED).texture.get_image()
	var center_x: int = raised.get_width() / 2
	var top_y: int = 3
	var bottom_y: int = raised.get_height() - 4
	_check(raised.get_pixel(center_x, top_y).get_luminance() > raised.get_pixel(center_x, bottom_y).get_luminance(), "raised surfaces follow top-left light / bottom-right shadow")
	_check(recessed.get_pixel(center_x, top_y).get_luminance() < recessed.get_pixel(center_x, bottom_y).get_luminance(), "recessed wells invert the bevel")
	_check(raised.get_pixel(0, 0).a == 0.0 and recessed.get_pixel(0, 0).a == 0.0, "corner cuts remain physically transparent")
	_check(raised.get_pixel(center_x, 0).is_equal_approx(OsTokens.EDGE_SHADOW), "outer containment stays dark instead of becoming another highlight line")


func _test_live_craft(tree: SceneTree) -> void:
	_cleanup()
	var old_size: Vector2i = tree.root.size
	tree.root.size = Vector2i(2560, 1440)
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	app.set("auto_load", false)
	tree.root.add_child(app)
	await _frames(tree)
	var view: SkeletonView = app.get("view") as SkeletonView
	var session: SkeletonSession = app.get("session") as SkeletonSession
	var before: Dictionary = session.checkpoint()
	var workspace_before: Dictionary = view.workspace.model.snapshot()
	var widget_before: Dictionary = view.widget_workspace.snapshot()

	_check((view.center_app_surface.get_theme_stylebox("panel") as StyleBoxTexture).texture != null, "Operations keeps a scalable recessed frame")
	_check((view._context_scroll.get_theme_stylebox("panel") as StyleBoxTexture).texture != null, "Context existing surface now uses the inset frame role")
	_check((view._bottom_widget_dock.get_theme_stylebox("panel") as StyleBoxTexture).texture != null, "Workbench existing bay now uses the inset frame role")
	for widget: WidgetView in view.widget_workspace.widgets.values():
		_check(widget.get_theme_stylebox("panel") is StyleBoxTexture, widget.widget_id + " remains a raised framed module")
	_check(view.workspace.model.snapshot() == workspace_before, "border craft does not change rail geometry/preferences")
	_check(view.widget_workspace.snapshot() == widget_before, "border craft does not change widget forms/positions")
	_check(session.checkpoint() == before, "border craft is presentation-only")

	app.queue_free()
	await _frames(tree)
	tree.root.size = old_size
	_cleanup()


func _frames(tree: SceneTree) -> void:
	for index: int in range(4):
		await tree.process_frame


func _cleanup() -> void:
	for path: String in [SLOT, WorkspacePreferences.path_for_slot(SLOT), WidgetWorkspace.profile_path(SLOT)]:
		for suffix: String in ["", ".tmp", ".bak"]:
			if FileAccess.file_exists(path + suffix):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("[border-craft-tests] PASS: " + label)
	else:
		failures += 1
		push_error("[border-craft-tests] FAIL: " + label)
