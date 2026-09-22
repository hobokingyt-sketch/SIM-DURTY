extends RefCounted

const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_controls/slot.json"
var failures: int = 0
var checks: int = 0


func run(tree: SceneTree) -> int:
	_test_role_contract()
	_test_state_styles()
	_test_icon_contract()
	await _test_live_controls(tree)
	print("[control-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_role_contract() -> void:
	var contract: Dictionary = OsControls.contract()
	_check(contract.size() == 8, "control kit exposes eight bounded roles")
	_check(int(contract[OsControls.ROLE_PRIMARY]["height"]) > int(contract[OsControls.ROLE_TAB]["height"]), "primary role preserves standard height while tabs remain more compact")
	_check(int(contract[OsControls.ROLE_LAUNCHER]["height"]) == 44, "launcher plate keeps the authored 44-unit footprint")
	_check(int(contract[OsControls.ROLE_HANDLE]["height"]) == 28 and int(contract[OsControls.ROLE_COMPACT]["height"]) == 28, "widget handles and compact controls preserve the 6B geometry contract")


func _test_state_styles() -> void:
	var palette: Dictionary = OsTokens.control_palette()
	for role: String in [OsControls.ROLE_STANDARD, OsControls.ROLE_PRIMARY, OsControls.ROLE_TAB, OsControls.ROLE_LAUNCHER, OsControls.ROLE_NAV, OsControls.ROLE_COMPACT, OsControls.ROLE_HANDLE, OsControls.ROLE_FOLD]:
		for state: String in OsControls.STATES:
			var style: StyleBoxTexture = OsControls.style_for(role, state, palette)
			_check(style.texture != null, role + " " + state + " has an engineered frame")
	var tab_normal: Color = _center(OsControls.style_for(OsControls.ROLE_TAB, "normal", palette))
	var tab_selected: Color = _center(OsControls.style_for(OsControls.ROLE_TAB, "pressed", palette))
	_check(not tab_normal.is_equal_approx(tab_selected), "selected tab has a distinct seated material")
	var primary_normal: Color = _center(OsControls.style_for(OsControls.ROLE_PRIMARY, "normal", palette))
	var standard_normal: Color = _center(OsControls.style_for(OsControls.ROLE_STANDARD, "normal", palette))
	_check(not primary_normal.is_equal_approx(standard_normal), "primary action is materially distinct from ordinary controls")
	var focus: StyleBoxTexture = OsControls.focus_style(OsControls.ROLE_STANDARD, palette)
	_check(_center(focus).a < 0.05, "focus treatment is an outline rather than a filled glow")


func _test_icon_contract() -> void:
	var contract: Dictionary = WorkspaceIcons.contract()
	_check(is_equal_approx(float(contract["stroke_width"]), 1.8), "icon family has one stroke weight")
	var kinds: Array = contract["kinds"]
	for kind: String in ["city", "work", "back", "fold_left", "fold_right", "fold_up", "fold_down", "zoom_in", "zoom_out", "reset", "move", "resize", "menu"]:
		_check(kinds.has(kind), kind + " belongs to the shared icon family")
		_check(WorkspaceIcons.texture(kind) != null, kind + " renders to a texture")


func _test_live_controls(tree: SceneTree) -> void:
	_cleanup()
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	app.set("auto_load", false)
	tree.root.add_child(app)
	await tree.process_frame
	await tree.process_frame
	var view: SkeletonView = app.get("view") as SkeletonView
	var session: SkeletonSession = app.get("session") as SkeletonSession
	var before: Dictionary = session.checkpoint()
	_check(OsControls.role_of(view.city_button) == OsControls.ROLE_LAUNCHER, "City uses launcher plate role")
	_check(OsControls.role_of(view.operations_button) == OsControls.ROLE_LAUNCHER, "Operations uses launcher plate role")
	_check(OsControls.role_of(view.work_button) == OsControls.ROLE_PRIMARY, "work execution uses primary action role")
	_check(OsControls.role_of(view.operations_work_tab) == OsControls.ROLE_TAB, "Operations Work uses tab role")
	_check(OsControls.role_of(view.record_activity_tab) == OsControls.ROLE_TAB, "Session Record Activity uses tab role")
	var work_widget: WidgetView = view.widget_workspace.widgets["work_scan"]
	_check(OsControls.role_of(work_widget.drag_handle) == OsControls.ROLE_HANDLE, "widget move affordance uses handle role")
	_check(OsControls.role_of(work_widget.resize_handle) == OsControls.ROLE_HANDLE, "widget resize affordance uses handle role")
	_check(OsControls.role_of(work_widget.menu_button) == OsControls.ROLE_COMPACT, "widget menu uses compact role")
	_check(work_widget.drag_handle.text.is_empty() and work_widget.drag_handle.icon != null, "move handle uses the icon kit instead of Unicode glyph text")
	_check(work_widget.resize_handle.text.is_empty() and work_widget.resize_handle.icon != null, "resize handle uses the icon kit instead of Unicode glyph text")
	_check(view.city_button.button_pressed, "City launcher is visibly selected at root")
	view.city.marker.pressed.emit()
	view.open_operations_button.pressed.emit()
	await tree.process_frame
	_check(view.operations_button.button_pressed and not view.city_button.button_pressed, "active app transfers launcher selection")
	_check(view.operations_work_tab.button_pressed and not view.operations_work_tab.disabled, "active app tab is selected rather than disabled")
	view.operations_record_tab.pressed.emit()
	await tree.process_frame
	_check(view.operations_record_tab.button_pressed, "Record tab receives selected material after navigation")
	_check(session.checkpoint() == before, "control styling and selection remain presentation-only")
	app.queue_free()
	await tree.process_frame
	_cleanup()


func _center(style: StyleBoxTexture) -> Color:
	var image: Image = style.texture.get_image()
	return image.get_pixel(image.get_width() / 2, image.get_height() / 2)


func _cleanup() -> void:
	for suffix: String in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(SLOT + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(SLOT + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("[control-tests] PASS: " + label)
	else:
		failures += 1
		push_error("[control-tests] FAIL: " + label)
