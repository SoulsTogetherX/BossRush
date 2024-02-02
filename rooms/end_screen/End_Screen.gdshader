shader_type canvas_item;

void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	if (pixelColor.r > 0.5) {
		pixelColor.rgb = vec3(0.0);
	} else {
		pixelColor.rgb = vec3(1.0);
	} 
	
	COLOR = pixelColor;
}