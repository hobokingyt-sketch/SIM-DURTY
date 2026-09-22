extends RefCounted
const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_apps/slot.json"
var failures: int = 0
var checks: int = 0
func run(tree: SceneTree) -> int:
	_test_navigation_model(); _test_presentation_model(); await _test_shell_lifecycle(tree); _cleanup()
	print("[app-tests] %d checks, %d failures" % [checks, failures]); return failures
func _test_navigation_model() -> void:
	var nav: OsAppNavigation = OsAppNavigation.new()
	_check(nav.snapshot()["active_app"] == "city", "navigation starts at City")
	_check(nav.open_app("missing") != OK, "unknown app rejected")
	_check(nav.open_app("operations") == OK, "center app opens")
	_check(nav.snapshot()["host_mode"] == OsAppManifest.HOST_CENTER and nav.snapshot()["active_view"] == "work", "Operations default view")
	_check(nav.navigate_view("record") == OK and nav.snapshot()["back_depth"] == 1, "local navigation pushes Back")
	_check(nav.back() and nav.snapshot()["active_view"] == "work", "Back restores prior view")
	_check(not nav.back(), "Back stops at app root")
	nav.navigate_view("record"); nav.return_to_city()
	_check(nav.open_app("operations") == OK and nav.snapshot()["active_view"] == "record", "Operations resumes view")
	nav.return_to_city(); _check(nav.open_app("record") == OK and nav.snapshot()["host_mode"] == OsAppManifest.HOST_RIGHT, "Session Record rail host")
	nav.navigate_view("storage"); nav.return_to_city()
	_check(nav.open_app("record") == OK and nav.snapshot()["active_view"] == "storage", "rail app remembers view")
func _test_presentation_model() -> void:
	var model: OsPresentationState = OsPresentationState.new()
	_check(model.open_app("operations") != OK, "Operations needs configured work")
	model.configure("skeleton_errand")
	_check(model.open_deep_link("operations", "work", "missing") != OK, "invalid deep link rejected")
	_check(model.open_deep_link("operations", "work", "skeleton_errand") == OK, "authored deep link accepted")
	_check(model.snapshot()["selected_id"] == "skeleton_errand", "deep link retains shared selection")
	model.navigate_view("record"); model.return_to_city()
	_check(model.snapshot()["selected_id"] == "skeleton_errand" and model.snapshot()["active_app"] == "city", "Home preserves selection")
	_check(model.open_app("record", "activity") == OK, "rail app needs no fake gameplay state")
	model.clear_selection(); _check(model.snapshot()["selected_id"] == "" and model.snapshot()["active_app"] == "city", "clear returns City")
func _test_shell_lifecycle(tree: SceneTree) -> void:
	_cleanup()
	var app: Control = MAIN.instantiate() as Control; app.set("save_path", SLOT); app.set("auto_load", false); tree.root.add_child(app); await _frames(tree)
	var view: SkeletonView = app.get("view") as SkeletonView; var session: SkeletonSession = app.get("session") as SkeletonSession
	var initial: Dictionary = session.checkpoint(); var button_count: int = view.find_children("*", "Button", true, false).size()
	_check(view.city.is_visible_in_tree() and not view.center_app_surface.visible, "City owns center by default")
	view.city.marker.grab_focus(); view.city.zoom_at(1.2, view.city.size * 0.5); view.city.pan_by_screen(Vector2(42,18)); var camera: Dictionary = view.city.camera_snapshot()
	view.city.marker.pressed.emit(); view.open_operations_button.pressed.emit(); await _frames(tree)
	_check(not view.city.visible and view.center_app_surface.visible, "Operations is center-focus")
	_check(view.center_app_surface.snapshot()["mounted_views"] == 2, "center views mount once")
	_check(view.ui_snapshot()["selected_id"] == "skeleton_errand" and session.checkpoint() == initial, "center focus preserves selection and gameplay")
	view.operations_record_tab.pressed.emit(); await _frames(tree)
	_check(view.ui_snapshot()["active_view"] == "record" and not view.work_button.is_visible_in_tree(), "Operations switches local view")
	var record_focus: Button = view.center_back_buttons[1]
	record_focus.grab_focus(); view.operations_record_work_button.pressed.emit(); view.operations_record_tab.pressed.emit(); await _frames(tree)
	_check(tree.root.gui_get_focus_owner() == record_focus, "view focus restores")
	view.close_operations_button.pressed.emit(); await _frames(tree)
	_check(view.city.visible and view.city.camera_snapshot() == camera, "City returns with same camera")
	_check(view.ui_snapshot()["selected_id"] == "skeleton_errand", "City return preserves selection")
	_check(tree.root.gui_get_focus_owner() == view.city.marker, "City focus restores")
	view.operations_button.pressed.emit(); await _frames(tree); _check(view.ui_snapshot()["active_view"] == "record", "launcher resumes Operations")
	view.city_button.pressed.emit(); var recent: WidgetView = view.widget_workspace.widgets["recent_activity"]; recent.inspect_button.pressed.emit(); await _frames(tree)
	_check(view.ui_snapshot()["active_app"] == "record" and view.ui_snapshot()["active_view"] == "activity", "widget deep-links to Session Record")
	_check(view.city.visible and view.right_app_surface.visible, "rail app leaves city visible")
	view.record_storage_tab.pressed.emit(); view.city_button.pressed.emit(); view.record_app_button.pressed.emit()
	_check(view.ui_snapshot()["active_view"] == "storage", "rail launcher resumes view")
	view.record_activity_tab.pressed.emit(); (view.right_back_buttons[0] as Button).pressed.emit()
	_check(view.ui_snapshot()["active_view"] == "storage", "Back restores rail view")
	view.city_button.pressed.emit()
	for index: int in range(30):
		view.operations_button.pressed.emit(); view.city_button.pressed.emit(); view.record_app_button.pressed.emit(); view.city_button.pressed.emit()
	_check(view.find_children("*", "Button", true, false).size() == button_count, "switching creates no duplicate controls")
	_check(session.checkpoint() == initial and not FileAccess.file_exists(SLOT), "navigation stays outside gameplay saves")
	_check(view.center_app_surface.process_mode == Node.PROCESS_MODE_DISABLED, "hidden center app suspended")
	app.queue_free(); await tree.process_frame
func _frames(tree: SceneTree) -> void:
	for index: int in range(4): await tree.process_frame
func _cleanup() -> void:
	for suffix: String in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(SLOT + suffix): DirAccess.remove_absolute(ProjectSettings.globalize_path(SLOT + suffix))
func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition: print("[app-tests] PASS: " + label)
	else: failures += 1; push_error("[app-tests] FAIL: " + label)
