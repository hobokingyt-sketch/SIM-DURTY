extends SceneTree

const RuntimeHealthScript = preload("res://game/core/debug/runtime_health.gd")
const BuildInfoScript = preload("res://game/core/build/build_info.gd")
const DebugReportScript = preload("res://game/core/debug/debug_report.gd")
const SkeletonTests = preload("res://tests/skeleton_tests.gd")

var failures: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("[tests] SIM-DURTY Walking Skeleton")
	_test_runtime_health()
	_test_build_info_contract()
	_test_debug_report_contract()
	_test_main_scene_loads()
	var suite: RefCounted = SkeletonTests.new()
	failures += await suite.run(self)
	if failures == 0:
		print("[tests] PASS")
		quit(0)
		return
	push_error("[tests] FAIL: %d failure(s)" % failures)
	quit(1)


func _test_runtime_health() -> void:
	var report: Dictionary = RuntimeHealthScript.foundation_report()
	_assert_true(bool(report.get("ok", false)), "runtime health reports OK")
	_assert_true(int(report.get("foundation_version", -1)) == 0, "runtime health preserves Foundation 0 contract")


func _test_build_info_contract() -> void:
	var info: Dictionary = BuildInfoScript.snapshot()
	_assert_true(not str(info.get("build_id", "")).is_empty(), "build info always has a build ID")
	_assert_true(not str(info.get("game_version", "")).is_empty(), "build info exposes game version")
	_assert_true(not str(info.get("engine_version", "")).is_empty(), "build info exposes engine version")


func _test_debug_report_contract() -> void:
	var report: String = DebugReportScript.compose({"milestone": "Walking Skeleton"})
	_assert_true(report.contains("SIM-DURTY DEBUG REPORT"), "debug report has stable header")
	_assert_true(report.contains("build_id:"), "debug report contains build identity")
	_assert_true(report.contains("simulation_tick: none"), "debug report does not invent a simulation clock")


func _test_main_scene_loads() -> void:
	var packed_scene: PackedScene = load("res://game/app/main.tscn") as PackedScene
	_assert_true(packed_scene != null, "main scene resource loads")
	if packed_scene != null:
		var instance: Node = packed_scene.instantiate()
		_assert_true(instance != null, "main scene instantiates")
		if instance != null:
			instance.free()


func _assert_true(condition: bool, label: String) -> void:
	if condition:
		print("[tests] PASS: %s" % label)
	else:
		failures += 1
		push_error("[tests] FAIL: %s" % label)
