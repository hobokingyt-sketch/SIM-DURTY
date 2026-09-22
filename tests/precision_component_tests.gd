extends RefCounted

const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_precision_component/slot.json"
var failures: int = 0
var checks: int = 0


func run(tree: SceneTree) -> int:
	_test_join_geometry()
	_test_precision_seating()
	_test_icon_mounting_contract()
	await _test_live_component_assemblies(tree)
	_cleanup()
	print("[precision-component-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_join_geometry() -> void:
	var palette: Dictionary = OsTokens.control_palette()
	_check(OsControlSurface.JOINS.size() == 4, "joined controls expose only four bounded edge positions")
	var single: Image = OsControls.style_for(OsControls.ROLE_TAB, "normal", palette).texture.get_image()
	var first: Image = OsControls.style_for(OsControls.ROLE_TAB, "normal", palette, -1, OsControlSurface.JOIN_FIRST).texture.get_image()
	var middle: Image = OsControls.style_for(OsControls.ROLE_TAB, "normal", palette, -1, OsControlSurface.JOIN_MIDDLE).texture.get_image()
	var last: Image = OsControls.style_for(OsControls.ROLE_TAB, "normal", palette, -1, OsControlSurface.JOIN_LAST).texture.get_image()
	var max_x: int = single.get_width() - 1
	_check(single.get_pixel(max_x, 0).a < 0.05, "single control keeps its outer top-right chamfer")
	_check(first.get_pixel(0, 0).a < 0.05 and first.get_pixel(max_x, 0).a > 0.95, "first control keeps only its exterior chamfer")
	_check(middle.get_pixel(0, 0).a > 0.95 and middle.get_pixel(max_x, 0).a > 0.95, "middle control exposes square internal joins")
	_check(last.get_pixel(0, 0).a > 0.95 and last.get_pixel(max_x, 0).a < 0.05, "last control keeps only its exterior chamfer")


func _test_precision_seating() -> void:
	var palette: Dictionary = OsTokens.control_palette()
	var normal: Image = OsControls.style_for(OsControls.ROLE_TAB, "normal", palette).texture.get_image()
	var pressed: Image = OsControls.style_for(OsControls.ROLE_TAB, "pressed", palette).texture.get_image()
	var x: int = normal.get_width() / 2
	_check(pressed.get_pixel(x, 3).get_luminance() < normal.get_pixel(x, 3).get_luminance(), "engaged tab face seats one pixel deeper")
	_check(_center(pressed).get_luminance() < palette["accent"].get_luminance() * 0.55, "deeper seating preserves dark selected face economy")


func _test_icon_mounting_contract() -> void:
	_check(WorkspaceIcons.optical_width("menu", 16) == 14, "menu glyph receives a compact optical cap")
	_check(WorkspaceIcons.optical_width("move", 16) == 15, "move glyph receives a compact optical cap")
	_check(WorkspaceIcons.optical_width("city", 22) == 22, "large launcher glyph keeps its authored size")


func _test_live_component_assemblies(tree: SceneTree) -> void:
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
	var gameplay_before: Dictionary = session.checkpoint()
	var workspace_before: Dictionary = view.workspace.model.snapshot()
	var widgets_before: Dictionary = view.widget_workspace.snapshot()

	_check(OsControls.join_of(view.close_operations_button) == OsControlSurface.JOIN_MIDDLE, "Operations City control is an internal assembly member")
	_check(OsControls.join_of(view.operations_work_tab) == OsControlSurface.JOIN_MIDDLE, "Operations Work tab uses a square internal join")
	_check(OsControls.join_of(view.operations_record_tab) == OsControlSurface.JOIN_LAST, "Operations Record tab terminates the assembly")
	var operations_group: HBoxContainer = view.operations_work_tab.get_parent() as HBoxContainer
	_check(operations_group.name == "OperationsWorkControls" and operations_group.get_theme_constant("separation") == -1, "Operations control bank overlaps one pixel to avoid doubled seams")

	_check(OsControls.join_of(view.bottom_work_tab) == OsControlSurface.JOIN_FIRST, "Workbench Work tab begins one assembly")
	_check(OsControls.join_of(view.record_toggle) == OsControlSurface.JOIN_MIDDLE, "Workbench Activity tab is an internal assembly member")
	_check(OsControls.join_of(view.bottom_layout_tab) == OsControlSurface.JOIN_LAST, "Workbench Layout tab terminates the assembly")
	var workbench_group: HBoxContainer = view.bottom_work_tab.get_parent() as HBoxContainer
	_check(workbench_group.name == "WorkbenchTabs" and workbench_group.get_theme_constant("separation") == -1, "Workbench tabs share one seam system")

	var work: WidgetView = view.widget_workspace.widgets["work_scan"]
	_check(work.resize_handle.get_parent() == work.menu_button.get_parent(), "widget resize and menu controls share one fitted header tool bank")
	_check(OsControls.join_of(work.resize_handle) == OsControlSurface.JOIN_FIRST, "widget resize handle begins the header tool pair")
	_check(OsControls.join_of(work.menu_button) == OsControlSurface.JOIN_LAST, "widget menu terminates the header tool pair")
	_check(work.menu_button.icon_alignment == HORIZONTAL_ALIGNMENT_CENTER and work.menu_button.vertical_icon_alignment == VERTICAL_ALIGNMENT_CENTER, "icon-only header control is optically centered")
	_check(work.menu_button.get_theme_constant("h_separation") == 0 and work.menu_button.get_theme_constant("icon_max_width") == 14, "icon-only header control removes dead spacing and respects optical size")

	_check(view.workspace.model.snapshot() == workspace_before, "precision craft does not change rail geometry or preferences")
	_check(view.widget_workspace.snapshot() == widgets_before, "precision craft does not change widget geometry or preferences")
	_check(session.checkpoint() == gameplay_before, "precision craft remains presentation-only")

	app.queue_free()
	await _frames(tree)
	tree.root.size = old_size


func _center(image: Image) -> Color:
	return image.get_pixel(image.get_width() / 2, image.get_height() / 2)


func _frames(tree: SceneTree) -> void:
	for index: int in range(5):
		await tree.process_frame


func _cleanup() -> void:
	for path: String in [SLOT, WorkspacePreferences.path_for_slot(SLOT), WidgetWorkspace.profile_path(SLOT)]:
		for suffix: String in ["", ".tmp", ".bak"]:
			if FileAccess.file_exists(path + suffix):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("[precision-component-tests] PASS: " + label)
	else:
		failures += 1
		push_error("[precision-component-tests] FAIL: " + label)
