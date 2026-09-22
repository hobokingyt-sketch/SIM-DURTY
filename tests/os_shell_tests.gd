extends RefCounted

const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_os_shell/slot.json"
var failures: int = 0
var checks: int = 0


func run(tree: SceneTree) -> int:
	_test_presentation_model()
	await _test_shell(tree)
	_cleanup()
	print("[os-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_presentation_model() -> void:
	var model: OsPresentationState = OsPresentationState.new()
	_check(model.open_app("operations") != OK, "no unconfigured work app")
	model.configure("skeleton_errand")
	_check(model.snapshot()["selected_id"] == "", "no invented initial selection")
	var initial: Dictionary = model.snapshot()
	_check(model.select_work("missing") != OK and model.snapshot() == initial, "unknown selection rejected")
	_check(model.open_app("crew") != OK and model.snapshot() == initial, "unimplemented app rejected")
	_check(model.select_work("skeleton_errand") == OK, "known authored work can be selected")
	_check(model.open_app("operations") == OK and model.snapshot()["selected_id"] == "skeleton_errand", "app receives selected identity")
	model.open_app("city")
	_check(model.snapshot()["selected_id"] == "skeleton_errand", "closing app preserves selection")
	var detached: Dictionary = model.snapshot()
	detached["selected_id"] = "tampered"
	_check(model.snapshot()["selected_id"] == "skeleton_errand", "presentation snapshot is detached")
	model.clear_selection()
	_check(model.snapshot()["selected_id"] == "" and model.snapshot()["active_app"] == "city", "clear resets only presentation route")


func _test_shell(tree: SceneTree) -> void:
	_cleanup()
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	app.set("auto_load", false)
	tree.root.add_child(app)
	await tree.process_frame
	await tree.process_frame
	var view: SkeletonView = app.get("view") as SkeletonView
	var session: SkeletonSession = app.get("session") as SkeletonSession
	var initial: Dictionary = session.checkpoint()
	_check(view.city.is_visible_in_tree(), "city is the default workspace")
	_check(not view.work_button.is_visible_in_tree(), "glance does not duplicate app actions")
	_check(not view.developer_scroll.visible and not view.record_scroll.visible, "secondary drawers start hidden")
	_check(view.open_operations_button.disabled, "empty context cannot start work")
	_check(view.select_work("fake") != OK and session.checkpoint() == initial, "unknown spatial entity cannot mutate session")
	view.inspect_button.pressed.emit()
	_check(view.ui_snapshot()["selected_id"] == "skeleton_errand" and view.context_title.text == "Run an errand", "Work Scan selects the same authored work")
	_check(not view.open_operations_button.disabled and not view.work_button.is_visible_in_tree(), "inspection exposes handoff, not execution")
	view.clear_selection()
	view.city.marker.pressed.emit()
	_check(view.ui_snapshot()["selected_id"] == "skeleton_errand" and view.city.marker.button_pressed, "city marker and context share one selection")
	view.city.zoom_at(1.2, view.city.size * 0.5)
	view.city.pan_by_screen(Vector2(50, 20))
	var camera: Dictionary = view.city.camera_snapshot()
	view.open_operations_button.pressed.emit()
	_check(view.work_button.is_visible_in_tree() and view.city.is_visible_in_tree(), "Operations occupies a dock, not the city")
	_check(view.ui_snapshot()["active_app"] == "operations", "app lifecycle owns one active route")
	view.close_operations_button.pressed.emit()
	_check(view.city.camera_snapshot() == camera and view.ui_snapshot()["selected_id"] == "skeleton_errand", "close restores context without replacing the city")
	_check(session.checkpoint() == initial and not FileAccess.file_exists(SLOT), "navigation and camera never consume time, RNG, IDs or disk")
	view.open_operations()
	view.work_button.pressed.emit()
	_check(view.cash_label.text == "$15.00" and view.time_label.text == "Day 1 · 08:15", "Operations uses the original authoritative command")
	_check(view.count_label.text == "1" and session.snapshot()["completed_actions"] == 1, "all readouts observe the same result")
	_check(view.record_label.text.contains("Errand completed") and view.status_kind.text == "UPDATE", "work is an update and record, not an alert")
	view.record_toggle.button_pressed = true
	_check(view.record_scroll.visible, "records open in their authored drawer")
	var checkpoint: Dictionary = session.checkpoint()
	view.developer_toggle.button_pressed = true
	_check(view.developer_scroll.visible and not view.record_scroll.visible, "developer drawer replaces rather than piles onto records")
	_check(session.checkpoint() == checkpoint, "developer inspection is presentation-only")
	view.developer_toggle.button_pressed = false
	view.show_status("Injected UI error", true)
	_check(view.status_kind.text == "ATTENTION", "errors are visually distinct from updates")
	view.show_status("Normal update", false)
	_check(view.status_kind.text == "UPDATE", "normal status can clear transient error emphasis")
	view.save_button.pressed.emit()
	_check(int(app.get("last_storage_error")) == OK, "persistent OS Save uses existing slot adapter")
	var disk: PackedByteArray = FileAccess.get_file_as_bytes(SLOT)
	var button_count: int = view.find_children("*", "Button", true, false).size()
	for index: int in range(50):
		view.city_button.pressed.emit()
		view.operations_button.pressed.emit()
		view.glance_toggle.button_pressed = not view.glance_toggle.button_pressed
	view.glance_toggle.button_pressed = true
	_check(view.find_children("*", "Button", true, false).size() == button_count, "repeated navigation does not create hidden app copies")
	_check(FileAccess.get_file_as_bytes(SLOT) == disk and session.checkpoint() == checkpoint, "repeated layout changes do not autosave or mutate gameplay")
	view.work_button.pressed.emit()
	view.load_button.pressed.emit()
	_check(session.checkpoint() == checkpoint and view.ui_snapshot()["active_app"] == "operations", "Load restores authority without tearing down the shell")
	_check(view.city.camera_snapshot() == camera, "save and load preserve the current camera")
	_check(view.record_label.text.contains("No events"), "loading does not invent event history")
	var point: Vector2 = Vector2(880, 600)
	_check(view.city.world_from_screen(view.city.screen_from_world(point)).distance_to(point) < 0.01, "world and screen transforms roundtrip")
	view.city.zoom_at(1000.0, view.city.size * 0.5)
	_check(view.city.camera_snapshot()["zoom"] == CityBlockout.MAX_ZOOM, "camera zoom has an upper bound")
	view.city.zoom_at(0.0001, view.city.size * 0.5)
	_check(view.city.camera_snapshot()["zoom"] == CityBlockout.MIN_ZOOM, "camera zoom has a lower bound")
	var safe_camera: Dictionary = view.city.camera_snapshot()
	view.city.zoom_at(NAN, Vector2.ZERO)
	view.city.pan_by_screen(Vector2(INF, 0))
	_check(view.city.camera_snapshot() == safe_camera, "invalid camera inputs cannot poison layout")
	view.city.reset_camera()
	_check(view.city.camera_snapshot()["zoom"] == 1.0, "camera reset is an independent presentation action")
	view.glance_toggle.button_pressed = false
	await tree.process_frame
	await tree.process_frame
	# ADR 0011 replaces the old fixed 820x520 surface with an available-size reservation.
	var required: Vector2 = WorkspaceLayout.city_minimum(view.workspace.size)
	print("[os-layout-test] workspace=%s city=%s required=%s" % [view.workspace.size, view.city.size, required])
	_check(view.city.size.x >= required.x and view.city.size.y >= required.y, "city retains its declared adaptive minimum working region")
	_check(str(app.call("debug_report")).contains("presentation:"), "debug report includes current presentation route")
	app.queue_free()
	await tree.process_frame


func _cleanup() -> void:
	for suffix: String in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(SLOT + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(SLOT + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("[os-tests] PASS: " + label)
	else:
		failures += 1
		push_error("[os-tests] FAIL: " + label)
