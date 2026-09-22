class_name SkeletonSession
extends RefCounted

signal changed

const INITIAL_CASH_CENTS: int = 1000
const MAX_CASH_CENTS: int = 1000000000000
const MAX_ELAPSED_MINUTES: int = 1000000000
const MAX_COMPLETED_ACTIONS: int = 1000000

var _definition: SkeletonWorkDefinition
var _cash_cents: int = INITIAL_CASH_CENTS
var _elapsed_minutes: int = 0
var _completed_actions: int = 0


func _init(definition: SkeletonWorkDefinition = null) -> void:
	# Own the command inputs; callers cannot change a live action by mutating a Resource.
	if definition != null:
		_definition = definition.duplicate(true) as SkeletonWorkDefinition


func snapshot() -> Dictionary:
	return {
		"cash_cents": _cash_cents,
		"elapsed_minutes": _elapsed_minutes,
		"completed_actions": _completed_actions,
	}


func can_work() -> bool:
	if _definition == null or not _definition.is_valid_definition():
		return false
	return _cash_cents <= MAX_CASH_CENTS - _definition.payout_cents \
		and _elapsed_minutes <= MAX_ELAPSED_MINUTES - _definition.duration_minutes \
		and _completed_actions < MAX_COMPLETED_ACTIONS


func perform_work() -> Error:
	if not can_work():
		return ERR_INVALID_DATA
	# Validate all preconditions before changing any authoritative field.
	_cash_cents += _definition.payout_cents
	_elapsed_minutes += _definition.duration_minutes
	_completed_actions += 1
	changed.emit()
	return OK


func reset() -> void:
	_cash_cents = INITIAL_CASH_CENTS
	_elapsed_minutes = 0
	_completed_actions = 0
	changed.emit()


func restore(value: Dictionary) -> Error:
	if not is_valid_snapshot(value):
		return ERR_INVALID_DATA
	_cash_cents = int(value["cash_cents"])
	_elapsed_minutes = int(value["elapsed_minutes"])
	_completed_actions = int(value["completed_actions"])
	changed.emit()
	return OK


static func is_bounded_integer(value: Variant, maximum: int) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false
	var number: float = float(value)
	return is_finite(number) and number >= 0.0 \
		and number <= float(maximum) and number == floor(number)


static func is_valid_snapshot(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var data: Dictionary = value
	if data.size() != 3 or not data.has_all([
		"cash_cents", "elapsed_minutes", "completed_actions",
	]):
		return false
	return is_bounded_integer(data["cash_cents"], MAX_CASH_CENTS) \
		and is_bounded_integer(data["elapsed_minutes"], MAX_ELAPSED_MINUTES) \
		and is_bounded_integer(data["completed_actions"], MAX_COMPLETED_ACTIONS)
