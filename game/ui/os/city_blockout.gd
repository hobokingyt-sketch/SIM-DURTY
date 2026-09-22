class_name CityBlockout
extends Control

signal work_selected(work_id: String)
signal selection_cleared
signal camera_changed

# Authored presentation fixture only. These blocks do not claim to be simulated entities.
const WORLD_SIZE: Vector2 = Vector2(1800, 1300)
const WORK_POINT: Vector2 = Vector2(940, 545)
const MIN_ZOOM: float = 0.7
const MAX_ZOOM: float = 2.4
const BUILDINGS: Array[Rect2] = [
	Rect2(100, 115, 155, 95), Rect2(110, 230, 135, 80),
	Rect2(425, 115, 110, 205), Rect2(560, 115, 130, 80), Rect2(575, 225, 125, 95),
	Rect2(835, 110, 230, 95), Rect2(850, 235, 110, 85), Rect2(980, 235, 105, 85),
	Rect2(1230, 110, 210, 210),
	Rect2(100, 415, 155, 170), Rect2(420, 420, 255, 80), Rect2(430, 530, 130, 75),
	Rect2(835, 420, 240, 85), Rect2(860, 535, 190, 80), Rect2(1230, 420, 205, 185),
	Rect2(105, 730, 165, 100), Rect2(110, 860, 80, 100), Rect2(220, 860, 65, 100),
	Rect2(425, 730, 120, 230), Rect2(580, 745, 115, 90), Rect2(580, 865, 115, 95),
	Rect2(835, 730, 100, 230), Rect2(965, 755, 125, 80), Rect2(965, 865, 125, 95),
	Rect2(1250, 735, 195, 100), Rect2(1265, 865, 180, 100),
	Rect2(435, 1090, 245, 110), Rect2(835, 1090, 255, 110), Rect2(1240, 1090, 215, 110),
]

var marker: Button
var _work_id: String = ""
var _center: Vector2 = WORLD_SIZE * 0.5
var _zoom: float = 1.0
var _dragging: bool = false


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_force_pass_scroll_events = false
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(820, 520)
	marker = OsTokens.button(self, "Errand location", _select_marker)
	marker.toggle_mode = true
	marker.tooltip_text = "Select the existing test errand. This location is an authored blockout fixture."
	marker.size = Vector2(244, 60)
	marker.visible = false
	resized.connect(_refresh_geometry)
	mouse_exited.connect(func() -> void: _dragging = false)
	_refresh_geometry()


func configure(work_id: String, title: String) -> void:
	_work_id = work_id
	marker.text = title
	marker.visible = not work_id.is_empty()
	_refresh_geometry()


func set_selected(value: bool) -> void:
	marker.set_pressed_no_signal(value)
	queue_redraw()


func camera_snapshot() -> Dictionary:
	return {"center": _center, "zoom": _zoom}


func projection_scale() -> float:
	return maxf(0.01, minf(size.x / WORLD_SIZE.x, size.y / WORLD_SIZE.y) * _zoom)


func screen_from_world(point: Vector2) -> Vector2:
	return (point - _center) * projection_scale() + size * 0.5


func world_from_screen(point: Vector2) -> Vector2:
	return (point - size * 0.5) / projection_scale() + _center


func pan_by_screen(delta: Vector2) -> void:
	if not delta.is_finite():
		return
	_center -= delta / projection_scale()
	_clamp_center()
	_refresh_geometry()
	camera_changed.emit()


func zoom_at(factor: float, point: Vector2) -> void:
	if not is_finite(factor) or factor <= 0.0 or not point.is_finite():
		return
	var anchored_world: Vector2 = world_from_screen(point)
	_zoom = clampf(_zoom * factor, MIN_ZOOM, MAX_ZOOM)
	_center = anchored_world - (point - size * 0.5) / projection_scale()
	_clamp_center()
	_refresh_geometry()
	camera_changed.emit()


func reset_camera() -> void:
	_center = WORLD_SIZE * 0.5
	_zoom = 1.0
	_refresh_geometry()
	camera_changed.emit()


func _clamp_center() -> void:
	_center.x = clampf(_center.x, 180.0, WORLD_SIZE.x - 180.0)
	_center.y = clampf(_center.y, 130.0, WORLD_SIZE.y - 130.0)


func _select_marker() -> void:
	if not _work_id.is_empty():
		work_selected.emit(_work_id)


func _refresh_geometry() -> void:
	if is_instance_valid(marker):
		marker.position = screen_from_world(WORK_POINT) - marker.size * 0.5
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event
		match mouse.button_index:
			MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE:
				_dragging = mouse.pressed
				accept_event()
			MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
				if mouse.pressed:
					zoom_at(1.15 if mouse.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.15, mouse.position)
				accept_event()
			MOUSE_BUTTON_LEFT:
				if mouse.pressed:
					selection_cleared.emit()
				accept_event()
	elif event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		if _dragging and (motion.button_mask & (MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE)) != 0:
			pan_by_screen(motion.relative)
			accept_event()
		else:
			_dragging = false


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("141d22"))
	var scale_value: float = projection_scale()
	draw_set_transform(size * 0.5 - _center * scale_value, 0.0, Vector2.ONE * scale_value)
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("263135"))
	# Street beds and pavements. No decorative chart/HUD geometry.
	for x: float in [340.0, 750.0, 1150.0]:
		draw_rect(Rect2(x - 17, 0, 82, WORLD_SIZE.y), Color("3a4447"))
		draw_rect(Rect2(x - 7, 0, 62, WORLD_SIZE.y), Color("1b272d"))
	for y: float in [355.0, 655.0, 1005.0]:
		draw_rect(Rect2(0, y - 17, WORLD_SIZE.x, 82), Color("3a4447"))
		draw_rect(Rect2(0, y - 7, WORLD_SIZE.x, 62), Color("1b272d"))
	# Canal and one fixed bridge establish spatial orientation in the blockout.
	draw_rect(Rect2(1520, 0, 280, 1300), Color("223a43"))
	draw_rect(Rect2(1500, 0, 20, 1300), Color("566063"))
	draw_rect(Rect2(1500, 650, 300, 65), Color("505a5c"))
	draw_rect(Rect2(80, 1090, 205, 130), Color("37463d"))
	for index: int in range(BUILDINGS.size()):
		var building: Rect2 = BUILDINGS[index]
		draw_rect(Rect2(building.position + Vector2(9, 13), building.size), Color("172126"))
		var roof: Color = Color("53605f") if index % 3 == 0 else Color("424e52")
		draw_rect(building, roof)
		draw_rect(building.grow(-7), roof.lightened(0.06), false, 2.0)
		draw_rect(Rect2(building.position + Vector2(17, 17), Vector2(24, 16)), roof.darkened(0.2))
	if is_instance_valid(marker) and marker.button_pressed:
		draw_rect(Rect2(820, 408, 270, 220), OsTokens.ACCENT, false, 4.0)
	draw_set_transform(Vector2.ZERO)
	var font: Font = get_theme_default_font()
	for item: Array in [[Vector2(410, 390), "NORTH STREET"], [Vector2(800, 693), "DEPOT STREET"], [Vector2(1510, 120), "CANAL"]]:
		draw_string(font, screen_from_world(item[0]), item[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("8b9c9f"))
