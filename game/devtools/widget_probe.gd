extends SceneTree

# This entry point is exported only as a debug acceptance tool. It uses isolated slots.
const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_ci_widgets/slot.json"
const ORACLE: String = "user://_ci_widgets/oracle.json"
var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var mode: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--widget-mode="): mode = argument.trim_prefix("--widget-mode=")
	if not OS.is_debug_build() or mode not in ["write", "read", "capture", "capture-preview", "capture-invalid", "capture-major", "capture-right"]:
		_fail("unsupported widget probe mode")
		quit(1)
		return
	if mode != "read":
		for path: String in [SLOT, ORACLE, WorkspacePreferences.path_for_slot(SLOT), WidgetWorkspace.profile_path(SLOT)]:
			for suffix: String in ["", ".tmp", ".bak"]:
				if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
	if mode in ["write", "read"]: root.size = Vector2i(2560, 1440)
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	app.set("auto_load", mode == "read")
	root.add_child(app)
	await _frames()
	var view: SkeletonView = app.get("view") as SkeletonView
	var session: SkeletonSession = app.get("session") as SkeletonSession
	view.configure_workspace(SLOT, true)
	await _frames()
	var widgets: WidgetWorkspace = view.widget_workspace
	var work: WidgetView = widgets.widgets["work_scan"]
	var recent: WidgetView = widgets.widgets["recent_activity"]
	var checkpoint: Dictionary = session.checkpoint()
	if mode == "read":
		var expected: Variant = JSON.parse_string(FileAccess.get_file_as_string(ORACLE))
		if not expected is Dictionary:
			_fail("writer oracle missing")
		else:
			_check(widgets.snapshot() == WidgetLayout.normalize(expected["widgets"]), "fresh process restores exact widget placement and form")
			_check(session.state_hash() == expected["state_hash"], "fresh process restores unchanged simulation")
			_check(FileAccess.get_sha256(SLOT) == expected["save_sha256"], "game save bytes remain unchanged")
			_check(FileAccess.get_sha256(WidgetWorkspace.profile_path(SLOT)) == expected["profile_sha256"], "loading layout does not rewrite its profile")
			_check(work.effective_form == "tall", "restored semantic form is applied to real components")
	elif mode == "write":
		view.save_button.pressed.emit()
		var save_hash: String = FileAccess.get_sha256(SLOT)
		var start: Vector2 = work.drag_handle.get_global_rect().get_center()
		var destination: Vector2 = recent.get_parent().get_parent().get_global_rect().position + Vector2(90, 15)
		_mouse(start, true)
		_motion(destination)
		_check(not widgets.manipulation_snapshot().is_empty() and widgets.manipulation_snapshot().get("valid", false), "native drag previews a legal destination")
		_mouse(destination, false)
		await _frames()
		_check(WidgetLayout.placement(widgets.snapshot(), "work_scan")["region"] == "right", "native drop moves Work Scan to the right rail")
		_check(widgets.move_widget("recent_activity", "bottom", 0), "second widget transfers without duplicate components")
		await _frames()
		_check(widgets.resize_widget("work_scan", "tall"), "tall form accepted by the destination")
		await _frames()
		_check(session.checkpoint() == checkpoint and FileAccess.get_sha256(SLOT) == save_hash, "widget edits preserve full gameplay state and saved bytes")
		_check(widgets.storage_error == OK, "committed widget profile is stored")
		_put(ORACLE, JSON.stringify({"widgets": widgets.snapshot(), "state_hash": session.state_hash(),
			"save_sha256": save_hash, "profile_sha256": FileAccess.get_sha256(WidgetWorkspace.profile_path(SLOT))}, "\t", true))
	else:
		for index: int in range(3): session.perform_work()
		view.select_work("skeleton_errand")
		if mode == "capture-major":
			view.workspace.model.resize_to("bottom", 380, view.workspace.size)
			await _frames()
			_check(widgets.resize_widget("work_scan", "major"), "major capture has adequate geometry")
		elif mode == "capture-right":
			_check(widgets.move_widget("recent_activity", "bottom", 0), "capture moves activity to workbench")
			await _frames()
			_check(widgets.move_widget("work_scan", "right", 0), "capture moves Work Scan into instrument rail")
			await _frames()
			widgets.resize_widget("work_scan", "tall")
		await _frames()
		if mode in ["capture-preview", "capture-invalid"]:
			var start: Vector2 = work.drag_handle.get_global_rect().get_center()
			_mouse(start, true)
			var target: Vector2 = recent.get_parent().get_parent().get_global_rect().position + Vector2(90, 15)
			_motion(view.city.get_global_rect().get_center() if mode == "capture-invalid" else target)
			_check(not widgets.manipulation_snapshot().is_empty(), "capture contains a real manipulation preview")
		await _frames()
		if DisplayServer.get_name() == "headless": _fail("capture needs a graphical display")
		else:
			await RenderingServer.frame_post_draw
			var path: String = OS.get_environment("SIM_DURTY_CAPTURE_PATH")
			_check(not path.is_empty() and root.get_texture().get_image().save_png(path) == OK, "real widget capture written")
			for widget: WidgetView in widgets.widgets.values():
				if not widget.is_visible_in_tree(): continue
				for control: Control in [widget.drag_handle, widget.resize_handle, widget.menu_button, widget.inspect_button]:
					_check(widget.get_global_rect().grow(1).encloses(control.get_global_rect()), "widget owns the bounds of its interactive controls")
	print("[widget-probe] %s %s" % ["FAIL" if _failed else "PASS", mode])
	print("widget_profile_sha256: " + FileAccess.get_sha256(WidgetWorkspace.profile_path(SLOT)))
	print(app.call("debug_report"))
	quit(1 if _failed else 0)


func _frames() -> void:
	for index: int in range(6): await process_frame


func _mouse(point: Vector2, pressed: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.global_position = point
	event.pressed = pressed
	root.push_input(event)


func _motion(point: Vector2) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(event)


func _put(path: String, text: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null: _fail("oracle could not be written")
	else:
		file.store_string(text)
		file.close()


func _check(condition: bool, label: String) -> void:
	if not condition: _fail(label)


func _fail(message: String) -> void:
	_failed = true
	push_error("[widget-probe] " + message)
