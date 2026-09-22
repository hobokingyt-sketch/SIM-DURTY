shader_type canvas_item;
render_mode unshaded;

uniform float grain_strength : hint_range(0.0, 0.03) = 0.006;
uniform float mottle_strength : hint_range(0.0, 0.03) = 0.012;
uniform float material_seed = 0.0;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void fragment() {
	vec2 pixel = SCREEN_UV / SCREEN_PIXEL_SIZE;
	vec2 seed_offset = vec2(material_seed * 97.0, material_seed * 53.0);
	float broad = value_noise(pixel / 132.0 + seed_offset);
	float middle = value_noise(pixel / 52.0 + seed_offset * 1.7);
	float grain = hash21(floor(pixel) + seed_offset * 13.0);
	float variation =
		(broad - 0.5) * mottle_strength * 1.35 +
		(middle - 0.5) * mottle_strength * 0.45 +
		(grain - 0.5) * grain_strength;
	COLOR.rgb *= 1.0 + variation;
}
