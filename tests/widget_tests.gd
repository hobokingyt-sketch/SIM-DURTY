extends RefCounted

const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_widgets/slot.json"
const CAPS: Dictionary = {"bottom": Vector2(1500, 320), "right": Vector2(500, 720)}
var failures: int = 0
var checks: int = 0


func run(tree: SceneTree) -> int:
	_test_model()
	_test_storage()
	await _test_input_and_continuity(tree)
	_cleanup()
	print("[widget-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_model() -> void:
	var layout: Dictionary = WidgetLayout.defaults()
	_check(WidgetLayout.validate(layout), "authored registry has a valid default layout")
	var original: Dictionary = layout.duplicate(true)
	var json: Variant = JSON.parse_string(JSON.stringify(layout))
	_check(WidgetLayout.validate(json) and WidgetLayout.normalize(json) == layout, "logical placements survive JSON numeric normalization")
	var invalid: Array = [null, {}, {"version": 99, "placements": []}]
	for field: String in ["id", "region", "form", "order"]:
		var bad: Dictionary = layout.duplicate(true)
		bad["placements"][0][field] = "unknown"
		invalid.append(bad)
	var duplicate: Dictionary = layout.duplicate(true)
	duplicate["placements"][1]["id"] = "work_scan"
	invalid.append(duplicate)
	var missing: Dictionary = layout.duplicate(true)
	missing["placements"].pop_back()
	invalid.append(missing)
	for value: Variant in invalid:
		_check(not WidgetLayout.validate(value), "unknown, missing or malformed widget layouts are rejected")
	var moved: Dictionary = WidgetLayout.propose_move(layout, CAPS, "recent_activity", "bottom", 0)
	_check(not moved.is_empty() and WidgetLayout.placement(moved, "recent_activity")["order"] == 0, "cross-rail move produces an ordered candidate")
	_check(layout == original, "proposal never mutates the committed layout")
	var reordered: Dictionary = WidgetLayout.propose_move(moved, CAPS, "work_scan", "bottom", 0)
	_check(WidgetLayout.placement(reordered, "work_scan")["order"] == 0, "same-rail insertion uses a stable order")
	_check(WidgetLayout.propose_move(layout, CAPS, "work_scan", "city", 0).is_empty(), "city is not a widget drop surface")
	_check(WidgetLayout.propose_move(layout, {"bottom": Vector2.ZERO, "right": Vector2(240, 128)}, "work_scan", "right", 0).is_empty(), "full destination rejects drop without growing rail")
	for form: String in WidgetLayout.FORMS:
		var candidate: Dictionary = WidgetLayout.propose_form(layout, CAPS, "work_scan", form)
		_check(not candidate.is_empty() and WidgetLayout.placement(candidate, "work_scan")["form"] == form, "each authored form can be requested with enough space")
	_check(WidgetLayout.propose_form(layout, {"bottom": Vector2(900, 128), "right": Vector2(240, 300)}, "work_scan", "major").is_empty(), "explicit enlargement rejects rather than silently changing the requested form")
	var expanded: Dictionary = WidgetLayout.propose_form(moved, CAPS, "work_scan", "major")
	for dimensions: Vector2 in [Vector2(570, 96), Vector2(720, 144), Vector2(1100, 300), Vector2(1500, 500)]:
		var capacities: Dictionary = {"bottom": dimensions, "right": Vector2(240, 300)}
		var solved: Dictionary = WidgetLayout.solve(expanded, capacities)
		_check(solved == WidgetLayout.solve(expanded, capacities), "capacity fitting is deterministic")
		var a: Rect2 = solved["items"]["work_scan"]["rect"]
		var b: Rect2 = solved["items"]["recent_activity"]["rect"]
		_check(not a.intersects(b), "settled rectangles never overlap at constrained sizes")
		_check(a.size.x >= WidgetLayout.minimum(solved["items"]["work_scan"]["form"], "bottom").x, "fitting preserves semantic minimum instead of shrinking text")
	_check(WidgetLayout.placement(expanded, "work_scan")["form"] == "major", "temporary fit does not overwrite preferred form")
	var narrow: Dictionary = WidgetLayout.solve(expanded, {"bottom": Vector2(700, 100), "right": Vector2(240, 300)})
	_check(narrow["regions"]["bottom"]["overflow"], "insufficient existing host exposes bounded scroll overflow")
	var detached: Dictionary = WidgetLayout.placement(layout, "work_scan")
	detached["form"] = "major"
	_check(layout == original, "placement access is detached")


func _test_storage() -> void:
	_cleanup()
	var path: String = WidgetWorkspace.profile_path(SLOT)
	var store: WorkspacePreferences = WorkspacePreferences.new(path, "widgets")
	_check(store.read_layout()["error"] == ERR_FILE_NOT_FOUND and not FileAccess.file_exists(path), "reading missing widget profile writes nothing")
	var first: Dictionary = WidgetLayout.defaults()
	_check(store.write_layout(first) == OK, "widget profile uses the shared staged IO implementation")
	_check(store.read_layout()["layout"] == first, "independent profile roundtrips logical data")
	_check(not FileAccess.file_exists(WorkspacePreferences.path_for_slot(SLOT)) and not FileAccess.file_exists(SLOT), "widget storage creates neither a rail nor a game save")
	var moved: Dictionary = WidgetLayout.propose_move(first, CAPS, "work_scan", "right", 1)
	_check(store.write_layout(moved) == OK and store.read_layout()["layout"] == moved, "committed move replaces only its own profile")
	_check(not FileAccess.file_exists(path + ".tmp"), "successful profile write leaves no stage file")
	var future: Dictionary = first.duplicate(true)
	future["version"] = 99
	_put(path, JSON.stringify({"format": "sim-durty.widgets", "layout": future}))
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	_check(store.read_layout()["error"] == ERR_UNAVAILABLE, "future widget schema is distinguished")
	_check(store.write_layout(first) == ERR_UNAVAILABLE and FileAccess.get_file_as_bytes(path) == bytes, "future profile is never overwritten")
	for text: String in ["{damaged", JSON.stringify({"format": "sim-durty.workspace", "layout": WorkspaceLayout.defaults()}), "x".repeat(WorkspacePreferences.MAX_BYTES + 1)]:
		_put(path, text)
		_check(store.read_layout()["error"] != OK and store.write_layout(first) != OK and FileAccess.get_file_as_string(path) == text, "bad, foreign and oversized profiles fail closed")
	var invalid: WorkspacePreferences = WorkspacePreferences.new("res://unsafe.json", "widgets")
	_check(invalid.write_layout(first) != OK, "widget writes stay in the presentation namespace")
	_cleanup()


func _test_input_and_continuity(tree: SceneTree) -> void:
	var old_size: Vector2i = tree.root.size
	tree.root.size = Vector2i(2560, 1440)
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	app.set("auto_load", false)
	tree.root.add_child(app)
	await _frames(tree)
	var view: SkeletonView = app.get("view") as SkeletonView
	view.configure_workspace(SLOT, true)
	await _frames(tree)
	var manager: WidgetWorkspace = view.widget_workspace
	var session: SkeletonSession = app.get("session") as SkeletonSession
	var work: WidgetView = manager.widgets["work_scan"]
	var recent: WidgetView = manager.widgets["recent_activity"]
	var profile: String = WidgetWorkspace.profile_path(SLOT)
	view.save_button.pressed.emit()
	var game_bytes: PackedByteArray = FileAccess.get_file_as_bytes(SLOT)
	var checkpoint: Dictionary = session.checkpoint()
	var camera: Dictionary = view.city.camera_snapshot()
	var initial: Dictionary = manager.snapshot()
	_check(work.is_visible_in_tree() and recent.is_visible_in_tree(), "two live widgets occupy their declared starting regions")
	_check(work.effective_form == "wide" and recent.effective_form == "tall", "default forms use actual available geometry")
	_check(not FileAccess.file_exists(profile), "initial presentation and read-model updates do not save preferences")
	var node_count: int = view.find_children("*", "Control", true, false).size()
	var start: Vector2 = work.drag_handle.get_global_rect().get_center()
	var destination: Vector2 = recent.get_parent().get_parent().get_global_rect().position + Vector2(80, 20)
	_mouse(tree, start, true)
	_motion(tree, destination)
	_check(not manager.manipulation_snapshot().is_empty() and manager.manipulation_snapshot()["valid"], "viewport pointer dispatch produces a valid drag preview")
	_check(manager.snapshot() == initial and not FileAccess.file_exists(profile), "preview is not a persisted move")
	_key(tree, KEY_ESCAPE)
	_mouse(tree, view.city.get_global_rect().get_center(), false)
	_check(manager.manipulation_snapshot().is_empty() and manager.snapshot() == initial, "Escape rolls back and consumes the release")
	_check(view.city.camera_snapshot() == camera and session.checkpoint() == checkpoint, "canceled manipulation never leaks to city or simulation")
	_mouse(tree, start, true)
	_motion(tree, view.city.get_global_rect().get_center())
	_mouse(tree, view.city.get_global_rect().get_center(), false)
	_check(manager.snapshot() == initial and not FileAccess.file_exists(profile), "invalid city drop leaves arrangement and disk unchanged")
	_mouse(tree, start, true)
	_motion(tree, destination)
	_mouse(tree, destination, false)
	await _frames(tree)
	_check(WidgetLayout.placement(manager.snapshot(), "work_scan")["region"] == "right", "native drop commits a cross-rail move")
	_check(FileAccess.file_exists(profile), "only a committed manipulation writes the widget profile")
	_check(manager.move_widget("recent_activity", "bottom", 0), "click-equivalent move follows the same model")
	await _frames(tree)
	_check(manager.resize_widget("work_scan", "compact"), "right-rail keyboard resize starts from a compact form")
	await _frames(tree)
	work.resize_handle.grab_focus()
	_key(tree, KEY_RIGHT)
	await _frames(tree)
	_check(work.effective_form == "tall", "keyboard resize skips an unavailable wide form")
	work.drag_handle.grab_focus()
	_key(tree, KEY_ENTER)
	await _frames(tree)
	_check(WidgetLayout.placement(manager.snapshot(), "work_scan")["region"] == "bottom", "keyboard transfer uses the same destination rules")
	_check(manager.move_widget("work_scan", "bottom", 1), "two widgets can share the workbench")
	await _frames(tree)
	work.drag_handle.grab_focus()
	_key(tree, KEY_LEFT)
	await _frames(tree)
	_check(WidgetLayout.placement(manager.snapshot(), "work_scan")["order"] == 0, "viewport keyboard event reorders the focused widget")
	_check(view.find_children("*", "Control", true, false).size() == node_count, "moves and reorders reuse mounted components")
	view.workspace.model.resize_to("bottom", 380, view.workspace.size)
	await _frames(tree)
	_check(manager.resize_widget("work_scan", "major"), "larger rail accepts the major form")
	await _frames(tree)
	_check(work.details.visible and work.effective_form == "major", "major form reveals useful additional information")
	start = work.resize_handle.get_global_rect().get_center()
	_mouse(tree, start, true)
	_motion(tree, start - Vector2(40, 132))
	_check(manager.manipulation_snapshot().get("valid", false), "pointer resize previews a fitting authored form")
	_mouse(tree, start - Vector2(40, 132), false)
	await _frames(tree)
	_check(work.effective_form == "wide", "pointer release commits the previewed wide form")
	work.menu_button.get_popup().about_to_popup.emit()
	var major_index: int = work.menu_button.get_popup().get_item_index(13)
	_check(not work.menu_button.get_popup().is_item_disabled(major_index), "non-drag menu enables a fitting major form")
	work.menu_button.get_popup().id_pressed.emit(13)
	await _frames(tree)
	_check(work.effective_form == "major", "menu action and pointer resizing share the same form contract")
	var preferred: Dictionary = manager.snapshot()
	var profile_bytes: PackedByteArray = FileAccess.get_file_as_bytes(profile)
	tree.root.size = Vector2i(1280, 800)
	await _frames(tree)
	_check(manager.snapshot() == preferred and FileAccess.get_file_as_bytes(profile) == profile_bytes, "smaller window retains preferred layout and saved bytes")
	_check(work.effective_form == "compact", "constrained window composes a compact form instead of scaling text")
	tree.root.size = Vector2i(2560, 1440)
	await _frames(tree)
	_check(work.effective_form == "major", "larger host restores the preferred major form")
	start = work.drag_handle.get_global_rect().get_center()
	_mouse(tree, start, true)
	_motion(tree, start + Vector2(20, 10))
	tree.root.focus_exited.emit()
	_check(manager.manipulation_snapshot().is_empty() and manager.snapshot() == preferred, "focus-loss notification cancels widget manipulation")
	_mouse(tree, start, false)
	tree.root.focus_entered.emit()
	var wheel: InputEventMouseButton = InputEventMouseButton.new()
	wheel.position = work.get_global_rect().get_center()
	wheel.global_position = wheel.position
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	tree.root.push_input(wheel, true)
	_check(view.city.camera_snapshot() == camera, "widget wheel input does not zoom the city")
	start = work.drag_handle.get_global_rect().get_center()
	_mouse(tree, start, true)
	_motion(tree, start + Vector2(30, 10))
	view.workspace.model.set_collapsed("top", true)
	_check(manager.manipulation_snapshot().is_empty() and manager.snapshot() == preferred, "rail changes cancel an in-flight widget manipulation")
	_mouse(tree, start, false)
	await _frames(tree)
	start = work.resize_handle.get_global_rect().get_center()
	_mouse(tree, start, true)
	_motion(tree, start - Vector2(180, 150))
	_key(tree, KEY_ESCAPE)
	_mouse(tree, start, false)
	_check(manager.snapshot() == preferred, "resize cancellation preserves preferred form")
	_check(session.checkpoint() == checkpoint and FileAccess.get_file_as_bytes(SLOT) == game_bytes, "all layout operations leave game save and complete simulation unchanged")
	view.workspace.model.set_scale_percent(125)
	await _frames(tree)
	start = work.drag_handle.get_global_rect().get_center()
	_mouse(tree, start, true)
	destination = recent.get_parent().get_parent().get_global_rect().position + Vector2(40, 30)
	_motion(tree, destination)
	if manager.manipulation_snapshot().is_empty():
		print("[widget-input-diagnostic] viewport=%s scale=%s start=%s handle=%s dock=%s hovered=%s" % [tree.root.get_visible_rect(), view.workspace.scale, start, work.drag_handle.get_global_rect(), work.get_parent().get_parent().get_global_rect(), tree.root.gui_get_hovered_control()])
	_check(not manager.manipulation_snapshot().is_empty(), "enlarged UI transforms pointer manipulation without losing the gesture")
	_key(tree, KEY_ESCAPE)
	_mouse(tree, destination, false)
	view.workspace.model.set_scale_percent(100)
	await _frames(tree)
	_check(manager.snapshot() == preferred and FileAccess.get_file_as_bytes(profile) == profile_bytes, "scale changes and cancellation do not rewrite widget preferences")
	work.inspect_button.pressed.emit()
	view.open_operations_button.pressed.emit()
	view.work_button.pressed.emit()
	_check(recent.primary.text == "Errand completed" and work.details.text.contains("1 completed"), "moved widgets continue observing real session updates")
	_check(FileAccess.get_file_as_bytes(profile) == profile_bytes, "data updates do not rewrite preferred widget geometry")
	var live_checkpoint: Dictionary = session.checkpoint()
	view.reset_layout_button.pressed.emit()
	await _frames(tree)
	_check(manager.snapshot() == WidgetLayout.defaults() and session.checkpoint() == live_checkpoint, "reset layout resets widget choices but not gameplay")
	_check(view.city.camera_snapshot() == camera, "widget resets retain the city camera")
	_check(str(app.call("debug_report")).contains("widget_storage_error"), "current report includes widget persistence status")
	app.queue_free()
	await _frames(tree)
	tree.root.size = old_size


func _frames(tree: SceneTree) -> void:
	for index: int in range(5): await tree.process_frame


func _mouse(tree: SceneTree, point: Vector2, pressed: bool) -> void:
	# Points come from Control global rectangles in this viewport, not desktop coordinates.
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.global_position = point
	event.pressed = pressed
	tree.root.push_input(event, true)


func _motion(tree: SceneTree, point: Vector2) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	tree.root.push_input(event, true)


func _key(tree: SceneTree, code: Key) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.pressed = true
	tree.root.push_input(event, true)
	event = event.duplicate() as InputEventKey
	event.pressed = false
	tree.root.push_input(event, true)


func _put(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_check(false, "fixture can be written")
		return
	file.store_string(text)
	file.close()


func _cleanup() -> void:
	for path: String in [SLOT, WorkspacePreferences.path_for_slot(SLOT), WidgetWorkspace.profile_path(SLOT)]:
		for suffix: String in ["", ".tmp", ".bak"]:
			if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition: print("[widget-tests] PASS: " + label)
	else:
		failures += 1
		push_error("[widget-tests] FAIL: " + label)
