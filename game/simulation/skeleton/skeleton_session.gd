class_name SkeletonSession
extends RefCounted

signal changed
signal event_recorded(record: Dictionary)

const INITIAL_CASH_CENTS: int = 1000
const MAX_CASH_CENTS: int = 1000000000000
const MAX_ELAPSED_MINUTES: int = GameClock.MAX_TICK
const MAX_COMPLETED_ACTIONS: int = 1000000
const SPINE_VERSION: int = 1
const EVENT_LIMIT: int = 32

var _definition: SkeletonWorkDefinition
var _cash_cents: int = INITIAL_CASH_CENTS
var _completed_actions: int = 0
var _clock: GameClock = GameClock.new()
var _rng: SimulationRng = SimulationRng.new()
var _ids: IdFactory = IdFactory.new()
var _next_command: int = 1
var _last_roll: int = -1
var _events: Array[Dictionary] = []
var _mutating: bool = false


func _init(definition: SkeletonWorkDefinition = null) -> void:
	if definition != null:
		_definition = definition.duplicate(true) as SkeletonWorkDefinition


func snapshot() -> Dictionary:
	# Compatibility read model; elapsed_minutes derives from the only clock.
	return {"cash_cents": _cash_cents, "elapsed_minutes": _clock.tick(), "completed_actions": _completed_actions}


func spine_snapshot() -> Dictionary:
	return {
		"version": SPINE_VERSION, "tick": _clock.tick(), "rng": _rng.snapshot(),
		"next_id": _ids.next_value(), "next_command": _next_command, "last_roll": _last_roll,
	}


func checkpoint() -> Dictionary:
	return {"state": snapshot(), "spine": spine_snapshot()}


func state_hash() -> String:
	var data: Dictionary = checkpoint()
	data["work"] = [String(_definition.activity_id), _definition.payout_cents, _definition.duration_minutes] \
		if _definition != null else []
	return StateCodec.fingerprint(data)


func recent_events() -> Array[Dictionary]:
	return _events.duplicate(true)


func next_command_sequence() -> int:
	return _next_command


func can_work() -> bool:
	# Availability is a read model, including during notification. execute guards mutation.
	if _definition == null or not _definition.is_valid_definition():
		return false
	return _ids.can_allocate() and _cash_cents <= MAX_CASH_CENTS - _definition.payout_cents \
		and _clock.can_advance(_definition.duration_minutes) and _completed_actions < MAX_COMPLETED_ACTIONS


func perform_work() -> Error:
	return execute({"sequence": _next_command, "type": "work", "amount": 0})


func advance_minutes(minutes: int) -> Error:
	return execute({"sequence": _next_command, "type": "advance", "amount": minutes})


func sample_random() -> Error:
	# Diagnostic command only; it never changes the errand payout or invents game risk.
	return execute({"sequence": _next_command, "type": "rng_probe", "amount": 0})


func execute(command: Dictionary) -> Error:
	if _mutating:
		return ERR_BUSY
	if command.size() != 3 or not command.has_all(["sequence", "type", "amount"]):
		return ERR_INVALID_DATA
	if typeof(command["sequence"]) != TYPE_INT or typeof(command["amount"]) != TYPE_INT \
			or typeof(command["type"]) != TYPE_STRING:
		return ERR_INVALID_DATA
	if int(command["sequence"]) != _next_command or not _ids.can_allocate():
		return ERR_INVALID_PARAMETER
	var kind: String = command["type"]
	var amount: int = command["amount"]
	# Validate every precondition before consuming time, IDs or random draws.
	match kind:
		"work":
			if amount != 0 or not can_work():
				return ERR_INVALID_DATA
		"advance":
			if amount > 1440 or not _clock.can_advance(amount):
				return ERR_INVALID_PARAMETER
		"rng_probe":
			if amount != 0 or not _rng.can_draw():
				return ERR_INVALID_PARAMETER
		_:
			return ERR_INVALID_DATA
	_mutating = true
	match kind:
		"work":
			_cash_cents += _definition.payout_cents
			_completed_actions += 1
			_clock.advance(_definition.duration_minutes)
		"advance":
			_clock.advance(amount)
		"rng_probe":
			_last_roll = _rng.draw_u32()
	var record: Dictionary = {
		"id": _ids.allocate(), "sequence": _next_command,
		"tick": _clock.tick(), "type": kind, "amount": amount,
	}
	if kind == "rng_probe":
		record["value"] = _last_roll
	_next_command += 1
	_events.append(record.duplicate(true))
	if _events.size() > EVENT_LIMIT:
		_events.pop_front()
	event_recorded.emit(record.duplicate(true))
	changed.emit()
	_mutating = false
	return OK


