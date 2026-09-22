class_name CriminalOsShell
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

# Existing app/probe boundary. Presentation never owns gameplay authority.
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
var record_app_button: Button
var glance_toggle: Button
var chassis_surface: Panel
var center_stage: Control
var center_app_surface: OsAppSurface
var right_app_surface: OsAppSurface
var center_back_buttons: Array[Button] = []
var right_back_buttons: Array[Button] = []
var operations_work_tab: Button
var operations_record_tab: Button
var operations_record_work_button: Button
var record_activity_tab: Button
var record_storage_tab: Button
var record_storage_activity_button: Button
var record_storage_storage_button: Button
var bottom_work_tab: Button
var bottom_layout_tab: Button
var record_toggle: Button
var record_scroll: ScrollContainer
var record_label: Label
var context_title: Label
var status_kind: Label
var workspace: WorkspaceContainer
var widget_workspace: WidgetWorkspace
var layout_toggle: Button
var layout_scroll: ScrollContainer
var reset_layout_button: Button
var scale_picker: OptionButton
var rail_controls: Dictionary = {}
var layout_storage_error: Error = OK

var _model: OsPresentationState = OsPresentationState.new()
var _preferences: WorkspacePreferences
var _expanded: Dictionary = {}
var _folded: Dictionary = {}
var _context: VBoxContainer
var _context_scroll: ScrollContainer
var _operations: VBoxContainer
var _operations_record_label: Label
var _rail_record_label: Label
var _rail_storage_label: Label
var _city_focus_path: NodePath = NodePath("")
var _last_active_app: String = "city"
var _recovery_row: VBoxContainer
var _context_terms: Label
var _context_body: Label
var _operation_title: Label
var _operation_terms: Label
var _build_label: Label
var _brand_label: Label
var _work_scroll: ScrollContainer
var _layout_note: Label
var _bottom_widget_dock: WidgetDock
var _right_widget_dock: WidgetDock
var _page: String = "work"
var _work_id: String = ""
var _work_name: String = ""
var _terms: String = ""
var _message_error: bool = false
var _storage_alert: bool = false


func _ready() -> void:
	theme = OsTokens.make_theme()
	chassis_surface = Panel.new()
	chassis_surface.name = "ChassisSurface"
	chassis_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chassis_surface.add_theme_stylebox_override("panel", OsFrames.frame_style(OsFrames.ROLE_SHELL, OsTokens.CHASSIS, 0, OsTokens.frame_palette()))
	add_child(chassis_surface)
	chassis_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	OsMaterials.apply_diffuse(chassis_surface, OsMaterials.ROLE_CHASSIS, "shell-chassis")
	workspace = WorkspaceContainer.new()
	workspace.name = "Workspace"
	add_child(workspace)
	_build_left()
	_build_right()
	_build_top()
	_build_bottom()
	center_stage = Control.new()
	center_stage.name = "CenterStage"
	center_stage.clip_contents = true
	center_stage.mouse_filter = Control.MOUSE_FILTER_STOP
	workspace.register_region("city", center_stage)
	city = CityBlockout.new()
	center_stage.add_child(city)
	city.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	city.custom_minimum_size = Vector2.ZERO
	city.work_selected.connect(select_work)
	city.selection_cleared.connect(clear_selection)
	_build_center_apps()
	widget_workspace = WidgetWorkspace.new()
	add_child(widget_workspace)
	widget_workspace.setup(self, workspace, _bottom_widget_dock, _right_widget_dock)
	widget_workspace.inspect_requested.connect(select_work)
	widget_workspace.record_requested.connect(func() -> void: open_record_app("activity"))
	widget_workspace.status_changed.connect(_widget_status)
	inspect_button = (widget_workspace.widgets["work_scan"] as WidgetView).inspect_button
	reset_layout_button.pressed.connect(widget_workspace.reset_widgets)
	workspace.layout_applied.connect(_apply_geometry)
	workspace.model.changed.connect(_fit_workspace)
	workspace.model.committed.connect(_persist_layout)
	resized.connect(_fit_workspace)
	_model.changed.connect(_apply_navigation)
	_fit_workspace()
	_apply_navigation()
	_choose_page("work")
	OsFrames.attach_overlay(self, OsFrames.ROLE_SHELL, OsTokens.frame_palette(), true)


func configure_workspace(slot: String, force_persistence: bool = false) -> void:
	var enabled: bool = force_persistence or not (slot.contains("/_tests") or slot.contains("/_ci_"))
	widget_workspace.configure_profile(slot, enabled)
	if not enabled:
		_preferences = null
		workspace.model.restore(WorkspaceLayout.defaults())
		return
	_preferences = WorkspacePreferences.new(WorkspacePreferences.path_for_slot(slot))
	var result: Dictionary = _preferences.read_layout()
	layout_storage_error = int(result["error"]) as Error
	if layout_storage_error == OK: workspace.model.restore(result["layout"])
	elif layout_storage_error == ERR_FILE_NOT_FOUND: layout_storage_error = OK
	_fit_workspace()


