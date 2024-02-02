shader_type canvas_item;

uniform bool enabled = false;
uniform float white_ratio : hint_range(0.0, 1.0, 0.001) = 1.0;

void fragment() {
	if (enabled) {
		COLOR = vec4(mix(COLOR.rgb, vec3(1.0), white_ratio), COLOR.a);
	}
}