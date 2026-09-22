class_name OsMaterials
extends RefCounted

const DIFFUSE_SHADER: Shader = preload("res://game/ui/theme/charcoal_diffuse.gdshader")

const ROLE_CHASSIS: String = "chassis"
const ROLE_SURFACE: String = "surface"
const ROLE_WELL: String = "well"

const GRAIN_STRENGTH: float = 0.008
const MOTTLE_STRENGTH: float = 0.018


static func apply_diffuse(target: CanvasItem, role: String, identity: String) -> void:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = DIFFUSE_SHADER
	var role_factor: float = 0.78 if role == ROLE_CHASSIS else (0.96 if role == ROLE_WELL else 1.0)
	material.set_shader_parameter("grain_strength", GRAIN_STRENGTH * role_factor)
	material.set_shader_parameter("mottle_strength", MOTTLE_STRENGTH * role_factor)
	material.set_shader_parameter("material_seed", _seed(identity))
	target.material = material


static func has_diffuse_material(target: CanvasItem) -> bool:
	if not target.material is ShaderMaterial:
		return false
	var material: ShaderMaterial = target.material as ShaderMaterial
	return material.shader == DIFFUSE_SHADER


static func contract() -> Dictionary:
	return {
		"grain_strength": GRAIN_STRENGTH,
		"mottle_strength": MOTTLE_STRENGTH,
		"roles": [ROLE_CHASSIS, ROLE_SURFACE, ROLE_WELL],
	}


static func _seed(identity: String) -> float:
	var value: int = 17
	for index: int in range(identity.length()):
		value = (value * 31 + identity.unicode_at(index)) % 9973
	return float(value) / 9973.0
