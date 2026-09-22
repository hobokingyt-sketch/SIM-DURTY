extends RefCounted

const MAIN: PackedScene = preload("res://game/app/main.tscn")
const SLOT: String = "user://_tests_material/slot.json"
var failures: int = 0
var checks: int = 0


func run(tree: SceneTree) -> int:
	_test_palette_contract()
	_test_material_contract()
	await _test_live_surfaces(tree)
	print("[material-tests] %d checks, %d failures" % [checks, failures])
	return failures


func _test_palette_contract() -> void:
	_check(_luminance(OsTokens.CHASSIS) < _luminance(OsTokens.WELL), "chassis is deeper than recessed well")
	_check(_luminance(OsTokens.WELL) < _luminance(OsTokens.SURFACE), "recessed well is deeper than primary surface")
	_check(_luminance(OsTokens.SURFACE) < _luminance(OsTokens.RAISED), "raised controls sit above surfaces")
	_check(_luminance(OsTokens.ACCENT) > _luminance(OsTokens.RAISED), "warm accent remains visibly stronger than graphite controls")
	_check(OsTokens.TEXT.get_luminance() > OsTokens.MUTED.get_luminance(), "primary text remains brighter than muted text")


func _test_material_contract() -> void:
	var contract: Dictionary = OsMaterials.contract()
	_check(float(contract["grain_strength"]) <= 0.01, "fine grain remains restrained")
	_check(float(contract["grain_strength"]) >= 0.007, "fine grain remains visible after R4 calibration")
	_check(float(contract["mottle_strength"]) <= 0.02, "broad mottling remains restrained")
	_check(float(contract["mottle_strength"]) >= 0.016, "broad mottling remains visible after R4 calibration")
	_check((contract["roles"] as Array).size() == 3, "material kit exposes only the current three depth roles")
	_check(OsMaterials.DIFFUSE_SHADER != null, "diffuse shader resource loads")


func _test_live_surfaces(tree: SceneTree) -> void:
	var app: Control = MAIN.instantiate() as Control
	app.set("save_path", SLOT)
	app.set("auto_load", false)
	tree.root.add_child(app)
	await tree.process_frame
	await tree.process_frame
	var view: SkeletonView = app.get("view") as SkeletonView
	_check(OsMaterials.has_diffuse_material(view.chassis_surface), "root chassis carries the diffuse material")
	for side: String in ["LeftRail", "RightRail", "TopRail", "BottomRail"]:
		var rail: CanvasItem = view.workspace.get_node_or_null(side) as CanvasItem
		_check(is_instance_valid(rail) and OsMaterials.has_diffuse_material(rail), side + " carries the shared diffuse material")
	_check(OsMaterials.has_diffuse_material(view.center_app_surface), "center app surface carries recessed material")
	_check(OsMaterials.has_diffuse_material(view.right_app_surface), "rail app surface carries recessed material")
	for widget: WidgetView in view.widget_workspace.widgets.values():
		_check(OsMaterials.has_diffuse_material(widget), widget.widget_id + " carries recessed widget material")
	var before: Dictionary = (app.get("session") as SkeletonSession).checkpoint()
	await tree.process_frame
	_check((app.get("session") as SkeletonSession).checkpoint() == before, "material rendering is presentation-only")
	app.queue_free()
	await tree.process_frame
	_cleanup()


func _luminance(color: Color) -> float:
	return color.get_luminance()


func _cleanup() -> void:
	for suffix: String in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(SLOT + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(SLOT + suffix))


func _check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("[material-tests] PASS: " + label)
	else:
		failures += 1
		push_error("[material-tests] FAIL: " + label)
