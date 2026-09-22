class_name SimulationRng
extends RefCounted

const DEFAULT_SEED: int = 184726
const MAX_SEED: int = 2147483647
const MAX_DRAWS: int = 1000000000
const CONTRACT: String = "godot-rng-state-v1"

var _generator: RandomNumberGenerator = RandomNumberGenerator.new()
var _seed_value: int = DEFAULT_SEED
var _draws: int = 0


func _init() -> void:
	_generator.seed = DEFAULT_SEED


func reseed(value: Variant) -> Error:
	if not StateCodec.bounded_integer(value, MAX_SEED):
		return ERR_INVALID_PARAMETER
	_seed_value = int(value)
	_generator.seed = _seed_value
	_draws = 0
	return OK


func can_draw() -> bool:
	return _draws < MAX_DRAWS


func draw_u32() -> int:
	if not can_draw():
		return -1
	_draws += 1
	return _generator.randi()


func snapshot() -> Dictionary:
	return {
		"contract": CONTRACT,
		"engine": engine_contract(),
		"seed": _seed_value,
		"state": str(_generator.state),
		"draws": _draws,
	}


func restore(value: Variant) -> Error:
	var error: Error = validate(value)
	if error != OK:
		return error
	var source: Dictionary = value
	_seed_value = int(source["seed"])
	# Setting seed changes state; always restore the saved state AFTER seed.
	_generator.seed = _seed_value
	_generator.state = String(source["state"]).to_int()
	_draws = int(source["draws"])
	return OK


static func engine_contract() -> String:
	return str(Engine.get_version_info().get("string", "unknown"))


static func validate(value: Variant) -> Error:
	if not value is Dictionary:
		return ERR_INVALID_DATA
	var source: Dictionary = value
	if source.size() != 5 or not source.has_all(["contract", "engine", "seed", "state", "draws"]):
		return ERR_INVALID_DATA
	if source["contract"] != CONTRACT or source["engine"] != engine_contract():
		return ERR_UNAVAILABLE
	if not StateCodec.bounded_integer(source["seed"], MAX_SEED) \
			or not StateCodec.signed_integer_text(source["state"]) \
			or not StateCodec.bounded_integer(source["draws"], MAX_DRAWS):
		return ERR_INVALID_DATA
	return OK
