class_name WorkspaceContainer
extends Container

signal layout_applied(result: Dictionary)
var model: WorkspaceLayout = WorkspaceLayout.new()
var handles: Dictionary = {}
var _regions: Dictionary = {}
var _pointer_origin: Vector2 = Vector2.ZERO
var _drag_moved: bool = false
var _observed_size: Vector2 = Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_force_pass_scroll_events = false
	clip_contents = true
	model.changed.connect(queue_sort)
	for side: String in WorkspaceLayout.SIDES:
		var handle: RailHandle = RailHandle.new()
		handle.name = side.capitalize() + "Resize"
		handle.side = side
		add_child(handle)
		handles[side] = handle
		handle.resize_started.connect(_begin)
		handle.step_requested.connect(step)
		handle.fold_requested.connect(toggle_rail)
	get_window().focus_exited.connect(cancel_manipulation)
	queue_sort()


func _exit_tree() -> void:
	model.cancel_resize()
	if is_instance_valid(get_window()) and get_window().focus_exited.is_connected(cancel_manipulation):
		get_window().focus_exited.disconnect(cancel_manipulation)


func register_region(id: String, control: Control) -> void:
	_regions[id] = control
	add_child(control)
	# Handles remain above the bounded region surfaces.
	for handle: RailHandle in handles.values():
		move_child(handle, get_child_count() - 1)
	queue_sort()


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN and is_inside_tree():
		if size != _observed_size:
			model.cancel_resize()
			_observed_size = size
		var result: Dictionary = model.solve(size)
		for id: String in _regions:
			fit_child_in_rect(_regions[id], result["rects"][id])
		for side: String in handles:
			fit_child_in_rect(handles[side], result["rects"][side + "_handle"])
		layout_applied.emit(result)


func toggle_rail(side: String) -> void:
	model.set_collapsed(side, not bool(model.snapshot()["rails"][side]["collapsed"]))


func step(side: String, delta: int) -> void:
	var current: int = int(model.solve(size)["extents"][side])
	model.resize_to(side, current + delta, size)


func _begin(side: String, viewport_position: Vector2) -> void:
	if model.begin_resize(side, size):
		_pointer_origin = get_global_transform().affine_inverse() * viewport_position
		_drag_moved = false


func cancel_manipulation() -> void:
	model.cancel_resize()
	_drag_moved = false


func _input(event: InputEvent) -> void:
	if model.active_side().is_empty():
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		cancel_manipulation()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		var position_local: Vector2 = get_global_transform().affine_inverse() * event.position
		var side: String = model.active_side()
		var delta: Vector2 = position_local - _pointer_origin
		if delta.length() >= 3.0:
			_drag_moved = true
		if _drag_moved:
			var scalar: float = delta.x if side in ["left", "right"] else delta.y
			model.preview_delta(scalar * (-1.0 if side in ["right", "bottom"] else 1.0), size)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			model.commit_resize()
			_drag_moved = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_manipulation()
		# A release after resizing must never activate a control beneath it.
		get_viewport().set_input_as_handled()
