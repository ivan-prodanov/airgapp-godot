shader_type spatial;
render_mode cull_back, unshaded, depth_draw_always;

uniform float brightness: hint_range(0, 1.0) = 1.0;
uniform sampler2D texture_window: hint_white;
uniform float alpha: hint_range(0, 1.0) = 1.0;
uniform vec4 glow_color: hint_color = vec4(1.0, 0.95, 0.8, 1.0);

void fragment() {
	vec3 data = texture(texture_window, UV).rgb;
	
	ALBEDO = (glow_color.rgb * data.r * brightness);
	ALPHA = alpha;
}