extends SceneTree

const RuntimeHealthScript = preload("res://game/core/debug/runtime_health.gd")

var failures: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("[tests] SIM-DURTY Foundation 0")

	_test_runtime_health()
	_test_main_scene_loads()

	if failures == 0:
		print("[tests] PASS")
		quit(0)
		return

	push_error("[tests] FAIL: %d failure(s)" % failures)
	quit(1)


func _test_runtime_health() -> void:
	var report: Dictionary = RuntimeHealthScript.foundation_report()

	_assert_true(bool(report.get("ok", false)), "runtime health reports OK")
	_assert_true(
		int(report.get("foundation_version", -1)) == 0,
		"runtime health reports Foundation 0"
	)


func _test_main_scene_loads() -> void:
	var packed_scene: PackedScene = load("res://game/app/main.tscn") as PackedScene
	_assert_true(packed_scene != null, "main scene resource loads")

	if packed_scene == null:
		return

	var instance: Node = packed_scene.instantiate()
	_assert_true(instance != null, "main scene instantiates")

	if instance != null:
		instance.free()


func _assert_true(condition: bool, label: String) -> void:
	if condition:
		print("[tests] PASS: %s" % label)
		return

	failures += 1
	push_error("[tests] FAIL: %s" % label)
