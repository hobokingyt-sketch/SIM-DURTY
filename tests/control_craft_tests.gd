extends RefCounted

const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_control_craft/slot.json"
var failures: int = 0
var checks: int = 0


func run(tree: SceneTree) -> int:
	_test_surface_contract()
	_test_material_economy()
	await _test_live_control_craft(tree)
	print("[control-craft-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_surface_contract() -> void:
	var contract: Dictionary = OsControlSurface.contract()
	_check(contract.size() == 8, "control surface kit covers every existing control role")
	_check(int(contract[OsControls.ROLE_PRIMARY]["face_inset"]) == 4, "primary action has a distinct inset face")
	_check(int(contract[OsControls.ROLE_LAUNCHER]["face_inset"]) == 4, "launcher plate has a distinct inset face")
	_check(int(contract[OsControls.ROLE_TAB]["face_inset"]) == 3, "tab face stays shallower than launcher/primary housing")
	_check(int(contract[OsControls.ROLE_HANDLE]["chamfer"]) == 3, "small widget controls keep the compact shape family")
	for role: String in contract:
		_check(int(contract[role]["patch"]) > int(contract[role]["chamfer"]), role + " preserves control corner geometry when stretched")


func _test_material_economy() -> void:
	var palette: Dictionary = OsTokens.control_palette()
	var selected_tab: Image = OsControls.style_for(OsControls.ROLE_TAB, "pressed", palette).texture.get_image()
	var primary: Image = OsControls.style_for(OsControls.ROLE_PRIMARY, "normal", palette).texture.get_image()
	var launcher: Image = OsControls.style_for(OsControls.ROLE_LAUNCHER, "pressed", palette).texture.get_image()
	var center: Vector2i = Vector2i(selected_tab.get_width() / 2, selected_tab.get_height() / 2)
	_check(selected_tab.get_pixelv(center).get_luminance() < palette["accent"].get_luminance() * 0.55, "selected tab face remains dark while brass defines engagement")
	_check(primary.get_pixelv(center).get_luminance() < palette["accent"].get_luminance() * 0.6, "primary face remains dark bronze instead of solid brass")
	_check(launcher.get_pixelv(center).get_luminance() < palette["accent"].get_luminance() * 0.55, "active launcher face remains dark")
	_check(_has_accent_edge(selected_tab, palette["accent"]), "selected tab exposes a brass structural edge")
	_check(_has_accent_edge(primary, palette["accent"]), "primary action exposes a brass structural edge")
	var normal: Image = OsControls.style_for(OsControls.ROLE_STANDARD, "normal", palette).texture.get_image()
	var pressed: Image = OsControls.style_for(OsControls.ROLE_STANDARD, "pressed", palette).texture.get_image()
	_check(_edge_top(normal) > _edge_bottom(normal), "normal face bevel is raised")
	_check(_edge_top(pressed) < _edge_bottom(pressed), "pressed face bevel is recessed")


func _test_live_control_craft(tree: SceneTree) -> void:
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

	_check(view.city_button.button_pressed, "City starts mechanically engaged at root")
	view.city.marker.pressed.emit()
	view.open_operations_button.pressed.emit()
	await _frames(tree)
	_check(view.operations_button.button_pressed, "Operations launcher becomes engaged without changing launcher geometry")
	_check(view.operations_work_tab.button_pressed, "active Operations tab uses the seated control state")
	_check(OsControls.role_of(view.work_button) == OsControls.ROLE_PRIMARY, "execution action remains the existing primary control")
	var work_widget: WidgetView = view.widget_workspace.widgets["work_scan"]
	_check(OsControls.role_of(work_widget.drag_handle) == OsControls.ROLE_HANDLE, "move handle keeps the authored handle role")
	_check(OsControls.role_of(work_widget.menu_button) == OsControls.ROLE_COMPACT, "widget menu keeps compact control construction")
	_check(view.workspace.model.snapshot() == workspace_before, "control craft does not change workspace geometry/preferences")
	_check(view.widget_workspace.snapshot() == widgets_before, "control craft does not change widget form/placement")
	_check(session.checkpoint() == gameplay_before, "control craft remains presentation-only")

	app.queue_free()
	await _frames(tree)
	tree.root.size = old_size
	_cleanup()


func _has_accent_edge(image: Image, accent: Color) -> bool:
	var count: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			if absf(color.r - accent.r) < 0.08 and absf(color.g - accent.g) < 0.08 and absf(color.b - accent.b) < 0.08:
				count += 1
	return count >= 8


func _edge_top(image: Image) -> float:
	return image.get_pixel(image.get_width() / 2, 4).get_luminance()


func _edge_bottom(image: Image) -> float:
	return image.get_pixel(image.get_width() / 2, image.get_height() - 5).get_luminance()


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
		print("[control-craft-tests] PASS: " + label)
	else:
		failures += 1
		push_error("[control-craft-tests] FAIL: " + label)
