extends RefCounted

# Debug-build acceptance probe. Uses real button signals and a separate CI-only slot.
static func run(app: Control, mode: String) -> void:
	if not OS.is_debug_build() or mode not in ["write", "read", "capture"]:
		push_error("[skeleton-probe] Unsupported probe mode")
		app.get_tree().quit(1)
		return
	var view: SkeletonView = app.get("view") as SkeletonView
	if mode == "write" or mode == "capture":
		for suffix: String in ["", ".tmp", ".bak"]:
			var path: String = str(app.get("save_path")) + suffix
			if FileAccess.file_exists(path):
				if DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) != OK:
					push_error("[skeleton-probe] Could not clean isolated probe slot")
					app.get_tree().quit(1)
					return
		view.reset_button.pressed.emit()
		for index: int in range(3):
			view.work_button.pressed.emit()
		view.save_button.pressed.emit()
		view.reset_button.pressed.emit()
	view.load_button.pressed.emit()
	var session: SkeletonSession = app.get("session") as SkeletonSession
	var expected: Dictionary = {"cash_cents": 2500, "elapsed_minutes": 45, "completed_actions": 3}
	if int(app.get("last_storage_error")) != OK or session.snapshot() != expected \
			or view.cash_label.text != "$25.00" \
			or view.time_label.text != "Day 1 · 08:45" or view.count_label.text != "3":
		push_error("[skeleton-probe] State, persistence, or rendered labels did not match")
		app.get_tree().quit(1)
		return
	if mode == "capture":
		if DisplayServer.get_name() == "headless":
			push_error("[skeleton-probe] Capture needs a graphical display")
			app.get_tree().quit(1)
			return
		await app.get_tree().process_frame
		await app.get_tree().process_frame
		await RenderingServer.frame_post_draw
		var capture_path: String = OS.get_environment("SIM_DURTY_CAPTURE_PATH")
		var image: Image = app.get_viewport().get_texture().get_image()
		if capture_path.is_empty() or image.save_png(capture_path) != OK:
			push_error("[skeleton-probe] Could not save rendered capture")
			app.get_tree().quit(1)
			return
	print("[skeleton-probe] PASS %s cash_cents=2500 elapsed_minutes=45 completed_actions=3" % mode)
	print(app.call("debug_report"))
	app.get_tree().quit(0)
