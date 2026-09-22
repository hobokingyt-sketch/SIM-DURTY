extends RefCounted

const SLOT: String = "user://_ci_workspace/slot_v1.json"
const ORACLE: String = "user://_ci_workspace/layout_oracle.json"


static func run(app: Control, mode: String) -> void:
	if not OS.is_debug_build() or app.get("save_path") != SLOT \
			or mode not in ["write", "read", "capture", "capture-layout", "capture-collapsed", "capture-scaled"]:
		_fail(app, "invalid isolated workspace probe")
		return
	var view: SkeletonView = app.get("view") as SkeletonView
	var session: SkeletonSession = app.get("session") as SkeletonSession
	var profile: String = WorkspacePreferences.path_for_slot(SLOT)
	# Headless windows default to the minimum, not the graphical override. This
	# specific persistence scenario needs 1600x900; captures retain their requested size.
	if mode in ["write", "read"]:
		app.get_window().size = Vector2i(1600, 900)
	await app.get_tree().process_frame
	await app.get_tree().process_frame
	if mode == "read":
		var parser: JSON = JSON.new()
		if parser.parse(FileAccess.get_file_as_string(ORACLE)) != OK or not parser.data is Dictionary:
			_fail(app, "missing first-process oracle")
			return
		var oracle: Dictionary = parser.data
		var expected_model: WorkspaceLayout = WorkspaceLayout.new()
		if expected_model.restore(oracle.get("layout", {})) != OK \
				or view.workspace.model.snapshot() != expected_model.snapshot() or session.state_hash() != oracle["state_hash"] \
				or FileAccess.get_file_as_bytes(SLOT).hex_encode().sha256_text() != oracle["game_bytes"]:
			_fail(app, "fresh process did not restore independent layout and gameplay")
			return
	elif mode == "write":
		for path: String in [SLOT, SLOT + ".bak", SLOT + ".tmp", profile, profile + ".tmp", ORACLE]:
			if FileAccess.file_exists(path):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		view.configure_workspace(SLOT, true)
		view.workspace.model.reset_layout()
		view.reset_button.pressed.emit()
		view.open_operations()
		for index: int in range(3):
			view.work_button.pressed.emit()
		view.save_button.pressed.emit()
		if int(app.get("last_storage_error")) != OK:
			_fail(app, "isolated game save failed")
			return
		var game_bytes: String = FileAccess.get_file_as_bytes(SLOT).hex_encode().sha256_text()
		var checkpoint: Dictionary = session.checkpoint()
		await app.get_tree().process_frame
		await app.get_tree().process_frame
		var handle: RailHandle = view.workspace.handles["left"]
		var point: Vector2 = handle.get_global_rect().get_center()
		_button(app, point, true)
		var motion: InputEventMouseMotion = InputEventMouseMotion.new()
		motion.position = point + Vector2(40, 0)
		motion.global_position = motion.position
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		app.get_viewport().push_input(motion)
		_button(app, motion.position, false)
		view.workspace.model.resize_to("top", 120, view.workspace.size)
		view.workspace.model.resize_to("bottom", 240, view.workspace.size)
		view.workspace.model.set_collapsed("right", true)
		var expected: Dictionary = WorkspaceLayout.defaults()
		expected["rails"]["left"]["extent"] = 340
		expected["rails"]["top"]["extent"] = 120
		expected["rails"]["bottom"]["extent"] = 240
		expected["rails"]["right"]["collapsed"] = true
		if view.workspace.model.snapshot() != expected or view.layout_storage_error != OK \
				or session.checkpoint() != checkpoint or FileAccess.get_file_as_bytes(SLOT).hex_encode().sha256_text() != game_bytes:
			_fail(app, "layout edit changed gameplay or did not commit exact preferences")
			return
		var file: FileAccess = FileAccess.open(ORACLE, FileAccess.WRITE)
		if file == null:
			_fail(app, "oracle write unavailable")
			return
		file.store_string(JSON.stringify({"layout": expected, "state_hash": session.state_hash(), "game_bytes": game_bytes}))
		file.close()
	else:
		view.workspace.model.reset_layout()
		view.reset_button.pressed.emit()
		view.inspect_button.pressed.emit()
		if mode == "capture-layout":
			view.layout_toggle.pressed.emit()
			view.workspace.model.set_collapsed("top", true)
			view.workspace.model.resize_to("bottom", 420, view.workspace.size)
		elif mode == "capture-collapsed":
			for side: String in WorkspaceLayout.SIDES:
				view.workspace.model.set_collapsed(side, true)
		elif mode == "capture-scaled":
			view.workspace.model.set_scale_percent(125)
		await app.get_tree().process_frame
		await app.get_tree().process_frame
		await app.get_tree().process_frame
		var geometry: Dictionary = view.workspace.model.solve(view.workspace.size)
		var city_rect: Rect2 = geometry["rects"]["city"]
		var minimum: Vector2 = geometry["city_minimum"]
		if city_rect.size.x < minimum.x or city_rect.size.y < minimum.y:
			_fail(app, "city minimum violated in rendered workspace")
			return
		var bounds: Rect2 = app.get_viewport_rect()
		for control: Control in [view.city, view.save_button, view.load_button, view.layout_toggle]:
			if not control.is_visible_in_tree() or not bounds.encloses(control.get_global_rect()):
				_fail(app, "critical control outside visible viewport")
				return
		if DisplayServer.get_name() == "headless":
			_fail(app, "capture requires a graphical display")
			return
		await RenderingServer.frame_post_draw
		var path: String = OS.get_environment("SIM_DURTY_CAPTURE_PATH")
		if path.is_empty() or app.get_viewport().get_texture().get_image().save_png(path) != OK:
			_fail(app, "capture write failed")
			return
		print("[workspace-render] viewport=%s logical=%s scale=%.2f city=%s minimum=%s" % [bounds.size, view.workspace.size, view.workspace.scale.x, city_rect.size, minimum])
	var fingerprint: String = JSON.stringify(view.workspace.model.snapshot(), "", true).sha256_text()
	print("[workspace-probe] PASS %s profile_hash=%s state_hash=%s" % [mode, fingerprint, session.state_hash()])
	app.get_tree().quit(0)


static func _button(app: Control, point: Vector2, pressed: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	app.get_viewport().push_input(event)


static func _fail(app: Control, message: String) -> void:
	push_error("[workspace-probe] " + message)
	app.get_tree().quit(1)
