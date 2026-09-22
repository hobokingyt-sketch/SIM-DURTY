class_name OsPresentationState
extends RefCounted

signal changed
var _work_id: String = ""
var _selected_id: String = ""
var _navigation: OsAppNavigation = OsAppNavigation.new()

func configure(work_id: String) -> void:
	_work_id = work_id
	if _selected_id != _work_id:
		_selected_id = ""
	changed.emit()

func select_work(work_id: String) -> Error:
	if work_id.is_empty() or work_id != _work_id:
		return ERR_INVALID_PARAMETER
	_selected_id = work_id
	changed.emit()
	return OK

func clear_selection() -> void:
	_selected_id = ""
	_navigation.return_to_city()
	changed.emit()

func open_app(app_id: String, requested_view: String = "") -> Error:
	if app_id == "city":
		_navigation.return_to_city()
		changed.emit()
		return OK
	if app_id == "operations" and _work_id.is_empty():
		return ERR_UNAVAILABLE
	if app_id == "operations" and _selected_id.is_empty():
		_selected_id = _work_id
	var error: Error = _navigation.open_app(app_id, requested_view)
	if error == OK:
		changed.emit()
	return error

func open_deep_link(app_id: String, view_id: String, work_id: String = "") -> Error:
	var old_selected: String = _selected_id
	var old_route: Dictionary = _navigation.snapshot()["route"]
	if not work_id.is_empty():
		var select_error: Error = select_work(work_id)
		if select_error != OK:
			return select_error
	var error: Error = open_app(app_id, view_id)
	if error != OK:
		_selected_id = old_selected
		_navigation.return_to_city()
		if old_route.get("kind") == "app":
			_navigation.open_app(str(old_route["app_id"]), str(old_route["view_id"]))
		changed.emit()
	return error

func navigate_view(view_id: String) -> Error:
	var error: Error = _navigation.navigate_view(view_id)
	if error == OK:
		changed.emit()
	return error

func back() -> bool:
	var moved: bool = _navigation.back()
	if moved:
		changed.emit()
	return moved

func return_to_city() -> void:
	_navigation.return_to_city()
	changed.emit()

func snapshot() -> Dictionary:
	var result: Dictionary = _navigation.snapshot()
	result["selected_id"] = _selected_id
	return result
