class_name CriminalOsShell
extends Control

# Presentation boundary retained by the SkeletonView compatibility adapter.
signal work_requested
signal save_requested
signal load_requested
signal reset_requested
signal debug_report_requested
signal advance_requested(minutes: int)
signal sample_requested
signal inspection_requested
signal recovery_requested

var cash_label: Label
var time_label: Label
var count_label: Label
var work_button: Button
var save_button: Button
var load_button: Button
var reset_button: Button
var copy_button: Button
var status_label: Label
var dirty_label: Label
var spine_panel: SpinePanel
var developer_toggle: Button
var developer_scroll: ScrollContainer
var recovery_button: Button
var recovery_hint: Label
var city: CityBlockout
var inspect_button: Button
var open_operations_button: Button
var close_operations_button: Button
var city_button: Button
var operations_button: Button
var glance_toggle: Button
var record_toggle: Button
var record_scroll: ScrollContainer
var record_label: Label
var context_title: Label
var status_kind: Label

var _model: OsPresentationState = OsPresentationState.new()
var _left: VBoxContainer
var _glance_scroll: ScrollContainer
var _context: VBoxContainer
var _operations: VBoxContainer
var _recovery_row: VBoxContainer
var _context_terms: Label
var _context_body: Label
var _scan_title: Label
var _scan_terms: Label
var _availability: Label
var _operation_title: Label
var _operation_terms: Label
var _build_label: Label
var _selection_label: Label
var _work_id: String = ""
var _work_name: String = ""
var _terms: String = ""
var _message_error: bool = false
var _storage_alert: bool = false


func _ready() -> void:
	theme = OsTokens.make_theme()
	var backdrop: ColorRect = ColorRect.new()
	backdrop.color = OsTokens.BACKGROUND
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin: MarginContainer = MarginContainer.new()
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	var root: VBoxContainer = OsTokens.column(margin, 16)
	_build_header(root)
	var body: HBoxContainer = OsTokens.row(root, 16)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_glance(body)
	_build_city(body)
	_build_context_and_operations(body)
	_build_recovery(root)
	_build_drawers(root)
	_build_footer(root)
	_model.changed.connect(_apply_navigation)
	_apply_navigation()


func _build_header(parent: Node) -> void:
	var row: HBoxContainer = OsTokens.row(parent, 24)
	row.custom_minimum_size.y = 80
	var brand: VBoxContainer = OsTokens.column(row, 0)
	OsTokens.label(brand, "SIM-DURTY", 36)
	OsTokens.label(brand, "CITY DESK  /  OS SKELETON", 20, OsTokens.ACCENT)
	OsTokens.spacer(row)
	city_button = OsTokens.button(row, "City", func() -> void: _model.open_app("city"))
	city_button.toggle_mode = true
	operations_button = OsTokens.button(row, "Operations", open_operations)
	operations_button.toggle_mode = true
	glance_toggle = OsTokens.button(row, "Glance", Callable())
	glance_toggle.toggle_mode = true
	glance_toggle.set_pressed_no_signal(true)
	glance_toggle.toggled.connect(func(opened: bool) -> void: _model.set_glance_open(opened))
	OsTokens.spacer(row)
	time_label = OsTokens.label(row, "Day 1 · 08:00", 30)
	time_label.tooltip_text = "Time advances through commands. No automatic or offline progress."