func _persist_layout() -> void:
	if _preferences != null: layout_storage_error = _preferences.write_layout(workspace.model.snapshot())
	_update_layout_note()


func _widget_status(message: String, failed: bool) -> void:
	show_status(message, failed)
	_update_layout_note()


func _fit_workspace() -> void:
	if not is_instance_valid(workspace): return
	var factor: float = workspace.model.scale_for(size)
	workspace.scale = Vector2.ONE * factor
	workspace.position = Vector2.ZERO
	workspace.size = size / factor
	workspace.queue_sort()


func _surface(side: String) -> Panel:
	var panel: Panel = Panel.new()
	panel.name = side.capitalize() + "Rail"
	panel.clip_contents = true
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.mouse_force_pass_scroll_events = false
	panel.add_theme_stylebox_override("panel", OsFrames.frame_style(OsFrames.ROLE_SURFACE, OsTokens.SURFACE, 0, OsTokens.frame_palette()))
	OsMaterials.apply_diffuse(panel, OsMaterials.ROLE_SURFACE, "rail-" + side)
	OsFrames.attach_overlay(panel, OsFrames.ROLE_SURFACE, OsTokens.frame_palette())
	workspace.register_region(side, panel)
	return panel


func _inset(parent: Control, padding: int = 16) -> VBoxContainer:
	var margin: MarginContainer = MarginContainer.new()
	parent.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, padding)
	return OsTokens.column(margin, 16)


func _scroll(parent: Node) -> ScrollContainer:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.mouse_force_pass_scroll_events = false
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(scroll)
	return scroll


func _icon(parent: Node, kind: String, title: String, action: Callable) -> Button:
	var button: Button = OsTokens.button(parent, "", action)
	OsControls.apply(button, OsControls.ROLE_LAUNCHER, OsTokens.control_palette())
	OsControls.set_icon(button, kind, 22)
	button.custom_minimum_size = Vector2(44, 44)
	button.tooltip_text = title
	button.accessibility_name = title
	return button


func _control_icon(button: Button, kind: String, role: String = OsControls.ROLE_COMPACT, max_width: int = 16) -> Button:
	OsControls.apply(button, role, OsTokens.control_palette())
	OsControls.set_icon(button, kind, max_width)
	return button


func _build_left() -> void:
	var rail: Panel = _surface("left")
	var mark: Label = OsTokens.label(rail, "SD", 24, OsTokens.ACCENT)
	mark.position = Vector2(15, 20)
	_brand_label = OsTokens.label(rail, "SIM-DURTY", 22)
	_brand_label.position = Vector2(76, 22)
	var launcher: VBoxContainer = OsTokens.column(rail, 10)
	launcher.position = Vector2(10, 78)
	launcher.size.x = 44
	city_button = _icon(launcher, "city", "City", func() -> void: _model.return_to_city())
	city_button.toggle_mode = true
	operations_button = _icon(launcher, "work", "Operations", open_operations)
	operations_button.toggle_mode = true
	record_app_button = _icon(launcher, "report", "Session Record", func() -> void: open_record_app())
	record_app_button.toggle_mode = true
	layout_toggle = _icon(launcher, "layout", "Workspace layout", func() -> void: _choose_page("layout"))
	layout_toggle.toggle_mode = true
	glance_toggle = _icon(launcher, "rail", "Show or fold the left rail", Callable())
	glance_toggle.toggle_mode = true
	glance_toggle.toggled.connect(func(opened: bool) -> void: workspace.model.set_collapsed("left", not opened))
	launcher.add_child(HSeparator.new())
	save_button = _icon(launcher, "save", "Save game", func() -> void: save_requested.emit())
	load_button = _icon(launcher, "load", "Load game", func() -> void: load_requested.emit())
	developer_toggle = _icon(launcher, "tools", "Developer tools", Callable())
	developer_toggle.toggle_mode = true
	developer_toggle.toggled.connect(_toggle_tools)
	copy_button = _icon(launcher, "report", "Copy debug report", func() -> void: debug_report_requested.emit())
	var scroll: ScrollContainer = _scroll(rail)
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 76
	scroll.offset_top = 92
	scroll.offset_right = -18
	scroll.offset_bottom = -18
	_expanded["left"] = scroll
	var summary: VBoxContainer = OsTokens.column(scroll, 12)
	summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	OsTokens.label(summary, "ON HAND", 13, OsTokens.MUTED)
	cash_label = OsTokens.label(summary, "$10.00", 40)
	cash_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	dirty_label = OsTokens.wrapped(summary, "Unsaved session", 14)
	var spacer: Control = Control.new()
	spacer.custom_minimum_size.y = 28
	summary.add_child(spacer)
	OsTokens.label(summary, "COMPLETED", 13, OsTokens.MUTED)
	count_label = OsTokens.label(summary, "0", 34)
	OsTokens.wrapped(summary, "Errands this save", 15)
	_build_label = OsTokens.wrapped(summary, "Local development", 13)