func reset() -> void:
	if _mutating:
		return
	var seed_value: int = int(_rng.snapshot()["seed"])
	_cash_cents = INITIAL_CASH_CENTS
	_completed_actions = 0
	_clock.restore(0)
	_ids.restore(1)
	_rng.reseed(seed_value)
	_next_command = 1
	_last_roll = -1
	_events.clear()
	_mutating = true
	changed.emit()
	_mutating = false


func restore(value: Dictionary, spine: Dictionary = {}) -> Error:
	if _mutating:
		return ERR_BUSY
	if not is_valid_snapshot(value):
		return ERR_INVALID_DATA
	var incoming: Dictionary = default_spine(value) if spine.is_empty() else spine
	var error: Error = validate_spine(incoming, value)
	if error != OK:
		return error
	# Build replacements before publishing any part of the restored state.
	var new_clock: GameClock = GameClock.new()
	var new_rng: SimulationRng = SimulationRng.new()
	var new_ids: IdFactory = IdFactory.new()
	new_clock.restore(incoming["tick"])
	new_rng.restore(incoming["rng"])
	new_ids.restore(incoming["next_id"])
	_clock = new_clock
	_rng = new_rng
	_ids = new_ids
	_cash_cents = int(value["cash_cents"])
	_completed_actions = int(value["completed_actions"])
	_next_command = int(incoming["next_command"])
	_last_roll = int(incoming["last_roll"])
	# Diagnostic journal is not durable authority; never invent missing history.
	_events.clear()
	_mutating = true
	changed.emit()
	_mutating = false
	return OK


static func default_spine(state: Dictionary) -> Dictionary:
	var rng: SimulationRng = SimulationRng.new()
	return {
		"version": SPINE_VERSION, "tick": int(state["elapsed_minutes"]),
		"rng": rng.snapshot(), "next_id": int(state["completed_actions"]) + 1,
		"next_command": int(state["completed_actions"]) + 1, "last_roll": -1,
	}


static func validate_spine(value: Variant, state: Dictionary) -> Error:
	if not is_valid_snapshot(state) or not value is Dictionary:
		return ERR_INVALID_DATA
	var data: Dictionary = value
	if data.size() != 6 or not data.has_all(["version", "tick", "rng", "next_id", "next_command", "last_roll"]):
		return ERR_INVALID_DATA
	if not StateCodec.bounded_integer(data["version"], 1000000):
		return ERR_INVALID_DATA
	if int(data["version"]) != SPINE_VERSION:
		return ERR_UNAVAILABLE
	if not StateCodec.bounded_integer(data["tick"], MAX_ELAPSED_MINUTES) \
			or int(data["tick"]) != int(state["elapsed_minutes"]):
		return ERR_INVALID_DATA
	if not StateCodec.bounded_integer(data["next_id"], IdFactory.MAX_ID + 1, 1) \
			or not StateCodec.bounded_integer(data["next_command"], IdFactory.MAX_ID + 1, 1):
		return ERR_INVALID_DATA
	if int(data["next_id"]) != int(data["next_command"]) \
			or int(data["next_command"]) <= int(state["completed_actions"]):
		return ERR_INVALID_DATA
	if not StateCodec.bounded_integer(data["last_roll"], 4294967295, -1):
		return ERR_INVALID_DATA
	var rng_error: Error = SimulationRng.validate(data["rng"])
	if rng_error != OK:
		return rng_error
	var draws: int = int(data["rng"]["draws"])
	if draws > int(data["next_command"]) - 1 - int(state["completed_actions"]) \
			or (draws == 0) != (int(data["last_roll"]) == -1):
		return ERR_INVALID_DATA
	return OK


static func is_bounded_integer(value: Variant, maximum: int) -> bool:
	return StateCodec.bounded_integer(value, maximum)


static func is_valid_snapshot(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var data: Dictionary = value
	if data.size() != 3 or not data.has_all(["cash_cents", "elapsed_minutes", "completed_actions"]):
		return false
	return is_bounded_integer(data["cash_cents"], MAX_CASH_CENTS) \
		and is_bounded_integer(data["elapsed_minutes"], MAX_ELAPSED_MINUTES) \
		and is_bounded_integer(data["completed_actions"], MAX_COMPLETED_ACTIONS)
