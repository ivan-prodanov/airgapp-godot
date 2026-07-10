shader_type spatial;
render_mode unshaded;

uniform vec4 window_color: hint_color = vec4(0.0, 0.0, 0.0, 0.5);

void fragment() {
	ALBEDO = window_color.rgb;
	ALPHA = window_color.a;
}