func _build_right() -> void:
	var rail: Panel = _surface("right")
	var full: VBoxContainer = _inset(rail, 20)
	_expanded["right"] = full.get_parent()
	var heading: HBoxContainer = OsTokens.row(full, 8)
	OsTokens.label(heading, "CONTEXT", 13, OsTokens.ACCENT)
	OsTokens.spacer(heading)
	var fold_right: Button = OsTokens.button(heading, "", func() -> void: workspace.model.set_collapsed("right", true))
	_control_icon(fold_right, "fold_right", OsControls.ROLE_FOLD)
	fold_right.tooltip_text = "Fold right rail"
	var scroll: ScrollContainer = _scroll(full)
	_context_scroll = scroll
	var stack: VBoxContainer = OsTokens.column(scroll, 20)
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_recovery_row = OsTokens.column(stack, 12)
	_recovery_row.visible = false
	recovery_hint = OsTokens.wrapped(_recovery_row, "", 16, OsTokens.ERROR)
	recovery_button = OsTokens.button(_recovery_row, "Recover previous save", func() -> void: recovery_requested.emit())
	_context = OsTokens.column(stack, 18)
	context_title = OsTokens.wrapped(_context, "Select work", 26, OsTokens.TEXT)
	_context_terms = OsTokens.wrapped(_context, "", 18, OsTokens.ACCENT)
	_context_body = OsTokens.wrapped(_context, "Choose work from a widget or its city location.", 17)
	open_operations_button = OsTokens.button(_context, "Open Operations", open_operations_for_selection)
	OsControls.apply(open_operations_button, OsControls.ROLE_PRIMARY, OsTokens.control_palette())
	OsTokens.button(_context, "Clear selection", clear_selection)
	right_app_surface = OsAppSurface.new()
	right_app_surface.name = "RightAppSurface"
	right_app_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	full.add_child(right_app_surface)
	right_app_surface.setup("record", OsAppManifest.HOST_RIGHT)
	right_app_surface.add_theme_stylebox_override("panel", OsFrames.frame_style(OsFrames.ROLE_APP, OsTokens.WELL, 0, OsTokens.frame_palette()))
	OsMaterials.apply_diffuse(right_app_surface, OsMaterials.ROLE_WELL, "app-record")
	OsFrames.attach_overlay(right_app_surface, OsFrames.ROLE_APP, OsTokens.frame_palette())
	_build_right_record_views()
	_right_widget_dock = WidgetDock.new()
	_right_widget_dock.region = "right"
	_right_widget_dock.name = "RightWidgets"
	full.add_child(_right_widget_dock)
	var folded: VBoxContainer = _inset(rail, 8)
	_folded["right"] = folded.get_parent()
	var expand_right: Button = OsTokens.button(folded, "", func() -> void: workspace.model.set_collapsed("right", false))
	_control_icon(expand_right, "fold_left", OsControls.ROLE_FOLD)
	expand_right.tooltip_text = "Expand right rail"


