extends RefCounted

const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_visual_calibration/slot.json"
var failures: int = 0
var checks: int = 0


func run(tree: SceneTree) -> int:
	_test_palette_balance()
	_test_accent_economy()
	_test_texture_balance()
	await _test_live_calibration(tree)
	print("[visual-calibration-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_palette_balance() -> void:
	var contract: Dictionary = OsVisualCalibration.contract()
	var surfaces: Array = contract["surface_order"]
	for index: int in range(surfaces.size() - 1):
		var a: Color = surfaces[index]
		var b: Color = surfaces[index + 1]
		_check(OsVisualCalibration.luminance(a) < OsVisualCalibration.luminance(b), "surface depth remains ordered at step %d" % index)
	_check(OsVisualCalibration.luminance(OsTokens.APP_WELL) > OsVisualCalibration.luminance(Color("16191b")), "app well is calibrated to charcoal rather than near-black")
	_check(OsVisualCalibration.luminance(OsTokens.RAIL_SURFACE) - OsVisualCalibration.luminance(OsTokens.APP_WELL) < 0.06, "rail-to-app contrast remains material rather than theatrical")
	_check(OsVisualCalibration.luminance(OsTokens.WIDGET_SURFACE) > OsVisualCalibration.luminance(OsTokens.WORKBENCH_WELL), "widgets remain mounted above the workbench well")
	_check(OsVisualCalibration.luminance(OsTokens.TEXT) > OsVisualCalibration.luminance(OsTokens.MUTED), "primary and muted text hierarchy remains intact")


func _test_accent_economy() -> void:
	var contract: Dictionary = OsVisualCalibration.contract()
	var accent: Color = contract["accent"]
	var selected: Color = contract["selected_face"]
	var primary: Color = contract["primary_face"]
	var icon: Color = contract["icon"]
	var text: Color = contract["text"]
	_check(OsVisualCalibration.luminance(selected) < OsVisualCalibration.luminance(accent) * 0.6, "selected control face remains dark beneath brass edge")
	_check(OsVisualCalibration.luminance(primary) < OsVisualCalibration.luminance(accent) * 0.65, "primary action remains dark bronze beneath brass edge")
	_check(OsVisualCalibration.luminance(icon) < OsVisualCalibration.luminance(text), "ordinary icons are quieter than primary text")
	_check(OsVisualCalibration.luminance(icon) > OsVisualCalibration.luminance(OsTokens.MUTED), "ordinary icons remain readable above muted copy")


func _test_texture_balance() -> void:
	var contract: Dictionary = OsVisualCalibration.contract()
	_check(float(contract["grain_strength"]) >= 0.007 and float(contract["grain_strength"]) <= 0.01, "grain lives in the calibrated restrained band")
	_check(float(contract["mottle_strength"]) >= 0.016 and float(contract["mottle_strength"]) <= 0.02, "mottling lives in the calibrated restrained band")
	_check(float(contract["mottle_strength"]) > float(contract["grain_strength"]), "diffuse material is led by soft mottling rather than harsh grain")


func _test_live_calibration(tree: SceneTree) -> void:
	_cleanup()
	var old_size: Vector2i = tree.root.size
	tree.root.size = Vector2i(2560, 1440)
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	app.set("auto_load", false)
	tree.root.add_child(app)
	await _frames(tree)
	var view: SkeletonView = app.get("view") as SkeletonView
	var session: SkeletonSession = app.get("session") as SkeletonSession
	var gameplay_before: Dictionary = session.checkpoint()
	var workspace_before: Dictionary = view.workspace.model.snapshot()
	var widgets_before: Dictionary = view.widget_workspace.snapshot()

	_check(OsDepth.fill(OsDepth.ROLE_APP_WELL).is_equal_approx(OsTokens.APP_WELL), "Operations and rail apps consume the calibrated app well")
	_check(OsDepth.fill(OsDepth.ROLE_WORKBENCH_WELL).is_equal_approx(OsTokens.WORKBENCH_WELL), "Workbench consumes the calibrated well")
	_check(OsDepth.fill(OsDepth.ROLE_WIDGET).is_equal_approx(OsTokens.WIDGET_SURFACE), "widgets consume the calibrated raised surface")
	_check(OsMaterials.has_diffuse_material(view.center_app_surface), "Operations retains the shared diffuse material")
	_check(OsMaterials.has_diffuse_material(view._bottom_widget_dock), "Workbench retains the shared diffuse material")
	_check(view.workspace.model.snapshot() == workspace_before, "R4 does not change rail geometry or preferences")
	_check(view.widget_workspace.snapshot() == widgets_before, "R4 does not change widget form or placement")
	_check(session.checkpoint() == gameplay_before, "R4 remains presentation-only")

	app.queue_free()
	await _frames(tree)
	tree.root.size = old_size
	_cleanup()


func _frames(tree: SceneTree) -> void:
	for index: int in range(4):
		await tree.process_frame


func _cleanup() -> void:
	for path: String in [SLOT, WorkspacePreferences.path_for_slot(SLOT), WidgetWorkspace.profile_path(SLOT)]:
		for suffix: String in ["", ".tmp", ".bak"]:
			if FileAccess.file_exists(path + suffix):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("[visual-calibration-tests] PASS: " + label)
	else:
		failures += 1
		push_error("[visual-calibration-tests] FAIL: " + label)
