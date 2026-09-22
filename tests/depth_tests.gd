extends RefCounted

const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_depth/slot.json"
var failures: int = 0
var checks: int = 0


func run(tree: SceneTree) -> int:
	_test_depth_contract()
	_test_overlay_contract()
	await _test_live_depth(tree)
	print("[depth-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_depth_contract() -> void:
	var contract: Dictionary = OsDepth.contract()
	_check(contract.size() == 6, "depth kit exposes six existing-surface roles")
	_check(OsDepth.fill(OsDepth.ROLE_CHASSIS).get_luminance() < OsDepth.fill(OsDepth.ROLE_RAIL).get_luminance(), "rails sit above the outer chassis")
	_check(OsDepth.fill(OsDepth.ROLE_APP_WELL).get_luminance() < OsDepth.fill(OsDepth.ROLE_RAIL).get_luminance(), "app body is recessed beneath rail material")
	_check(OsDepth.fill(OsDepth.ROLE_WORKBENCH_WELL).get_luminance() < OsDepth.fill(OsDepth.ROLE_WIDGET).get_luminance(), "widgets sit above the workbench well")
	_check(str(OsDepth.spec(OsDepth.ROLE_APP_WELL)["mode"]) == "recessed", "app well uses recessed edge lighting")
	_check(str(OsDepth.spec(OsDepth.ROLE_WIDGET)["mode"]) == "raised", "widget body uses raised edge lighting")
	_check(int(OsDepth.spec(OsDepth.ROLE_APP_WELL)["width"]) > int(OsDepth.spec(OsDepth.ROLE_WIDGET)["width"]), "large well has a broader depth falloff than a widget")
	var style: StyleBoxFlat = OsDepth.fill_style(OsDepth.ROLE_CONTEXT_WELL)
	_check(style.get_content_margin(SIDE_LEFT) == 0.0 and style.get_content_margin(SIDE_TOP) == 0.0, "inset fill adds no layout padding")


func _test_overlay_contract() -> void:
	var panel: Panel = Panel.new()
	panel.custom_minimum_size = Vector2(123, 45)
	var before: Vector2 = panel.get_combined_minimum_size()
	var overlay: OsDepthOverlay = OsDepth.attach(panel, OsDepth.ROLE_APP_WELL)
	_check(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "depth overlay never owns pointer input")
	_check(panel.get_child(0) == overlay, "depth wash stays behind existing content")
	_check(panel.get_combined_minimum_size() == before, "depth wash does not change layout minimums")
	_check(OsDepth.role_of(panel) == "", "attaching a wash alone does not invent semantic ownership")
	panel.free()


func _test_live_depth(tree: SceneTree) -> void:
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
	var widgets_before: Dictionary = view.widget_workspace.snapshot()
	_check(OsDepth.role_of(view.chassis_surface) == OsDepth.ROLE_CHASSIS, "root chassis owns chassis depth")
	for side: String in ["LeftRail", "RightRail", "TopRail", "BottomRail"]:
		var rail: Control = view.workspace.get_node_or_null(side) as Control
		_check(is_instance_valid(rail) and OsDepth.role_of(rail) == OsDepth.ROLE_RAIL, side + " owns rail depth")
		_check(_has_depth_overlay(rail, OsDepth.ROLE_RAIL), side + " carries non-interactive depth wash")
	_check(OsDepth.role_of(view.center_app_surface) == OsDepth.ROLE_APP_WELL, "Operations uses the deep app well")
	_check(OsDepth.role_of(view.right_app_surface) == OsDepth.ROLE_APP_WELL, "Session Record uses the deep app well")
	_check(OsDepth.role_of(view._context_scroll) == OsDepth.ROLE_CONTEXT_WELL, "Context body uses an inset well without changing structure")
	_check(OsDepth.role_of(view._bottom_widget_dock) == OsDepth.ROLE_WORKBENCH_WELL, "Workbench widget bay owns recessed workbench depth")
	_check(OsDepth.role_of(view.record_scroll) == OsDepth.ROLE_WORKBENCH_WELL, "Activity page shares the workbench recess")
	_check(OsDepth.role_of(view.layout_scroll) == OsDepth.ROLE_WORKBENCH_WELL, "Layout page shares the workbench recess")
	for widget: WidgetView in view.widget_workspace.widgets.values():
		_check(OsDepth.role_of(widget) == OsDepth.ROLE_WIDGET, widget.widget_id + " uses raised module depth")
		_check(_has_depth_overlay(widget, OsDepth.ROLE_WIDGET), widget.widget_id + " has the shared module depth wash")
	_check(view.workspace.model.snapshot() == workspace_before, "depth styling does not alter rail preferences")
	_check(view.widget_workspace.snapshot() == widgets_before, "depth styling does not alter widget preferences")
	_check(session.checkpoint() == before, "depth styling is presentation-only")
	app.queue_free()
	await _frames(tree)
	tree.root.size = old_size
	_cleanup()


func _has_depth_overlay(target: Control, role: String) -> bool:
	for child: Node in target.get_children():
		if child is OsDepthOverlay and str(child.get_meta("os_depth_role", "")) == role:
			return true
	return false


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
		print("[depth-tests] PASS: " + label)
	else:
		failures += 1
		push_error("[depth-tests] FAIL: " + label)