func _build_center_apps() -> void:
	center_app_surface = OsAppSurface.new()
	center_app_surface.name = "CenterAppSurface"
	center_stage.add_child(center_app_surface)
	center_app_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center_app_surface.setup("operations", OsAppManifest.HOST_CENTER)
	center_app_surface.add_theme_stylebox_override("panel", OsFrames.frame_style(OsFrames.ROLE_APP, OsTokens.WELL, 0, OsTokens.frame_palette()))
	OsMaterials.apply_diffuse(center_app_surface, OsMaterials.ROLE_WELL, "app-operations")
	OsFrames.attach_overlay(center_app_surface, OsFrames.ROLE_APP, OsTokens.frame_palette())
	var work_view: MarginContainer = MarginContainer.new()
	var work_stack: VBoxContainer = _app_inset(work_view, 28)
	var work_header: HBoxContainer = _app_header(work_stack, "Operations")
	var work_back: Button = OsTokens.button(work_header, "Back", func() -> void: _model.back())
	_control_icon(work_back, "back", OsControls.ROLE_NAV)
	center_back_buttons.append(work_back)
	close_operations_button = OsTokens.button(work_header, "City", func() -> void: _model.return_to_city())
	_control_icon(close_operations_button, "city", OsControls.ROLE_NAV)
	operations_work_tab = OsTokens.button(work_header, "Work", func() -> void: _model.navigate_view("work"))
	operations_work_tab.toggle_mode = true
	OsControls.apply(operations_work_tab, OsControls.ROLE_TAB, OsTokens.control_palette())
	operations_record_tab = OsTokens.button(work_header, "Record", func() -> void: _model.navigate_view("record"))
	operations_record_tab.toggle_mode = true
	OsControls.apply(operations_record_tab, OsControls.ROLE_TAB, OsTokens.control_palette())
	OsTokens.label(work_stack, "SELECTED WORK", 13, OsTokens.ACCENT)
	_operations = OsTokens.column(work_stack, 18)
	_operation_title = OsTokens.wrapped(_operations, "", 36, OsTokens.TEXT)
	_operation_terms = OsTokens.wrapped(_operations, "", 20, OsTokens.ACCENT)
	OsTokens.wrapped(_operations, "Operations owns execution. City camera and selection stay mounted behind this focused view.", 17)
	work_button = OsTokens.button(_operations, "Run an errand", func() -> void: work_requested.emit())
	OsControls.apply(work_button, OsControls.ROLE_PRIMARY, OsTokens.control_palette())
	work_button.custom_minimum_size.y = 64
	OsTokens.wrapped(_operations, "Test activity only. Crew, travel and risk are not active.", 15)
	center_app_surface.register_view("work", work_view)
	var record_view: MarginContainer = MarginContainer.new()
	var record_stack: VBoxContainer = _app_inset(record_view, 28)
	var record_header: HBoxContainer = _app_header(record_stack, "Operations")
	var record_back: Button = OsTokens.button(record_header, "Back", func() -> void: _model.back())
	_control_icon(record_back, "back", OsControls.ROLE_NAV)
	center_back_buttons.append(record_back)
	var record_city: Button = OsTokens.button(record_header, "City", func() -> void: _model.return_to_city())
	_control_icon(record_city, "city", OsControls.ROLE_NAV)
	operations_record_work_button = OsTokens.button(record_header, "Work", func() -> void: _model.navigate_view("work"))
	operations_record_work_button.toggle_mode = true
	OsControls.apply(operations_record_work_button, OsControls.ROLE_TAB, OsTokens.control_palette())
	var operations_record_selected: Button = OsTokens.button(record_header, "Record", func() -> void: _model.navigate_view("record"))
	operations_record_selected.toggle_mode = true
	OsControls.apply(operations_record_selected, OsControls.ROLE_TAB, OsTokens.control_palette())
	operations_record_selected.set_meta("os_app_view", "operations_record_selected")
	OsTokens.label(record_stack, "CURRENT SESSION RECORD", 13, OsTokens.ACCENT)
	var record_scroll_view: ScrollContainer = _scroll(record_stack)
	var record_content: VBoxContainer = OsTokens.column(record_scroll_view, 10)
	record_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_operations_record_label = OsTokens.wrapped(record_content, "No events since this session was loaded or reset.", 19, OsTokens.TEXT)
	OsTokens.wrapped(record_content, "Bounded local event journal. No invented historical data.", 15)
	center_app_surface.register_view("record", record_view)

func _build_right_record_views() -> void:
	var activity_view: MarginContainer = MarginContainer.new()
	var activity_stack: VBoxContainer = _app_inset(activity_view, 12)
	OsTokens.label(activity_stack, "Session Record", 22)
	var activity_nav: HBoxContainer = OsTokens.row(activity_stack, 6)
	var activity_back: Button = OsTokens.button(activity_nav, "Back", func() -> void: _model.back())
	_control_icon(activity_back, "back", OsControls.ROLE_NAV)
	var activity_city: Button = OsTokens.button(activity_nav, "City", func() -> void: _model.return_to_city())
	_control_icon(activity_city, "city", OsControls.ROLE_NAV)
	right_back_buttons.append(activity_back)
	var activity_tabs: HBoxContainer = OsTokens.row(activity_stack, 6)
	record_activity_tab = OsTokens.button(activity_tabs, "Activity", func() -> void: _model.navigate_view("activity"))
	record_activity_tab.toggle_mode = true
	OsControls.apply(record_activity_tab, OsControls.ROLE_TAB, OsTokens.control_palette())
	record_storage_tab = OsTokens.button(activity_tabs, "Storage", func() -> void: _model.navigate_view("storage"))
	record_storage_tab.toggle_mode = true
	OsControls.apply(record_storage_tab, OsControls.ROLE_TAB, OsTokens.control_palette())
	OsTokens.label(activity_stack, "CURRENT SESSION", 13, OsTokens.ACCENT)
	var activity_scroll: ScrollContainer = _scroll(activity_stack)
	var activity_content: VBoxContainer = OsTokens.column(activity_scroll, 8)
	activity_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rail_record_label = OsTokens.wrapped(activity_content, "No events since this session was loaded or reset.", 17, OsTokens.TEXT)
	OsTokens.wrapped(activity_content, "Rail-hosted app · current session only", 14)
	right_app_surface.register_view("activity", activity_view)
	var storage_view: MarginContainer = MarginContainer.new()
	var storage_stack: VBoxContainer = _app_inset(storage_view, 12)
	OsTokens.label(storage_stack, "Session Record", 22)
	var storage_nav: HBoxContainer = OsTokens.row(storage_stack, 6)
	var storage_back: Button = OsTokens.button(storage_nav, "Back", func() -> void: _model.back())
	_control_icon(storage_back, "back", OsControls.ROLE_NAV)
	var storage_city: Button = OsTokens.button(storage_nav, "City", func() -> void: _model.return_to_city())
	_control_icon(storage_city, "city", OsControls.ROLE_NAV)
	right_back_buttons.append(storage_back)
	var storage_tabs: HBoxContainer = OsTokens.row(storage_stack, 6)
	record_storage_activity_button = OsTokens.button(storage_tabs, "Activity", func() -> void: _model.navigate_view("activity"))
	record_storage_activity_button.toggle_mode = true
	OsControls.apply(record_storage_activity_button, OsControls.ROLE_TAB, OsTokens.control_palette())
	record_storage_storage_button = OsTokens.button(storage_tabs, "Storage", func() -> void: _model.navigate_view("storage"))
	record_storage_storage_button.toggle_mode = true
	OsControls.apply(record_storage_storage_button, OsControls.ROLE_TAB, OsTokens.control_palette())
	OsTokens.label(storage_stack, "SAVE SLOT", 13, OsTokens.ACCENT)
	_rail_storage_label = OsTokens.wrapped(storage_stack, "No saved slot yet.", 17, OsTokens.TEXT)
	OsTokens.wrapped(storage_stack, "Read-only inspection here. Saving and recovery stay explicit.", 14)
	right_app_surface.register_view("storage", storage_view)