func _build_glance(parent: Node) -> void:
	# Bound the rail independently: opening a drawer must never push Save off-screen.
	_glance_scroll = ScrollContainer.new()
	_glance_scroll.custom_minimum_size.x = 350
	_glance_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_glance_scroll.mouse_force_pass_scroll_events = false
	parent.add_child(_glance_scroll)
	_left = OsTokens.column(_glance_scroll, 16)
	_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var money: VBoxContainer = OsTokens.card(_left)
	OsTokens.label(money, "ON HAND", 22, OsTokens.MUTED)
	cash_label = OsTokens.label(money, "$10.00", 52)
	dirty_label = OsTokens.label(money, "Unsaved session", 22, OsTokens.MUTED)
	var scan: VBoxContainer = OsTokens.card(_left)
	OsTokens.label(scan, "Work Scan", 30)
	_availability = OsTokens.wrapped(scan, "Checking work", 22, OsTokens.ACCENT)
	_scan_title = OsTokens.wrapped(scan, "", 28, OsTokens.TEXT)
	_scan_terms = OsTokens.label(scan, "", 24, OsTokens.MUTED)
	inspect_button = OsTokens.button(scan, "Inspect work", func() -> void: select_work(_work_id))
	var activity: VBoxContainer = OsTokens.card(_left)
	OsTokens.label(activity, "COMPLETED", 22, OsTokens.MUTED)
	count_label = OsTokens.label(activity, "0", 40)
	OsTokens.label(activity, "Errands this save", 22, OsTokens.MUTED)
	var space: Control = Control.new()
	space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_left.add_child(space)
	OsTokens.wrapped(_left, "City layout preview. The errand is the only working activity.", 22)


func _build_city(parent: Node) -> void:
	var workspace: VBoxContainer = OsTokens.column(parent, 16)
	workspace.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var heading: HBoxContainer = OsTokens.row(workspace)
	var titles: VBoxContainer = OsTokens.column(heading, 2)
	OsTokens.label(titles, "City", 36)
	OsTokens.label(titles, "Authored blockout · not a live city yet", 22, OsTokens.MUTED)
	OsTokens.spacer(heading)
	OsTokens.button(heading, "−", func() -> void: city.zoom_at(1.0 / 1.2, city.size * 0.5))
	OsTokens.button(heading, "+", func() -> void: city.zoom_at(1.2, city.size * 0.5))
	OsTokens.button(heading, "Reset view", func() -> void: city.reset_camera())
	city = CityBlockout.new()
	city.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	city.size_flags_vertical = Control.SIZE_EXPAND_FILL
	workspace.add_child(city)
	city.work_selected.connect(select_work)
	city.selection_cleared.connect(clear_selection)
	var foot: HBoxContainer = OsTokens.row(workspace)
	_selection_label = OsTokens.label(foot, "Nothing selected", 22, OsTokens.ACCENT)
	OsTokens.spacer(foot)
	OsTokens.label(foot, "Wheel: zoom  ·  Right-drag: pan", 20, OsTokens.MUTED)


func _build_context_and_operations(parent: Node) -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size.x = 520
	parent.add_child(panel)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.mouse_force_pass_scroll_events = false
	panel.add_child(scroll)
	var stack: VBoxContainer = OsTokens.column(scroll, 24)
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_context = OsTokens.column(stack, 24)
	var heading: HBoxContainer = OsTokens.row(_context)
	OsTokens.label(heading, "CONTEXT", 22, OsTokens.ACCENT)
	OsTokens.spacer(heading)
	OsTokens.button(heading, "Clear", clear_selection)
	context_title = OsTokens.wrapped(_context, "Select work", 36, OsTokens.TEXT)
	_context_terms = OsTokens.label(_context, "", 28, OsTokens.ACCENT)
	_context_body = OsTokens.wrapped(_context, "Inspect an opportunity from Work Scan or select its city location.")
	open_operations_button = OsTokens.button(_context, "Open Operations", open_operations)
	_operations = OsTokens.column(stack, 24)
	var app_header: HBoxContainer = OsTokens.row(_operations)
	OsTokens.label(app_header, "OPERATIONS", 22, OsTokens.ACCENT)
	OsTokens.spacer(app_header)
	close_operations_button = OsTokens.button(app_header, "Close", func() -> void: _model.open_app("city"))
	_operation_title = OsTokens.wrapped(_operations, "", 36, OsTokens.TEXT)
	_operation_terms = OsTokens.label(_operations, "", 28, OsTokens.ACCENT)
	OsTokens.wrapped(_operations, "Carry out the selected work.")
	work_button = OsTokens.button(_operations, "Run an errand", func() -> void: work_requested.emit())
	work_button.add_theme_stylebox_override("normal", OsTokens.box(Color("574b37"), 18))
	work_button.add_theme_stylebox_override("hover", OsTokens.box(Color("6c5b3f"), 18))
	work_button.custom_minimum_size.y = 72
	OsTokens.wrapped(_operations, "Prototype terms only. Crew, travel and risk are not active yet.", 22)


