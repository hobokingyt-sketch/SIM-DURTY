extends Control


@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	var report: Dictionary = RuntimeHealth.foundation_report()
	var engine_version: String = str(report.get("engine_version", "unknown"))

	status_label.text = "FOUNDATION 0\nGodot %s\nHEALTHY" % engine_version
	print("[SIM-DURTY] Foundation 0 boot OK | Godot %s" % engine_version)