func _app_inset(root: MarginContainer, padding: int) -> VBoxContainer:
	for edge: String in ["left", "right", "top", "bottom"]:
		root.add_theme_constant_override("margin_" + edge, padding)
	return OsTokens.column(root, 16)

func _app_header(parent: Node, title: String) -> HBoxContainer:
	var row: HBoxContainer = OsTokens.row(parent, 10)
	OsTokens.label(row, title, 24)
	OsTokens.spacer(row)
	return row


func _build_top() -> void:
	var rail: Panel = _surface("top")
	var stack: VBoxContainer = _inset(rail, 8)
	stack.add_theme_constant_override("separation", 6)
	var head: HBoxContainer = OsTokens.row(stack, 12)
	OsTokens.label(head, "CITY WORKSPACE", 15, OsTokens.MUTED)
	OsTokens.spacer(head)
	var zoom_out: Button = OsTokens.button(head, "", func() -> void: city.zoom_at(1.0 / 1.2, city.size * 0.5))
	var zoom_in: Button = OsTokens.button(head, "", func() -> void: city.zoom_at(1.2, city.size * 0.5))
	var reset_view: Button = OsTokens.button(head, "", func() -> void: city.reset_camera())
	_control_icon(zoom_out, "zoom_out", OsControls.ROLE_COMPACT)
	_control_icon(zoom_in, "zoom_in", OsControls.ROLE_COMPACT)
	_control_icon(reset_view, "reset", OsControls.ROLE_COMPACT)
	zoom_out.tooltip_text = "Zoom out"
	zoom_in.tooltip_text = "Zoom in"
	reset_view.tooltip_text = "Reset city view"
	time_label = OsTokens.label(head, "Day 1 · 08:00", 23)
	var fold: Button = OsTokens.button(head, "", func() -> void: workspace.toggle_rail("top"))
	_control_icon(fold, "fold_up", OsControls.ROLE_FOLD)
	fold.custom_minimum_size.y = 30
	fold.tooltip_text = "Fold or expand top rail"
	var status: HBoxContainer = OsTokens.row(stack, 12)
	_expanded["top"] = status
	status_kind = OsTokens.label(status, "UPDATE", 12, OsTokens.ACCENT)
	status_label = OsTokens.wrapped(status, "", 16, OsTokens.TEXT)
	status_label.max_lines_visible = 2
	status_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS


