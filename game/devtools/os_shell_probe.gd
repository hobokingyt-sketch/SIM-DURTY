extends RefCounted

# Runs only against a separate CI slot. Navigation must not consume simulation state.
static func run(app: Control, mode: String) -> void:
	if not OS.is_debug_build() or mode not in ["verify", "city", "operations", "tools"] \
			or not str(app.get("save_path")).begins_with("user://_ci_os_shell/"):
		_fail(app, "invalid or non-isolated probe")
		return
	var view: SkeletonView = app.get("view") as SkeletonView
	var session: SkeletonSession = app.get("session") as SkeletonSession
	var initial: Dictionary = session.checkpoint()
	await app.get_tree().process_frame
	view.city.marker.pressed.emit()
	if view.ui_snapshot()["selected_id"] != "skeleton_errand" or view.work_button.is_visible_in_tree():
		_fail(app, "city selection must reveal context, not execute or open work")
		return
	view.city.zoom_at(1.1, view.city.size * 0.5)
	view.city.pan_by_screen(Vector2(28, 12))
	var camera: Dictionary = view.city.camera_snapshot()
	view.open_operations_button.pressed.emit()
	if not view.work_button.is_visible_in_tree() or not view.city.is_visible_in_tree():
		_fail(app, "Operations must remain alongside the city")
		return
	view.close_operations_button.pressed.emit()
	if view.city.camera_snapshot() != camera or session.checkpoint() != initial:
		_fail(app, "navigation changed camera or authoritative state")
		return
	view.inspect_button.pressed.emit()
	view.open_operations_button.pressed.emit()
	for index: int in range(3):
		view.work_button.pressed.emit()
	if session.snapshot() != {"cash_cents": 2500, "elapsed_minutes": 45, "completed_actions": 3} \
			or not view.record_label.text.contains("Errand completed"):
		_fail(app, "Operations did not update real state and records")
		return
	if mode == "city":
		view.close_operations_button.pressed.emit()
	elif mode == "tools":
		view.developer_toggle.button_pressed = true
	view.city.reset_camera()
	await app.get_tree().process_frame
	await app.get_tree().process_frame
	if mode != "verify":
		if DisplayServer.get_name() == "headless":
			_fail(app, "capture requires a graphical display")
			return
		await RenderingServer.frame_post_draw
		var path: String = OS.get_environment("SIM_DURTY_CAPTURE_PATH")
		if path.is_empty() or app.get_viewport().get_texture().get_image().save_png(path) != OK:
			_fail(app, "capture write failed")
			return
	print("[os-probe] PASS selection navigation command isolation")
	print(app.call("debug_report"))
	app.get_tree().quit(0)


static func _fail(app: Control, message: String) -> void:
	push_error("[os-probe] " + message)
	app.get_tree().quit(1)
