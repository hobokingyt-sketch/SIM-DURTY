extends RefCounted

const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_typography_rhythm/slot.json"
var failures: int = 0
var checks: int = 0


func run(tree: SceneTree) -> int:
	_test_type_contract()
	_test_spacing_contract()
	await _test_live_hierarchy(tree)
	_cleanup()
	print("[typography-rhythm-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_type_contract() -> void:
	_check(OsTypography.minimum_persistent_size() >= 14, "persistent semantic text keeps a 14 px floor")
	_check(OsTypography.font_size(OsTypography.ROLE_TASK_TITLE) > OsTypography.font_size(OsTypography.ROLE_APP_TITLE), "task title outranks app title")
	_check(OsTypography.font_size(OsTypography.ROLE_APP_TITLE) > OsTypography.font_size(OsTypography.ROLE_REGION_TITLE), "app title outranks region title")
	_check(OsTypography.font_size(OsTypography.ROLE_REGION_TITLE) > OsTypography.font_size(OsTypography.ROLE_BODY), "region title outranks body copy")
	_check(OsTypography.font_size(OsTypography.ROLE_VALUE_LARGE) > OsTypography.font_size(OsTypography.ROLE_DATA), "primary numeric readout outranks inline data")
	_check(OsTypography.button_font_size(OsControls.ROLE_PRIMARY) > OsTypography.button_font_size(OsControls.ROLE_COMPACT), "primary control text outranks compact control text")


func _test_spacing_contract() -> void:
	var spacing: Dictionary = OsTokens.spacing_contract()
	var previous: int = 0
	for name: String in ["xxs", "xs", "sm", "md", "lg", "xl"]:
		var value: int = int(spacing[name])
		_check(value % 4 == 0, "%s spacing sits on the 4 px baseline" % name)
		_check(value > previous, "%s spacing advances the rhythm" % name)
		previous = value
	_check(int(spacing["md"]) == OsTokens.GAP, "default container gap uses the shared medium rhythm")


func _test_live_hierarchy(tree: SceneTree) -> void:
	_cleanup()
	var old_size: Vector2i = tree.root.size
	tree.root.size = Vector2i(2560, 1440)
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	app.set("auto_load", false)
	tree.root.add_child(app)
	await _frames(tree)
	var view: SkeletonView = app.get("view") as SkeletonView
	var operation_title: Label = view.get("_operation_title") as Label
	_check(str(operation_title.get_meta("os_type_role", "")) == OsTypography.ROLE_TASK_TITLE, "Operations work name uses the task-title role")
	_check(str(view.context_title.get_meta("os_type_role", "")) == OsTypography.ROLE_REGION_TITLE, "Context heading uses the region-title role")
	_check(str(view.cash_label.get_meta("os_type_role", "")) == OsTypography.ROLE_VALUE_LARGE, "cash uses the large numeric role")
	_check(bool(view.cash_label.get_meta("os_stable_numeric", false)) and view.cash_label.custom_minimum_size.x >= 180.0, "cash width is stabilized")
	_check(bool(view.time_label.get_meta("os_stable_numeric", false)) and view.time_label.custom_minimum_size.x >= 190.0, "clock width is stabilized")
	_check(view.time_label.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT, "clock aligns to a stable right edge")
	var work: WidgetView = view.widget_workspace.widgets["work_scan"]
	_check(str(work.primary.get_meta("os_type_role", "")) == OsTypography.ROLE_WIDGET_PRIMARY, "widget primary copy uses its semantic role")
	var stale: PackedStringArray = [
		"Operations owns execution",
		"Test activity only",
		"Bounded local event journal",
		"Rail-hosted app",
		"Read-only inspection here",
		"Opens Operations",
	]
	var all_copy: String = ""
	for node: Node in view.find_children("*", "Label", true, false):
		all_copy += (node as Label).text + "\n"
	for phrase: String in stale:
		_check(not all_copy.contains(phrase), "temporary explainer removed: %s" % phrase)
	for button: Node in view.find_children("*", "Button", true, false):
		var control: Button = button as Button
		var role: String = OsControls.role_of(control)
		if not role.is_empty():
			_check(control.get_theme_font_size("font_size") == OsTypography.button_font_size(role), "control role owns its font size: %s" % role)

	tree.root.size = Vector2i(1280, 800)
	await _frames(tree)
	_check(is_equal_approx(view.workspace.scale.x, 1.0), "minimum supported window does not shrink typography")
	for node: Node in view.find_children("*", "Label", true, false):
		var label: Label = node as Label
		var role: String = str(label.get_meta("os_type_role", ""))
		if not role.is_empty() and label.is_visible_in_tree():
			_check(label.get_theme_font_size("font_size") >= 14, "visible semantic text remains readable at minimum window")
	app.queue_free()
	await _frames(tree)
	tree.root.size = old_size


func _frames(tree: SceneTree) -> void:
	for index: int in range(5):
		await tree.process_frame


func _cleanup() -> void:
	for path: String in [SLOT, WorkspacePreferences.path_for_slot(SLOT), WidgetWorkspace.profile_path(SLOT)]:
		for suffix: String in ["", ".tmp", ".bak"]:
			if FileAccess.file_exists(path + suffix):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("[typography-rhythm-tests] PASS: " + label)
	else:
		failures += 1
		push_error("[typography-rhythm-tests] FAIL: " + label)
