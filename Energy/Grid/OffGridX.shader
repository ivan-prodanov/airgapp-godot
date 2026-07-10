shader_type spatial;
render_mode unshaded, cull_back;

uniform vec4 color : hint_color;
uniform float side_brightness : hint_range(0, 1) = 0.5;
uniform vec3 forward = vec3(0.0, 1.0, 0.0);

void fragment() {
	float brightness = mix(side_brightness, 1.0, dot(NORMAL, forward));
	ALBEDO = color.rgb * brightness;
}