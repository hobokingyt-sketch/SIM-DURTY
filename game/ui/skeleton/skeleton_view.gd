class_name SkeletonView
extends Control

signal work_requested
signal save_requested
signal load_requested
signal reset_requested
signal debug_report_requested
signal advance_requested(minutes: int)
signal sample_requested

@onready var cash_label: Label = %CashValue
@onready var time_label: Label = %TimeValue
@onready var count_label: Label = %CountValue
@onready var work_button: Button = %WorkButton
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var reset_button: Button = %ResetButton
@onready var copy_button: Button = %CopyButton
@onready var status_label: Label = %StatusLabel
@onready var dirty_label: Label = %DirtyLabel
var spine_panel: SpinePanel


func _ready() -> void:
	work_button.pressed.connect(func() -> void: work_requested.emit())
	save_button.pressed.connect(func() -> void: save_requested.emit())
	load_button.pressed.connect(func() -> void: load_requested.emit())
	reset_button.pressed.connect(func() -> void: reset_requested.emit())
	copy_button.pressed.connect(func() -> void: debug_report_requested.emit())
	var stack: VBoxContainer = get_node("Center/Panel/Margin/Stack") as VBoxContainer
	(stack.get_node("Header/Phase") as Label).text = "SIMULATION SPINE"
	(stack.get_node("Intro") as Label).text = "One activity. Controlled time. Repeatable state."
	(stack.get_node("PrototypeNote") as Label).text = "Time advances through actions or explicit steps. No offline progress."
	spine_panel = SpinePanel.new()
	stack.add_child(spine_panel)
	stack.move_child(spine_panel, stack.get_node("Divider2").get_index())
	spine_panel.advance_requested.connect(func(minutes: int) -> void: advance_requested.emit(minutes))
	spine_panel.sample_requested.connect(func() -> void: sample_requested.emit())


func configure_work(definition: SkeletonWorkDefinition) -> void:
	%WorkName.text = definition.display_name
	%WorkTerms.text = "+%s  /  %d minutes" % [money_text(definition.payout_cents), definition.duration_minutes]
	work_button.text = definition.display_name


func show_state(state: Dictionary, work_available: bool, dirty: bool) -> void:
	cash_label.text = money_text(int(state["cash_cents"]))
	var clock_minutes: int = 480 + int(state["elapsed_minutes"])
	time_label.text = "Day %d · %02d:%02d" % [
		1 + floori(clock_minutes / 1440.0), floori((clock_minutes % 1440) / 60.0), clock_minutes % 60,
	]
	count_label.text = str(state["completed_actions"])
	work_button.disabled = not work_available
	dirty_label.text = "Unsaved session" if dirty else "Matches saved slot"


func show_status(message: String, is_error: bool = false) -> void:
	status_label.text = message
	status_label.modulate = Color(1.0, 0.65, 0.55) if is_error else Color(0.77, 0.8, 0.82)


func show_build(build: Dictionary) -> void:
	%BuildLabel.text = "v%s  ·  %s" % [build["game_version"], build["build_id"]]


static func money_text(cents: int) -> String:
	return "$%d.%02d" % [floori(cents / 100.0), cents % 100]