func _build_recovery(parent: Node) -> void:
	_recovery_row = OsTokens.column(parent, 10)
	_recovery_row.visible = false
	recovery_hint = OsTokens.wrapped(_recovery_row, "", 22, OsTokens.ERROR)
	recovery_button = OsTokens.button(_recovery_row, "Recover previous save", func() -> void: recovery_requested.emit())
	recovery_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN


func _build_drawers(parent: Node) -> void:
	developer_scroll = ScrollContainer.new()
	developer_scroll.custom_minimum_size.y = 300
	developer_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	developer_scroll.visible = false
	parent.add_child(developer_scroll)
	var contents: VBoxContainer = OsTokens.column(developer_scroll)
	contents.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spine_panel = SpinePanel.new()
	contents.add_child(spine_panel)
	spine_panel.advance_requested.connect(func(minutes: int) -> void: advance_requested.emit(minutes))
	spine_panel.sample_requested.connect(func() -> void: sample_requested.emit())
	reset_button = OsTokens.button(contents, "Reset session", func() -> void: reset_requested.emit())
	reset_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	reset_button.tooltip_text = "Resets the live session only. Your saved slot is untouched."
	record_scroll = ScrollContainer.new()
	record_scroll.custom_minimum_size.y = 220
	record_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	record_scroll.visible = false
	parent.add_child(record_scroll)
	var records: VBoxContainer = OsTokens.column(record_scroll, 12)
	records.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	OsTokens.label(records, "RECENT ACTIVITY", 22, OsTokens.ACCENT)
	record_label = OsTokens.wrapped(records, "No events since this session was loaded or reset.", 24, OsTokens.TEXT)
	OsTokens.label(records, "Current session only · retained save history is not implemented", 20, OsTokens.MUTED)


func _build_footer(parent: Node) -> void:
	var status: HBoxContainer = OsTokens.row(parent)
	status_kind = OsTokens.label(status, "UPDATE", 22, OsTokens.ACCENT)
	status_label = OsTokens.wrapped(status, "", 24, OsTokens.TEXT)
	status_label.custom_minimum_size.y = 58
	var controls: HBoxContainer = OsTokens.row(parent, 16)
	_build_label = OsTokens.label(controls, "Local development", 20, OsTokens.MUTED)
	_build_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button = OsTokens.button(controls, "Save", func() -> void: save_requested.emit())
	load_button = OsTokens.button(controls, "Load", func() -> void: load_requested.emit())
	record_toggle = OsTokens.button(controls, "Recent activity", Callable())
	record_toggle.toggle_mode = true
	record_toggle.toggled.connect(_toggle_record)
	developer_toggle = OsTokens.button(controls, "Developer tools", Callable())
	developer_toggle.toggle_mode = true
	developer_toggle.toggled.connect(_toggle_tools)
	copy_button = OsTokens.button(controls, "Copy report", func() -> void: debug_report_requested.emit())


func configure_work(definition: SkeletonWorkDefinition) -> void:
	_work_id = String(definition.activity_id)
	_work_name = definition.display_name
	_terms = "+%s  /  %d minutes" % [money_text(definition.payout_cents), definition.duration_minutes]
	_scan_title.text = _work_name
	_scan_terms.text = _terms
	_operation_title.text = _work_name
	_operation_terms.text = _terms
	work_button.text = _work_name
	city.configure(_work_id, _work_name)
	_model.configure(_work_id)


func select_work(work_id: String) -> Error:
	return _model.select_work(work_id)


func clear_selection() -> void:
	_model.clear_selection()


func open_operations() -> void:
	_model.open_app("operations")


