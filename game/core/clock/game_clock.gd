class_name GameClock
extends RefCounted

# One authoritative tick is one in-game minute. No wall-clock/frame callbacks.
const MAX_TICK: int = 1000000000
var _tick: int = 0


func tick() -> int:
	return _tick


func can_advance(minutes: int) -> bool:
	return minutes > 0 and minutes <= MAX_TICK - _tick


func advance(minutes: int) -> Error:
	if not can_advance(minutes):
		return ERR_INVALID_PARAMETER
	_tick += minutes
	return OK


func restore(value: Variant) -> Error:
	if not StateCodec.bounded_integer(value, MAX_TICK):
		return ERR_INVALID_DATA
	_tick = int(value)
	return OK
