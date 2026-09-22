extends RefCounted

# Acceptance uses real button signals and a separate CI-only slot.
static func run(app: Control, mode: String) -> void:
	if not OS.is_debug_build() or mode not in ["write", "read", "capture"]:
		_fail(app, "Unsupported probe mode")
		return
	var view: SkeletonView = app.get("view") as SkeletonView
	var session: SkeletonSession = app.get("session") as SkeletonSession
	var continuation_path: String = str(app.get("save_path")) + ".continuation.json"
	if mode == "write" or mode == "capture":
		for suffix: String in ["", ".tmp", ".bak", ".continuation.json"]:
			var path: String = str(app.get("save_path")) + suffix
			if FileAccess.file_exists(path) and DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) != OK:
				_fail(app, "Could not clean isolated probe slot")
				return
		view.reset_button.pressed.emit()
		for index: int in range(3):
			view.work_button.pressed.emit()
		view.spine_panel.sample_button.pressed.emit()
		view.spine_panel.sample_button.pressed.emit()
		view.save_button.pressed.emit()
		var reference: SkeletonSession = SkeletonSession.new(app.get("WORK") as SkeletonWorkDefinition)
		if reference.restore(session.snapshot(), session.spine_snapshot()) != OK:
			_fail(app, "Could not create continuation reference")
			return
		var before_hash: String = session.state_hash()
		reference.sample_random()
		reference.perform_work()
		var evidence: Dictionary = {"before_hash": before_hash, "after_hash": reference.state_hash()}
		var file: FileAccess = FileAccess.open(continuation_path, FileAccess.WRITE)
		if file == null:
			_fail(app, "Could not write continuation oracle")
			return
		file.store_string(JSON.stringify(evidence))
		file.close()
		view.reset_button.pressed.emit()
	view.load_button.pressed.emit()
	var expected: Dictionary = {"cash_cents": 2500, "elapsed_minutes": 45, "completed_actions": 3}
	if int(app.get("last_storage_error")) != OK or session.snapshot() != expected \
			or view.cash_label.text != "$25.00" or view.time_label.text != "Day 1 · 08:45" or view.count_label.text != "3":
		_fail(app, "State, persistence, or rendered labels did not match")
		return
	if mode == "read":
		if not FileAccess.file_exists(continuation_path):
			_fail(app, "Continuation oracle missing from previous process")
			return
		var evidence: Variant = JSON.parse_string(FileAccess.get_file_as_string(continuation_path))
		if not evidence is Dictionary or evidence.get("before_hash", "") != session.state_hash():
			_fail(app, "Complete saved state differs between processes")
			return
		view.spine_panel.sample_button.pressed.emit()
		view.work_button.pressed.emit()
		if session.state_hash() != evidence.get("after_hash", ""):
			_fail(app, "RNG, clock, command or ID continuation differs")
			return
		print("[spine-probe] PASS continuation state_hash=%s" % session.state_hash())
		# Return to the saved baseline for the retained skeleton acceptance contract.
		view.load_button.pressed.emit()
		if int(app.get("last_storage_error")) != OK or session.snapshot() != expected:
			_fail(app, "Could not restore the verified baseline")
			return
	if mode == "capture":
		if DisplayServer.get_name() == "headless":
			_fail(app, "Capture needs a graphical display")
			return
		await app.get_tree().process_frame
		await app.get_tree().process_frame
		await RenderingServer.frame_post_draw
		var capture_path: String = OS.get_environment("SIM_DURTY_CAPTURE_PATH")
		var image: Image = app.get_viewport().get_texture().get_image()
		if capture_path.is_empty() or image.save_png(capture_path) != OK:
			_fail(app, "Could not save rendered capture")
			return
	print("[skeleton-probe] PASS %s cash_cents=2500 elapsed_minutes=45 completed_actions=3" % mode)
	print(app.call("debug_report"))
	app.get_tree().quit(0)


static func _fail(app: Control, message: String) -> void:
	push_error("[skeleton-probe] " + message)
	app.get_tree().quit(1)
