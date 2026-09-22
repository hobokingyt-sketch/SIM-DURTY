class_name WidgetView
extends Panel

signal inspect_requested(work_id: String)
signal record_requested
signal manipulation_requested(id: String, kind: String, point: Vector2)
signal key_requested(id: String, kind: String, direction: int, transfer: bool)
signal option_requested(id: String, option: int)
signal menu_requested(id: String)
var widget_id: String
var drag_handle: WidgetHandle
var resize_handle: WidgetHandle
var menu_button: MenuButton
var inspect_button: Button
var primary: Label
var secondary: Label
var details: Label
var effective_form: String = "compact"
var _body: BoxContainer
var _identity: VBoxContainer
var _work_id: String = ""
var _work_name: String = "No work available"
var _payout: int = 0
var _minutes: int = 0
var _completed: int = 0
var _available: bool = false
var _selected: bool = false
var _events: Array[Dictionary] = []


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_force_pass_scroll_events = false
	add_theme_stylebox_override("panel", OsFrames.frame_style(OsFrames.ROLE_WIDGET, OsTokens.WELL, 0, OsTokens.frame_palette()))
	OsMaterials.apply_diffuse(self, OsMaterials.ROLE_WELL, "widget-" + widget_id)
	OsFrames.attach_overlay(self, OsFrames.ROLE_WIDGET, OsTokens.frame_palette())
	var inset: MarginContainer = MarginContainer.new()
	add_child(inset)
	inset.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		inset.add_theme_constant_override("margin_" + side, 10)
	var stack: VBoxContainer = OsTokens.column(inset, 8)
	var header: HBoxContainer = OsTokens.row(stack, 6)
	drag_handle = _handle(header, "move")
	var title: Label = OsTokens.label(header, str(WidgetLayout.TITLES[widget_id]), 15, OsTokens.MUTED)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	resize_handle = _handle(header, "resize")
	menu_button = MenuButton.new()
	menu_button.text = "⋯"
	_small_button(menu_button)
	header.add_child(menu_button)
	menu_button.tooltip_text = "Widget position and size"
	menu_button.accessibility_name = str(WidgetLayout.TITLES[widget_id]) + " options"
	var menu: PopupMenu = menu_button.get_popup()
	menu.add_item("Move to workbench", 0)
	menu.add_item("Move to right rail", 1)
	menu.add_item("Move earlier", 2)
	menu.add_item("Move later", 3)
	menu.add_separator()
	for index: int in range(WidgetLayout.FORMS.size()):
		menu.add_item(WidgetLayout.FORMS[index].capitalize(), 10 + index)
	menu.about_to_popup.connect(func() -> void: menu_requested.emit(widget_id))
	menu.id_pressed.connect(func(option: int) -> void: option_requested.emit(widget_id, option))
	_body = BoxContainer.new()
	_body.add_theme_constant_override("separation", 12)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(_body)
	_identity = OsTokens.column(_body, 6)
	_identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	primary = OsTokens.label(_identity, "", 18)
	primary.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	secondary = OsTokens.label(_identity, "", 15, OsTokens.ACCENT)
	secondary.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	details = OsTokens.wrapped(_identity, "", 16, OsTokens.MUTED)
	details.max_lines_visible = 6
	details.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	inspect_button = Button.new()
	_small_button(inspect_button)
	inspect_button.text = "Inspect" if widget_id == "work_scan" else "Record"
	inspect_button.custom_minimum_size.y = 34
	inspect_button.size_flags_vertical = Control.SIZE_SHRINK_END
	_body.add_child(inspect_button)
	inspect_button.pressed.connect(func() -> void:
		if widget_id == "work_scan": inspect_requested.emit(_work_id)
		else: record_requested.emit())
	apply_form("compact")


func _handle(parent: Node, kind: String) -> WidgetHandle:
	var handle: WidgetHandle = WidgetHandle.new()
	handle.widget_id = widget_id
	handle.kind = kind
	_small_button(handle)
	parent.add_child(handle)
	handle.manipulation_requested.connect(func(id: String, type: String, point: Vector2) -> void: manipulation_requested.emit(id, type, point))
	handle.key_requested.connect(func(id: String, type: String, direction: int, transfer: bool) -> void: key_requested.emit(id, type, direction, transfer))
	return handle


static func _small_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(28, 28)
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_stylebox_override("normal", OsFrames.frame_style(OsFrames.ROLE_CONTROL, OsTokens.RAISED, 5, OsTokens.frame_palette()))
	button.add_theme_stylebox_override("hover", OsFrames.frame_style(OsFrames.ROLE_CONTROL, OsTokens.RAISED_HOVER, 5, OsTokens.frame_palette()))
	button.add_theme_stylebox_override("pressed", OsFrames.frame_style(OsFrames.ROLE_CONTROL, OsTokens.RAISED_PRESSED, 5, OsTokens.frame_palette()))
	button.add_theme_stylebox_override("disabled", OsFrames.frame_style(OsFrames.ROLE_CONTROL, OsTokens.DISABLED, 5, OsTokens.frame_palette()))
	button.mouse_force_pass_scroll_events = false


func bind_work(definition: SkeletonWorkDefinition) -> void:
	_work_id = String(definition.activity_id)
	_work_name = definition.display_name
	_payout = definition.payout_cents
	_minutes = definition.duration_minutes
	_render()


func bind_state(state: Dictionary, available: bool) -> void:
	_completed = int(state["completed_actions"])
	_available = available
	_render()


func bind_events(events: Array[Dictionary]) -> void:
	_events = events.duplicate(true)
	_render()


func set_selected(id: String) -> void:
	_selected = not id.is_empty() and id == _work_id
	_render()


func apply_form(form: String) -> void:
	effective_form = form
	_body.vertical = form == "tall"
	details.visible = form in ["tall", "major"]
	primary.add_theme_font_size_override("font_size", 22 if form == "major" else 18)
	primary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if form in ["tall", "major"] else TextServer.AUTOWRAP_OFF
	primary.max_lines_visible = 2 if form in ["tall", "major"] else 1
	_render()


func _render() -> void:
	if not is_instance_valid(primary): return
	if widget_id == "work_scan":
		primary.text = _work_name
		primary.tooltip_text = _work_name
		secondary.text = "$%d.%02d · %d min" % [_payout / 100, _payout % 100, _minutes]
		details.text = "%s\n%d completed this save\nOpens Operations" % ["Selected work" if _selected else ("Available" if _available else "Unavailable"), _completed]
		inspect_button.disabled = _work_id.is_empty()
	else:
		primary.text = "No recent activity" if _events.is_empty() else _event_title(_events.back())
		secondary.text = "Current session only" if _events.is_empty() else "Minute %d · #%d" % [_events.back()["tick"], _events.back()["sequence"]]
		var lines: PackedStringArray = []
		var count: int = 4 if effective_form == "major" else 2
		for index: int in range(maxi(0, _events.size() - count - 1), maxi(0, _events.size() - 1)):
			lines.append("%s · %dm" % [_event_title(_events[index]), _events[index]["tick"]])
		details.text = "No earlier local events." if lines.is_empty() else "\n".join(lines)
	primary.tooltip_text = primary.text


static func _event_title(event: Dictionary) -> String:
	match str(event.get("type", "")):
		"work": return "Errand completed"
		"advance": return "Time advanced"
		"rng_probe": return "Test draw"
	return "Session updated"