func _apply_navigation() -> void:
	var state: Dictionary = _model.snapshot()
	var selected: bool = not str(state["selected_id"]).is_empty()
	var operations_open: bool = state["active_app"] == "operations"
	_context.visible = not operations_open
	_operations.visible = operations_open
	_glance_scroll.visible = state["glance_open"]
	glance_toggle.set_pressed_no_signal(state["glance_open"])
	city_button.set_pressed_no_signal(not operations_open)
	operations_button.set_pressed_no_signal(operations_open)
	city.set_selected(selected)
	context_title.text = _work_name if selected else "Select work"
	_context_terms.text = _terms if selected else ""
	_context_body.text = "Open Operations to carry out this work. The marked location is a spatial test fixture." if selected else \
		"Inspect an opportunity from Work Scan or select its city location."
	open_operations_button.disabled = not selected
	_selection_label.text = _work_name if selected else "Nothing selected"


func _toggle_tools(opened: bool) -> void:
	developer_scroll.visible = opened
	if opened:
		record_toggle.set_pressed_no_signal(false)
		record_scroll.visible = false
		inspection_requested.emit()


func _toggle_record(opened: bool) -> void:
	record_scroll.visible = opened
	if opened:
		developer_toggle.set_pressed_no_signal(false)
		developer_scroll.visible = false


func show_state(state: Dictionary, work_available: bool, dirty: bool) -> void:
	cash_label.text = money_text(int(state["cash_cents"]))
	time_label.text = time_text(int(state["elapsed_minutes"]))
	count_label.text = str(state["completed_actions"])
	work_button.disabled = not work_available
	_availability.text = "1 available" if work_available else "Unavailable at this session limit"
	dirty_label.text = "Unsaved session" if dirty else "Matches saved slot"


func show_storage(info: Dictionary) -> void:
	var available: bool = bool(info.get("can_recover", false))
	_recovery_row.visible = available
	recovery_button.disabled = not available
	var primary_error: int = int(info.get("primary", {}).get("error", OK))
	_storage_alert = available or primary_error not in [OK, ERR_FILE_NOT_FOUND]
	if available:
		var backup: Dictionary = info["backup"]
		recovery_hint.text = "Previous save: %s, %d completed. Recovery replaces this live session; the original file is kept." % [
			money_text(int(backup["cash_cents"])), int(backup["completed_actions"]),
		]
	_update_attention()


func show_status(message: String, is_error: bool = false) -> void:
	status_label.text = message
	_message_error = is_error
	status_label.modulate = OsTokens.ERROR if is_error else Color.WHITE
	_update_attention()


func _update_attention() -> void:
	status_kind.text = "ATTENTION" if _storage_alert or _message_error else "UPDATE"


func show_build(build: Dictionary) -> void:
	_build_label.text = "v%s  ·  %s" % [build["game_version"], build["build_id"]]


func show_events(events: Array[Dictionary]) -> void:
	var lines: PackedStringArray = []
	for index: int in range(maxi(0, events.size() - 6), events.size()):
		var event: Dictionary = events[index]
		var title: String = "Errand completed"
		if event["type"] == "advance":
			title = "Time advanced"
		elif event["type"] == "rng_probe":
			title = "Diagnostic random draw"
		lines.append("%s   ·   %s   ·   #%d" % [time_text(int(event["tick"])), title, int(event["sequence"])])
	record_label.text = "\n".join(lines) if not lines.is_empty() else \
		"No events since this session was loaded or reset."


func ui_snapshot() -> Dictionary:
	var state: Dictionary = _model.snapshot()
	state["camera"] = city.camera_snapshot()
	state["developer_open"] = developer_scroll.visible
	state["record_open"] = record_scroll.visible
	return state


static func time_text(elapsed_minutes: int) -> String:
	var clock_minutes: int = 480 + elapsed_minutes
	return "Day %d · %02d:%02d" % [
		1 + floori(clock_minutes / 1440.0), floori((clock_minutes % 1440) / 60.0), clock_minutes % 60,
	]


static func money_text(cents: int) -> String:
	return "$%d.%02d" % [floori(cents / 100.0), cents % 100]
