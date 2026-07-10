shader_type spatial;
render_mode cull_back, unshaded;

uniform sampler2D texture_light : hint_white;

uniform vec4 normal_color : hint_color;
uniform vec4 shade_color : hint_color;
//uniform vec4 alert_color : hint_color;

//uniform float alert_mix: hint_range(0, 1);
uniform float brightness: hint_range(0, 1);

void fragment() {
	vec4 light_tex = texture(texture_light, UV);
	float light_shade = light_tex.b;
	float light_shape = light_tex.g;
	
	float shade_strength = light_shade;
	float pixel_brightness = light_shape * brightness;
	
	ALBEDO = normal_color.rgb;//mix(shade_color.rgb * shade_strength, normal_color.rgb, light_shape);
	ALPHA = pixel_brightness;
}
