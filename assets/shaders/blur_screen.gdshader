shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float amount : hint_range(0.0, 5.0);
uniform float darken : hint_range(0.0, 1.0);

void fragment() {
	COLOR.rgb = textureLod(SCREEN_TEXTURE, SCREEN_UV, amount).rgb * darken;
}