class_name SkeletonView
extends Control

signal work_requested
signal save_requested
signal load_requested
signal reset_requested
signal debug_report_requested
signal advance_requested(minutes: int)
signal sample_requested
signal inspection_requested
signal recovery_requested

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
var developer_toggle: Button
var developer_scroll: ScrollContainer
var recovery_button: Button
var recovery_hint: Label
var _recovery_row: VBoxContainer


func _ready() -> void:
	work_button.pressed.connect(func() -> void: work_requested.emit())
	save_button.pressed.connect(func() -> void: save_requested.emit())
	load_button.pressed.connect(func() -> void: load_requested.emit())
	reset_button.pressed.connect(func() -> void: reset_requested.emit())
	copy_button.pressed.connect(func() -> void: debug_report_requested.emit())
	var stack: VBoxContainer = get_node("Center/Panel/Margin/Stack") as VBoxContainer
	(stack.get_node("Header/Phase") as Label).text = "PERSISTENCE / TOOLS"
	(stack.get_node("Intro") as Label).text = "One activity. Save and continue."
	(stack.get_node("PrototypeNote") as Label).text = "Test values. Manual saving. Developer tools are optional."
	developer_scroll = ScrollContainer.new()
	developer_scroll.custom_minimum_size = Vector2(0, 300)
	developer_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	developer_scroll.visible = false
	stack.add_child(developer_scroll)
	stack.move_child(developer_scroll, stack.get_node("Divider2").get_index())
	spine_panel = SpinePanel.new()
	spine_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	developer_scroll.add_child(spine_panel)
	spine_panel.advance_requested.connect(func(minutes: int) -> void: advance_requested.emit(minutes))
	spine_panel.sample_requested.connect(func() -> void: sample_requested.emit())
	developer_toggle = Button.new()
	developer_toggle.text = "Developer tools"
	developer_toggle.toggle_mode = true
	developer_toggle.add_theme_font_size_override("font_size", 22)
	var footer: HBoxContainer = stack.get_node("Footer") as HBoxContainer
	footer.add_child(developer_toggle)
	footer.move_child(developer_toggle, copy_button.get_index())
	developer_toggle.toggled.connect(_toggle_tools)
	_recovery_row = VBoxContainer.new()
	_recovery_row.add_theme_constant_override("separation", 12)
	_recovery_row.visible = false
	stack.add_child(_recovery_row)
	stack.move_child(_recovery_row, status_label.get_index())
	recovery_hint = Label.new()
	recovery_hint.add_theme_font_size_override("font_size", 22)
	recovery_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_recovery_row.add_child(recovery_hint)
	recovery_button = Button.new()
	recovery_button.text = "Recover previous save"
	recovery_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_recovery_row.add_child(recovery_button)
	recovery_button.pressed.connect(func() -> void: recovery_requested.emit())


func _toggle_tools(opened: bool) -> void:
	developer_scroll.visible = opened
	if opened:
		inspection_requested.emit()


func configure_work(definition: SkeletonWorkDefinition) -> void:
	%WorkName.text = definition.display_name
	%WorkTerms.text = "+%s  /  %d minutes" % [money_text(definition.payout_cents), definition.duration_minutes]
	work_button.text = definition.display_name


func show_storage(info: Dictionary) -> void:
	var available: bool = bool(info.get("can_recover", false))
	_recovery_row.visible = available
	recovery_button.disabled = not available
	if available:
		var backup: Dictionary = info["backup"]
		recovery_hint.text = "Previous save: %s, %d completed. Recovery replaces this live session; the original file is kept." % [
			money_text(int(backup["cash_cents"])), int(backup["completed_actions"]),
		]


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