func _build_bottom() -> void:
	var rail: Panel = _surface("bottom")
	var stack: VBoxContainer = _inset(rail, 8)
	stack.add_theme_constant_override("separation", 10)
	var tabs: HBoxContainer = OsTokens.row(stack, 10)
	OsTokens.label(tabs, "WORKBENCH", 13, OsTokens.MUTED)
	OsTokens.spacer(tabs)
	bottom_work_tab = OsTokens.button(tabs, "Work", func() -> void: _choose_page("work"))
	bottom_work_tab.toggle_mode = true
	OsControls.apply(bottom_work_tab, OsControls.ROLE_TAB, OsTokens.control_palette())
	record_toggle = OsTokens.button(tabs, "Activity", Callable())
	record_toggle.toggle_mode = true
	OsControls.apply(record_toggle, OsControls.ROLE_TAB, OsTokens.control_palette())
	record_toggle.toggled.connect(_toggle_record)
	bottom_layout_tab = OsTokens.button(tabs, "Layout", func() -> void: _choose_page("layout"))
	bottom_layout_tab.toggle_mode = true
	OsControls.apply(bottom_layout_tab, OsControls.ROLE_TAB, OsTokens.control_palette())
	var fold: Button = OsTokens.button(tabs, "", func() -> void: workspace.toggle_rail("bottom"))
	_control_icon(fold, "fold_down", OsControls.ROLE_FOLD)
	fold.tooltip_text = "Fold or expand bottom rail"
	var pages: VBoxContainer = OsTokens.column(stack, 0)
	pages.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_expanded["bottom"] = pages
	_bottom_widget_dock = WidgetDock.new()
	_bottom_widget_dock.region = "bottom"
	_bottom_widget_dock.name = "WorkbenchWidgets"
	pages.add_child(_bottom_widget_dock)
	_work_scroll = _bottom_widget_dock
	record_scroll = _scroll(pages)
	var records: VBoxContainer = OsTokens.column(record_scroll, 8)
	records.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	record_label = OsTokens.wrapped(records, "", 18, OsTokens.TEXT)
	OsTokens.label(records, "Current session only", 14, OsTokens.MUTED)
	developer_scroll = _scroll(pages)
	var tools: VBoxContainer = OsTokens.column(developer_scroll, 12)
	tools.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spine_panel = SpinePanel.new()
	tools.add_child(spine_panel)
	spine_panel.advance_requested.connect(func(minutes: int) -> void: advance_requested.emit(minutes))
	spine_panel.sample_requested.connect(func() -> void: sample_requested.emit())
	for label: Label in [spine_panel.identity, spine_panel.random_value, spine_panel.storage_label, spine_panel.events_label]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 18)
	reset_button = OsTokens.button(tools, "Reset session", func() -> void: reset_requested.emit())
	reset_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	reset_button.tooltip_text = "Reset live gameplay only. Saved progress stays intact."
	layout_scroll = _scroll(pages)
	_build_layout_controls(layout_scroll)


func _build_layout_controls(parent: Node) -> void:
	var stack: VBoxContainer = OsTokens.column(parent, 8)
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_layout_note = OsTokens.wrapped(stack, "", 15)
	for side: String in WorkspaceLayout.SIDES:
		var row: HBoxContainer = OsTokens.row(stack, 12)
		var name_label: Label = OsTokens.label(row, side.capitalize(), 18)
		name_label.custom_minimum_size.x = 76
		var value: Label = OsTokens.label(row, "", 15, OsTokens.MUTED)
		value.custom_minimum_size.x = 155
		var smaller: Button = OsTokens.button(row, "−20", func() -> void: workspace.step(side, -20))
		var larger: Button = OsTokens.button(row, "+20", func() -> void: workspace.step(side, 20))
		var fold: Button = OsTokens.button(row, "Fold", func() -> void: workspace.toggle_rail(side))
		for control: Button in [smaller, larger, fold]: control.custom_minimum_size.y = 34
		rail_controls[side] = {"value": value, "smaller": smaller, "larger": larger, "fold": fold}
	var options: HBoxContainer = OsTokens.row(stack, 12)
	OsTokens.label(options, "Interface size", 16)
	scale_picker = OptionButton.new()
	OsControls.apply(scale_picker, OsControls.ROLE_STANDARD, OsTokens.control_palette())
	scale_picker.add_item("100%", 100)
	scale_picker.add_item("125%", 125)
	options.add_child(scale_picker)
	scale_picker.item_selected.connect(func(index: int) -> void: workspace.model.set_scale_percent(scale_picker.get_item_id(index)))
	reset_layout_button = OsTokens.button(options, "Reset layout", func() -> void: workspace.model.reset_layout())
	reset_layout_button.tooltip_text = "Restore rails and widget defaults only. Does not reset gameplay, camera or save."
	OsTokens.wrapped(stack, "Widget headers: drag ≡ to move, ↘ to resize, or use ⋯ for clickable position and size controls.", 15)


func _apply_geometry(result: Dictionary) -> void:
	for side: String in _expanded: (_expanded[side] as Control).visible = not bool(result["collapsed"][side])
	for side: String in _folded: (_folded[side] as Control).visible = bool(result["collapsed"][side])
	_brand_label.visible = not bool(result["collapsed"]["left"])
	OsControls.set_selected(glance_toggle, not bool(result["collapsed"]["left"]))
	var preferred: Dictionary = workspace.model.snapshot()
	for side: String in rail_controls:
		var controls: Dictionary = rail_controls[side]
		(controls["value"] as Label).text = "%d / %d preferred" % [result["extents"][side], preferred["rails"][side]["extent"]]
		(controls["fold"] as Button).text = "Expand" if result["collapsed"][side] else "Fold"
	scale_picker.select(0 if int(preferred["scale_percent"]) == 100 else 1)
	_update_layout_note()


