class_name IdFactory
extends RefCounted

# Deterministic IDs are unique within one saved timeline, not global UUIDs.
const MAX_ID: int = 1000000000
var _next_value: int = 1


func next_value() -> int:
	return _next_value


func can_allocate() -> bool:
	return _next_value <= MAX_ID


func allocate() -> String:
	if not can_allocate():
		return ""
	var value: String = "event_%010d" % _next_value
	_next_value += 1
	return value


func restore(value: Variant) -> Error:
	if not StateCodec.bounded_integer(value, MAX_ID + 1, 1):
		return ERR_INVALID_DATA
	_next_value = int(value)
	return OK
