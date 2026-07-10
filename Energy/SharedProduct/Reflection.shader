shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never;

uniform sampler2D reflection_texture : hint_white;
uniform float intensity : hint_range(0, 1) = 1;
uniform float alpha : hint_range(0, 1) = 1;
uniform vec4 tint_color : hint_color = vec4(1.0);
uniform bool color_as_alpha = false;

void fragment() {
	if (color_as_alpha) {
		ALBEDO = tint_color.rgb;
		ALPHA = texture(reflection_texture, UV).r * intensity;
	} else {
		ALBEDO = texture(reflection_texture, UV).rgb * tint_color.rgb;
		float reflection_luminance = (0.299*ALBEDO.r + 0.587*ALBEDO.g + 0.114*ALBEDO.b);
		ALPHA = reflection_luminance * intensity * alpha;
	}
}