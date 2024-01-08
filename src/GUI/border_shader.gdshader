shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 distance_center = vec2(0.5, 0.5) - UV;
	
	float distance = sqrt((distance_center.x * distance_center.x) + ((distance_center.y * distance_center.y) * 1.1));
	
	if (distance < 0.4) {
		discard;
	}
	vec4 color = vec4(texture(TEXTURE, UV).rgb, (distance - 0.4) / 1.0);
	
	COLOR *= color;
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
