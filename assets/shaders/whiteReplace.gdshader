shader_type canvas_item;

uniform bool enabled = false;

void fragment() {
	if (enabled) {
		COLOR = vec4(1.0, 1.0, 1.0, COLOR.a);
	}
}
