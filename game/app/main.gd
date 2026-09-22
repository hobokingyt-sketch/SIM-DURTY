extends Control


@onready var status_label: Label = %StatusLabel
@onready var build_label: Label = %BuildLabel
@onready var copy_debug_report_button: Button = %CopyDebugReportButton

var _debug_report_text: String = ""


func _ready() -> void:
	var report: Dictionary = RuntimeHealth.foundation_report()
	var build: Dictionary = BuildInfo.snapshot()
	var engine_version: String = str(report.get("engine_version", "unknown"))
	var build_id: String = str(build.get("build_id", "unknown"))
	var ref_name: String = str(build.get("ref_name", "unknown"))

	_debug_report_text = DebugReport.compose({
		"milestone": "Infrastructure 2",
		"save_schema": "none",
		"simulation_seed": "none",
		"simulation_tick": "none",
	})

	status_label.text = "INFRASTRUCTURE 2\nGodot %s\nHEALTHY" % engine_version
	build_label.text = "Build: %s\nRef: %s" % [build_id, ref_name]
	copy_debug_report_button.pressed.connect(_copy_debug_report)

	print("[SIM-DURTY] Infrastructure 2 boot OK | build=%s" % build_id)
	print(_debug_report_text)


func _copy_debug_report() -> void:
	DisplayServer.clipboard_set(_debug_report_text)
	copy_debug_report_button.text = "DEBUG REPORT COPIED"
