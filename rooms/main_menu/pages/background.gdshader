shader_type canvas_item;

void fragment() {
	float dark = 1.0 - distance(UV, vec2(0.507, 0.85)) + (sin(TIME * 0.5) * 0.1);
	COLOR.a = mix(1.0, 0.0, dark);
}