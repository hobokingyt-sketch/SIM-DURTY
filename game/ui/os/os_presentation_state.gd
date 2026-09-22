class_name OsPresentationState
extends RefCounted

signal changed

var _work_id: String = ""
var _selected_id: String = ""
var _active_app: String = "city"
var _glance_open: bool = true


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
	_active_app = "city"
	changed.emit()


func open_app(app_id: String) -> Error:
	if app_id not in ["city", "operations"]:
		return ERR_INVALID_PARAMETER
	if app_id == "operations":
		if _work_id.is_empty():
			return ERR_UNAVAILABLE
		_selected_id = _work_id
	_active_app = app_id
	changed.emit()
	return OK


func set_glance_open(value: bool) -> void:
	_glance_open = value
	changed.emit()


func snapshot() -> Dictionary:
	return {"selected_id": _selected_id, "active_app": _active_app, "glance_open": _glance_open}