func _update_layout_note() -> void:
	if not is_instance_valid(_layout_note): return
	_layout_note.text = "Drag seams or use these controls. Committed UI changes save separately from gameplay."
	var widget_error: int = int(widget_workspace.storage_error) if is_instance_valid(widget_workspace) else 0
	if layout_storage_error != OK or widget_error != OK:
		_layout_note.text = "Some layout choices are temporary. Saved profiles were preserved; copy report for details."
	elif workspace.model.scale_for(size) * 100 < float(workspace.model.snapshot()["scale_percent"]):
		_layout_note.text = "125% needs a 1600×1000 window. Using 100% here; your larger-size preference is kept."


func _choose_page(page: String) -> void:
	if is_instance_valid(widget_workspace): widget_workspace.cancel_manipulation()
	_page = page
	_work_scroll.visible = page == "work"
	record_scroll.visible = page == "record"
	developer_scroll.visible = page == "tools"
	layout_scroll.visible = page == "layout"
	OsControls.set_selected(bottom_work_tab, page == "work")
	OsControls.set_selected(record_toggle, page == "record")
	OsControls.set_selected(bottom_layout_tab, page == "layout")
	OsControls.set_selected(layout_toggle, page == "layout")
	OsControls.set_selected(developer_toggle, page == "tools")
	workspace.model.set_collapsed("bottom", false)
	if page == "tools": inspection_requested.emit()


func _toggle_tools(opened: bool) -> void:
	_choose_page("tools" if opened else "work")


func _toggle_record(opened: bool) -> void:
	_choose_page("record" if opened else "work")


func configure_work(definition: SkeletonWorkDefinition) -> void:
	_work_id = String(definition.activity_id)
	_work_name = definition.display_name
	_terms = "+%s  /  %d minutes" % [money_text(definition.payout_cents), definition.duration_minutes]
	widget_workspace.configure_work(definition)
	_operation_title.text = _work_name
	_operation_terms.text = _terms
	work_button.text = _work_name
	city.configure(_work_id, _work_name)
	_model.configure(_work_id)


func select_work(work_id: String) -> Error:
	var error: Error = _model.select_work(work_id)
	if error == OK: workspace.model.set_collapsed("right", false)
	return error


func clear_selection() -> void:
	_model.clear_selection()


func open_operations() -> void:
	_model.open_app("operations")

func open_operations_for_selection() -> void:
	var selected_id: String = str(_model.snapshot()["selected_id"])
	if not selected_id.is_empty():
		_model.open_deep_link("operations", "work", selected_id)

func open_record_app(view_id: String = "") -> void:
	var error: Error = _model.open_app("record", view_id)
	if error == OK:
		workspace.model.set_collapsed("right", false)

func _remember_city_focus() -> void:
	var owner: Control = get_viewport().gui_get_focus_owner()
	if is_instance_valid(owner) and city.is_ancestor_of(owner):
		_city_focus_path = city.get_path_to(owner)

func _restore_city_focus() -> void:
	if _city_focus_path.is_empty() or not city.is_visible_in_tree():
		return
	var target: Node = city.get_node_or_null(_city_focus_path)
	if target is Control and target.is_visible_in_tree():
		(target as Control).grab_focus()

func _apply_navigation() -> void:
	var state: Dictionary = _model.snapshot()
	var selected: bool = not str(state["selected_id"]).is_empty()
	var active_app: String = str(state["active_app"])
	var active_view: String = str(state["active_view"])
	var center_active: bool = active_app == "operations"
	var rail_active: bool = active_app == "record"
	if center_active and _last_active_app != "operations":
		_remember_city_focus()
	if center_active:
		city.hide()
		city.process_mode = Node.PROCESS_MODE_DISABLED
		center_app_surface.activate(active_view)
	else:
		center_app_surface.suspend()
		city.show()
		city.process_mode = Node.PROCESS_MODE_INHERIT
		if _last_active_app == "operations":
			call_deferred("_restore_city_focus")
	if rail_active:
		right_app_surface.activate(active_view)
		_context_scroll.hide()
		_right_widget_dock.hide()
	else:
		right_app_surface.suspend()
		_context_scroll.show()
		_right_widget_dock.show()
	OsControls.set_selected(city_button, active_app == "city")
	OsControls.set_selected(operations_button, center_active)
	OsControls.set_selected(record_app_button, rail_active)
	for button: Button in center_back_buttons:
		button.disabled = not center_active or int(state["back_depth"]) == 0
	for button: Button in right_back_buttons:
		button.disabled = not rail_active or int(state["back_depth"]) == 0
	OsControls.set_selected(operations_work_tab, center_active and active_view == "work")
	OsControls.set_selected(operations_record_tab, center_active and active_view == "record")
	OsControls.set_selected(operations_record_work_button, center_active and active_view == "work")
	var record_selected: Array[Node] = center_app_surface.find_children("*", "Button", true, false).filter(func(node: Node) -> bool: return str(node.get_meta("os_app_view", "")) == "operations_record_selected")
	for node: Node in record_selected:
		OsControls.set_selected(node as Button, center_active and active_view == "record")
	OsControls.set_selected(record_activity_tab, rail_active and active_view == "activity")
	OsControls.set_selected(record_storage_tab, rail_active and active_view == "storage")
	OsControls.set_selected(record_storage_activity_button, rail_active and active_view == "activity")
	OsControls.set_selected(record_storage_storage_button, rail_active and active_view == "storage")
	city.set_selected(selected)
	context_title.text = _work_name if selected else "Select work"
	_context_terms.text = _terms if selected else ""
	_context_body.text = "Ready to open in Operations." if selected else "Choose work from a widget or its city location."
	open_operations_button.disabled = not selected
	widget_workspace.set_selected(str(state["selected_id"]))
	_last_active_app = active_app


