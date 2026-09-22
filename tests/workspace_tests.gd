extends RefCounted

const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_workspace/slot.json"
const PROFILE: String = "user://ui_workspaces/test_workspace.json"
var checks: int = 0
var failures: int = 0
var commits: int = 0


func run(tree: SceneTree) -> int:
	_test_geometry()
	_test_transactions()
	_test_storage()
	await _test_input(tree)
	_cleanup(PROFILE)
	_cleanup(WorkspacePreferences.path_for_slot(SLOT))
	print("[workspace-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_geometry() -> void:
	var model: WorkspaceLayout = WorkspaceLayout.new()
	for size: Vector2 in [Vector2(2560, 1440), Vector2(1920, 1080), Vector2(1600, 900), Vector2(1280, 800)]:
		for index: int in range(16):
			var prefs: Dictionary = WorkspaceLayout.defaults()
			for side_index: int in range(4):
				prefs["rails"][WorkspaceLayout.SIDES[side_index]]["collapsed"] = (index & (1 << side_index)) != 0
			model.restore(prefs)
			var fit: Dictionary = model.solve(size)
			var city_rect: Rect2 = fit["rects"]["city"]
			var minimum: Vector2 = fit["city_minimum"]
			var safe: bool = city_rect.size.x >= minimum.x and city_rect.size.y >= minimum.y
			var regions: Array = ["left", "right", "top", "bottom", "city"]
			for a: int in range(regions.size()):
				var rect: Rect2 = fit["rects"][regions[a]]
				safe = safe and Rect2(Vector2.ZERO, size).encloses(rect)
				for b: int in range(a + 1, regions.size()):
					safe = safe and not rect.intersects(fit["rects"][regions[b]])
			_check(safe, "bounded non-overlapping regions and protected city at %s combination %d" % [size, index])
	model.restore(WorkspaceLayout.defaults())
	_check(model.solve(WorkspaceLayout.REFERENCE)["city_minimum"] == Vector2(1440, 800), "reference city minimum is explicit")
	model.resize_to("left", 700, WorkspaceLayout.REFERENCE)
	var preferred: Dictionary = model.snapshot()
	var large: Dictionary = model.solve(WorkspaceLayout.REFERENCE)
	model.solve(Vector2(1280, 800))
	_check(model.snapshot() == preferred and model.solve(WorkspaceLayout.REFERENCE) == large, "small-host fitting never overwrites preferred arrangement")
	model.set_scale_percent(125)
	_check(model.scale_for(Vector2(2560, 1440)) == 1.25 and model.scale_for(Vector2(1280, 800)) == 1.0, "scale never auto-shrinks text below 100 percent")
	_check(model.snapshot()["scale_percent"] == 125, "temporary scale fallback preserves requested size")
	for bad: Variant in [null, {}, {"version": 99}, {"rails": []}]:
		_check(not WorkspaceLayout.validate(bad), "malformed preference rejected")
	var malformed: Dictionary = WorkspaceLayout.defaults()
	malformed["rails"]["left"]["extent"] = 301
	_check(not WorkspaceLayout.validate(malformed), "unsnapped persisted extent rejected")
	malformed = WorkspaceLayout.defaults()
	malformed["rails"]["left"]["collapsed"] = 1
	_check(not WorkspaceLayout.validate(malformed), "non-boolean collapsed flag rejected")


func _test_transactions() -> void:
	var model: WorkspaceLayout = WorkspaceLayout.new()
	model.committed.connect(func() -> void: commits += 1)
	var original: Dictionary = model.snapshot()
	_check(model.begin_resize("left", WorkspaceLayout.REFERENCE), "begin one rail edit")
	_check(not model.begin_resize("right", WorkspaceLayout.REFERENCE), "second manipulation refused")
	model.preview_delta(93, WorkspaceLayout.REFERENCE)
	_check(model.snapshot() == original and model.solve(WorkspaceLayout.REFERENCE)["extents"]["left"] == 400 and commits == 0, "preview snaps but is not persisted")
	model.cancel_resize()
	_check(model.snapshot() == original and model.active_side().is_empty() and commits == 0, "cancel restores original without a commit")
	model.begin_resize("left", WorkspaceLayout.REFERENCE)
	model.preview_delta(60, WorkspaceLayout.REFERENCE)
	_check(model.commit_resize() and commits == 1 and model.snapshot()["rails"]["left"]["extent"] == 360, "one completed edit produces one commit")
	_check(not model.commit_resize() and commits == 1, "duplicate release cannot write twice")
	model.resize_to("right", 1000000, WorkspaceLayout.REFERENCE)
	_check(model.solve(WorkspaceLayout.REFERENCE)["rects"]["city"].size.x >= 1440, "extreme drag stops before crushing city")
	original = model.snapshot()
	_check(not model.resize_to("unknown", 400, WorkspaceLayout.REFERENCE) and not model.resize_to("left", NAN, WorkspaceLayout.REFERENCE) and model.snapshot() == original, "invalid edit cannot poison preferences")
	model.set_collapsed("left", true)
	_check(model.snapshot()["rails"]["left"]["extent"] == 360, "folding retains expanded size")
	model.reset_layout()
	_check(model.snapshot() == WorkspaceLayout.defaults(), "reset layout resets only the model")


func _test_storage() -> void:
	_cleanup(PROFILE)
	var store: WorkspacePreferences = WorkspacePreferences.new(PROFILE)
	_check(store.read_layout()["error"] == ERR_FILE_NOT_FOUND and not FileAccess.file_exists(PROFILE), "first inspection creates no profile")
	var layout: Dictionary = WorkspaceLayout.defaults()
	layout["rails"]["bottom"]["extent"] = 300
	_check(store.write_layout(layout) == OK, "committed layout writes independently")
	_check(WorkspacePreferences.new(PROFILE).read_layout()["layout"] == layout, "fresh store restores logical preferences")
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(PROFILE)
	var invalid: Dictionary = layout.duplicate(true)
	invalid["version"] = 99
	_check(store.write_layout(invalid) != OK and FileAccess.get_file_as_bytes(PROFILE) == bytes, "invalid write preserves profile")
	_put(PROFILE, JSON.stringify({"format": WorkspacePreferences.FORMAT, "layout": invalid}))
	bytes = FileAccess.get_file_as_bytes(PROFILE)
	_check(store.read_layout()["error"] == ERR_UNAVAILABLE and store.write_layout(layout) == ERR_UNAVAILABLE and FileAccess.get_file_as_bytes(PROFILE) == bytes, "future profile is never silently overwritten")
	_put(PROFILE, "{broken")
	_check(store.read_layout()["error"] == ERR_FILE_CORRUPT and store.write_layout(layout) == ERR_FILE_CORRUPT and FileAccess.get_file_as_string(PROFILE) == "{broken", "damaged profile remains intact")
	_put(PROFILE, "x".repeat(WorkspacePreferences.MAX_BYTES + 1))
	_check(store.read_layout()["error"] == ERR_FILE_CORRUPT, "oversized profile bounded")
	_check(WorkspacePreferences.new(SLOT).write_layout(layout) != OK, "profile writer rejects gameplay namespace")
	_check(WorkspacePreferences.path_for_slot(SLOT) != WorkspacePreferences.path_for_slot(SLOT + "other"), "slots have independent profiles")
	_cleanup(PROFILE)


func _test_input(tree: SceneTree) -> void:
	var original_window_size: Vector2i = tree.root.size
	tree.root.size = Vector2i(1600, 900)
	var profile: String = WorkspacePreferences.path_for_slot(SLOT)
	_cleanup(profile)
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	app.set("auto_load", false)
	tree.root.add_child(app)
	await tree.process_frame
	await tree.process_frame
	var view: SkeletonView = app.get("view") as SkeletonView
	view.configure_workspace(SLOT, true)
	var session: SkeletonSession = app.get("session") as SkeletonSession
	var checkpoint: Dictionary = session.checkpoint()
	var camera: Dictionary = view.city.camera_snapshot()
	var handle: RailHandle = view.workspace.handles["left"]
	var point: Vector2 = handle.get_global_rect().get_center()
	_push_button(tree, point, true)
	_push_motion(tree, point + Vector2(60, 0))
	_check(view.workspace.model.active_side() == "left" and not FileAccess.file_exists(profile), "real pointer dispatch starts a preview without disk writes")
	var escape: InputEventKey = InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	tree.root.push_input(escape)
	_check(view.workspace.model.snapshot() == WorkspaceLayout.defaults() and not FileAccess.file_exists(profile), "Escape cancels dispatched drag without saving")
	_push_button(tree, point + Vector2(60, 0), false)
	_push_button(tree, point, true)
	_push_motion(tree, point + Vector2(40, 0))
	_push_button(tree, point + Vector2(40, 0), false)
	await tree.process_frame
	_check(view.workspace.model.snapshot()["rails"]["left"]["extent"] == 340 and FileAccess.file_exists(profile), "pointer release commits and autosaves layout only")
	var disk: PackedByteArray = FileAccess.get_file_as_bytes(profile)
	handle.grab_focus()
	var key: InputEventKey = InputEventKey.new()
	key.keycode = KEY_RIGHT
	key.pressed = true
	tree.root.push_input(key)
	_check(view.workspace.model.snapshot()["rails"]["left"]["extent"] == 360, "focused splitter keyboard input uses same step")
	await tree.process_frame
	point = handle.get_global_rect().get_center()
	_push_button(tree, point, true)
	_push_motion(tree, point + Vector2(80, 0))
	view.workspace.cancel_manipulation()
	_push_button(tree, point + Vector2(80, 0), false)
	_check(view.workspace.model.snapshot()["rails"]["left"]["extent"] == 360, "focus-loss cancellation path restores committed width")
	var before: Dictionary = view.workspace.model.snapshot()
	_push_button(tree, handle.get_global_rect().get_center(), true)
	_push_motion(tree, handle.get_global_rect().get_center() + Vector2(80, 0))
	view.workspace.size -= Vector2(20, 0)
	view.workspace.notification(Container.NOTIFICATION_SORT_CHILDREN)
	_check(view.workspace.model.active_side().is_empty() and view.workspace.model.snapshot() == before, "viewport change cancels manipulation")
	_push_button(tree, point, false)
	view.call("_fit_workspace")
	var wheel: InputEventMouseButton = InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	wheel.position = view.save_button.get_global_rect().get_center()
	tree.root.push_input(wheel)
	_check(view.city.camera_snapshot() == camera, "wheel over OS control does not reach city camera")
	_check(session.checkpoint() == checkpoint and not FileAccess.file_exists(SLOT), "dispatched layout input never mutates or autosaves gameplay")
	view.layout_toggle.pressed.emit()
	(view.rail_controls["right"]["larger"] as Button).pressed.emit()
	_check(view.layout_scroll.visible and view.workspace.model.snapshot()["rails"]["right"]["extent"] == 320, "non-drag pointer alternative uses same geometry model")
	view.reset_layout_button.pressed.emit()
	_check(view.workspace.model.snapshot() == WorkspaceLayout.defaults() and session.checkpoint() == checkpoint and view.city.camera_snapshot() == camera, "Reset layout leaves simulation and camera intact")
	var node_count: int = view.find_children("*", "Control", true, false).size()
	for index: int in range(40):
		view.workspace.toggle_rail("left")
	_check(view.find_children("*", "Control", true, false).size() == node_count, "repeated fold/expand retains the same components")
	_check(FileAccess.get_file_as_bytes(profile) != disk, "later layout commits update only the profile")
	app.queue_free()
	await tree.process_frame
	_cleanup(profile)
	tree.root.size = original_window_size


func _push_button(tree: SceneTree, point: Vector2, pressed: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = point
	event.global_position = point
	tree.root.push_input(event)


func _push_motion(tree: SceneTree, point: Vector2) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	tree.root.push_input(event)


func _put(path: String, text: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(text)
		file.close()


func _cleanup(path: String) -> void:
	for suffix: String in ["", ".tmp"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("[workspace-tests] PASS: " + label)
	else:
		failures += 1
		push_error("[workspace-tests] FAIL: " + label)
