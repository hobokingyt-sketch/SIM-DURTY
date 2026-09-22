extends RefCounted
const SLOT: String = "user://_ci_apps/slot.json"
var _failed: bool = false
var _tree: SceneTree
func run(app: Control, mode: String) -> void:
	_tree = app.get_tree()
	if not OS.is_debug_build() or app.get("save_path") != SLOT or mode not in ["verify", "operations", "record"]:
		_fail("unsupported or non-isolated app probe"); _tree.quit(1); return
	var view: SkeletonView = app.get("view") as SkeletonView; var session: SkeletonSession = app.get("session") as SkeletonSession; var initial: Dictionary = session.checkpoint()
	await _frames(); view.city.zoom_at(1.15, view.city.size * 0.5); view.city.pan_by_screen(Vector2(30,14)); var camera: Dictionary = view.city.camera_snapshot()
	view.city.marker.pressed.emit(); view.open_operations_button.pressed.emit(); await _frames()
	_check(view.ui_snapshot()["active_app"] == "operations" and not view.city.visible, "context opens center Operations")
	view.operations_record_tab.pressed.emit(); view.city_button.pressed.emit(); view.operations_button.pressed.emit(); await _frames()
	_check(view.ui_snapshot()["active_view"] == "record", "Operations remembers local view")
	view.close_operations_button.pressed.emit(); _check(view.city.camera_snapshot() == camera and view.ui_snapshot()["selected_id"] == "skeleton_errand", "City return preserves camera and selection")
	var recent: WidgetView = view.widget_workspace.widgets["recent_activity"]; recent.inspect_button.pressed.emit(); await _frames()
	_check(view.ui_snapshot()["active_app"] == "record" and view.city.visible, "widget opens rail Session Record")
	view.record_storage_tab.pressed.emit(); view.city_button.pressed.emit(); view.record_app_button.pressed.emit(); _check(view.ui_snapshot()["active_view"] == "storage", "rail app resumes view")
	_check(session.checkpoint() == initial, "navigation consumes no simulation state")
	if mode == "operations":
		view.city_button.pressed.emit()
		view.operations_button.pressed.emit()
		view.operations_work_tab.pressed.emit()
	elif mode == "record":
		view.city_button.pressed.emit()
		view.record_app_button.pressed.emit()
		view.record_activity_tab.pressed.emit()
	await _frames()
	if mode != "verify":
		if DisplayServer.get_name() == "headless": _fail("capture requires graphical display")
		else:
			var surface: Control = view.center_app_surface if mode == "operations" else view.right_app_surface
			var surface_bounds: Rect2 = surface.get_global_rect().grow(1.0)
			var controls: Array[Control] = [view.operations_work_tab, view.operations_record_tab] if mode == "operations" else [view.record_activity_tab, view.record_storage_tab, view.right_back_buttons[0], view.right_back_buttons[1]]
			for control: Control in controls:
				if control.is_visible_in_tree():
					_check(surface_bounds.encloses(control.get_global_rect()), "visible app chrome stays inside its owning surface")
			await RenderingServer.frame_post_draw
			var path: String = OS.get_environment("SIM_DURTY_CAPTURE_PATH")
			_check(not path.is_empty() and app.get_viewport().get_texture().get_image().save_png(path) == OK, "real app capture written")
	print("[app-probe] %s lifecycle navigation continuity" % ["FAIL" if _failed else "PASS"]); print(app.call("debug_report")); _tree.quit(1 if _failed else 0)
func _frames() -> void:
	for index: int in range(5): await _tree.process_frame
func _check(condition: bool, label: String) -> void:
	if not condition: _fail(label)
func _fail(message: String) -> void:
	_failed = true; push_error("[app-probe] " + message)