func show_state(state: Dictionary, work_available: bool, dirty: bool) -> void:
	cash_label.text = money_text(int(state["cash_cents"]))
	cash_label.tooltip_text = cash_label.text
	time_label.text = time_text(int(state["elapsed_minutes"]))
	count_label.text = str(state["completed_actions"])
	work_button.disabled = not work_available
	dirty_label.text = "Unsaved session" if dirty else "Matches saved slot"
	widget_workspace.show_state(state, work_available)


func show_storage(info: Dictionary) -> void:
	var primary: Dictionary = info.get("primary", {})
	var primary_error: int = int(primary.get("error", OK))
	if is_instance_valid(_rail_storage_label):
		if primary_error == OK:
			_rail_storage_label.text = "Ready · schema %d\n%s · %d completed" % [int(primary.get("schema", 0)), money_text(int(primary.get("cash_cents", 0))), int(primary.get("completed_actions", 0))]
		elif primary_error == ERR_FILE_NOT_FOUND:
			_rail_storage_label.text = "No saved slot yet."
		else:
			_rail_storage_label.text = "Saved slot needs attention (error %d)." % primary_error
	var available: bool = bool(info.get("can_recover", false))
	_recovery_row.visible = available
	recovery_button.disabled = not available
	_storage_alert = available or primary_error not in [OK, ERR_FILE_NOT_FOUND]
	if available:
		var backup: Dictionary = info["backup"]
		recovery_hint.text = "Previous save: %s, %d completed. Recovery replaces this live session; original kept." % [money_text(int(backup["cash_cents"])), int(backup["completed_actions"])]
		workspace.model.set_collapsed("right", false)
	_update_attention()


func show_status(message: String, is_error: bool = false) -> void:
	status_label.text = message
	status_label.tooltip_text = message
	_message_error = is_error
	status_label.modulate = OsTokens.ERROR if is_error else Color.WHITE
	_update_attention()


func _update_attention() -> void:
	status_kind.text = "ATTENTION" if _storage_alert or _message_error else "UPDATE"


func show_build(build: Dictionary) -> void:
	_build_label.text = "v%s\n%s" % [build["game_version"], build["build_id"]]


func show_events(events: Array[Dictionary]) -> void:
	var lines: PackedStringArray = []
	for index: int in range(maxi(0, events.size() - 6), events.size()):
		var event: Dictionary = events[index]
		var title: String = "Errand completed"
		if event["type"] == "advance": title = "Time advanced"
		elif event["type"] == "rng_probe": title = "Diagnostic random draw"
		lines.append("%s   ·   %s   ·   #%d" % [time_text(int(event["tick"])), title, int(event["sequence"])])
	var event_text: String = "\n".join(lines) if not lines.is_empty() else "No events since this session was loaded or reset."
	record_label.text = event_text
	if is_instance_valid(_operations_record_label):
		_operations_record_label.text = event_text
	if is_instance_valid(_rail_record_label):
		_rail_record_label.text = event_text
	widget_workspace.show_events(events)


func ui_snapshot() -> Dictionary:
	var state: Dictionary = _model.snapshot()
	state["camera"] = city.camera_snapshot()
	state["glance_open"] = not bool(workspace.model.solve(workspace.size)["collapsed"]["left"])
	state["developer_open"] = developer_scroll.visible
	state["record_open"] = record_scroll.visible
	state["layout"] = workspace.model.snapshot()
	state["layout_storage_error"] = int(layout_storage_error)
	state["effective_ui_scale"] = workspace.scale.x
	state["layout_editing"] = workspace.model.active_side()
	state["widgets"] = widget_workspace.snapshot()
	state["widget_storage_error"] = int(widget_workspace.storage_error)
	state["widget_manipulation"] = widget_workspace.manipulation_snapshot()
	state["app_surfaces"] = {"center": center_app_surface.snapshot(), "right": right_app_surface.snapshot()}
	return state


static func time_text(elapsed_minutes: int) -> String:
	var clock_minutes: int = 480 + elapsed_minutes
	return "Day %d · %02d:%02d" % [1 + floori(clock_minutes / 1440.0), floori((clock_minutes % 1440) / 60.0), clock_minutes % 60]


static func money_text(cents: int) -> String:
	return "$%d.%02d" % [floori(cents / 100.0), cents % 100]
