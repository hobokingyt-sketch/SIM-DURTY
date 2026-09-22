extends RefCounted

const WORK: SkeletonWorkDefinition = preload("res://game/content/work/skeleton_errand.tres")
const SLOT: String = "user://_ci_recovery/probe_slot_v1.json"
const DAMAGED: String = "{isolated-recovery-fixture"


static func run(app: Control, mode: String) -> void:
	# This fault injection can never select the player's slot.
	if not OS.is_debug_build() or str(app.get("save_path")) != SLOT \
			or mode not in ["write", "read", "capture", "capture-tools"]:
		_fail(app, "Invalid isolated recovery probe")
		return
	var view: SkeletonView = app.get("view") as SkeletonView
	var session: SkeletonSession = app.get("session") as SkeletonSession
	var expected: SkeletonSession = SkeletonSession.new(WORK)
	for index: int in range(3):
		expected.perform_work()
	for index: int in range(2):
		expected.sample_random()
	var expected_hash: String = expected.state_hash()
	if mode != "read":
		var directory: String = ProjectSettings.globalize_path(SLOT.get_base_dir())
		if DirAccess.make_dir_recursive_absolute(directory) != OK:
			_fail(app, "Cannot create isolated slot")
			return
		for suffix: String in _suffixes():
			if FileAccess.file_exists(SLOT + suffix):
				if DirAccess.remove_absolute(ProjectSettings.globalize_path(SLOT + suffix)) != OK:
					_fail(app, "Cannot clear isolated fixture")
					return
		view.reset_button.pressed.emit()
		for index: int in range(3):
			view.work_button.pressed.emit()
		for index: int in range(2):
			view.spine_panel.sample_button.pressed.emit()
		view.save_button.pressed.emit()
		if int(app.get("last_storage_error")) != OK:
			_fail(app, "Cannot save checkpoint")
			return
		var original: String = FileAccess.get_file_as_string(SLOT)
		view.work_button.pressed.emit()
		view.save_button.pressed.emit()
		if int(app.get("last_storage_error")) != OK:
			_fail(app, "Cannot prepare backup")
			return
		var file: FileAccess = FileAccess.open(SLOT, FileAccess.WRITE)
		if file == null:
			_fail(app, "Cannot prepare corruption fixture")
			return
		file.store_string(DAMAGED)
		file.close()
		view.load_button.pressed.emit()
		if view.recovery_button.disabled or not view.recovery_button.is_visible_in_tree():
			_fail(app, "Recovery action was not offered")
			return
		view.recovery_button.pressed.emit()
		if int(app.get("last_storage_error")) != OK \
				or FileAccess.get_file_as_string(SLOT) != original \
				or FileAccess.get_file_as_string(SLOT + ".bak") != original \
				or FileAccess.get_file_as_string(SLOT + ".rejected-001") != DAMAGED:
			_fail(app, "Recovery did not preserve exact files")
			return
	if session.state_hash() != expected_hash or view.cash_label.text != "$25.00" \
			or view.dirty_label.text != "Matches saved slot" or view.developer_scroll.visible:
		_fail(app, "Recovered startup state or default presentation is incorrect")
		return
	if mode == "read":
		# Normal startup auto-load, then prove the next random/work continuation.
		session.sample_random()
		session.perform_work()
		expected.sample_random()
		expected.perform_work()
		if session.state_hash() != expected.state_hash():
			_fail(app, "Recovered continuation diverged")
			return
		view.load_button.pressed.emit()
	if mode.begins_with("capture"):
		if mode == "capture-tools":
			view.developer_toggle.button_pressed = true
		if DisplayServer.get_name() == "headless":
			_fail(app, "Capture requires a graphical display")
			return
		await app.get_tree().process_frame
		await app.get_tree().process_frame
		await RenderingServer.frame_post_draw
		var output: String = OS.get_environment("SIM_DURTY_CAPTURE_PATH")
		if output.is_empty() or app.get_viewport().get_texture().get_image().save_png(output) != OK:
			_fail(app, "Capture failed")
			return
	print("[recovery-probe] PASS %s state_hash=%s" % [mode, expected_hash])
	print(app.call("debug_report"))
	app.get_tree().quit(0)


static func _suffixes() -> PackedStringArray:
	var result: PackedStringArray = ["", ".bak", ".tmp", ".recover.tmp"]
	for index: int in range(1, SkeletonSave.MAX_REJECTED_COPIES + 1):
		result.append(".rejected-%03d" % index)
	return result


static func _fail(app: Control, message: String) -> void:
	push_error("[recovery-probe] " + message)
	app.get_tree().quit(1)
