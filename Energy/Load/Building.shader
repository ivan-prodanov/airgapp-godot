shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled, unshaded, skip_vertex_transform;

uniform sampler2D texture_light: hint_white;
uniform float theme: hint_range(0, 1) = 0.0;
uniform float alpha: hint_range(0, 1) = 1.0;
uniform vec4 albedo_light: hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 albedo_dark: hint_color = vec4(0.3, 0.31, 0.32, 1.0);
uniform float garage_height: hint_range(0, 100) = 100.0;
uniform float night_light_power: hint_range(0, 1) = 1;

// The color of nighttime lighting.
uniform vec4 night_light: hint_color = vec4(1.0, 0.95, 0.8, 1.0);

highp float rand(vec2 co) {
	highp float a = 12.9898;
	highp float b = 78.233;
	highp float c = 43758.5453;
	highp float dt= dot(co.xy ,vec2(a,b));
	highp float sn= mod(dt,3.14);
	return fract(sin(sn) * c);
}

float fade(float value, float by) {
	return mix(1.0 - by, 1.0, value);
}

varying float ambient_light;

void vertex() {
	vec3 sun_direction = mix(vec3(-0.5, 0.8, 2.5), vec3(-0.5, 0.3, 2.5), theme);
	
	float ambient_strength = mix(0.35, 0.81, theme);
	
	float sun_light = dot(NORMAL, sun_direction) * 0.5 + 0.5;
	
	ambient_light = (sun_light * (1.0 - ambient_strength)) + ambient_strength + mix(0.0, 0.06, theme);

    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
}

void fragment() {
	// The light data texture.
	vec4 light = texture(texture_light, UV);

	// Break out the data into separate floats.
	float environment = light.r;
	float tone = light.g;
	float night = light.b;

	// Hand-picked constants to balance appearance from light to dark.
	// These affect all buildings, and should be adjusted with caution.
	float environment_affect = mix(1.0, 0.5, theme);
	float night_affect = mix(1.0, 0.0, theme);
	
	//vec3 albedo_night = mix(albedo_dark.rgb, night_moonlight.rgb, 1.0 - environment);
	vec3 albedo = mix(albedo_dark.rgb, albedo_light.rgb, theme);
	
	// Tone is the bright/dark fakery that makes slats and roof look good.
	tone = pow(tone, 0.455) * 2.0 - 1.0;

	// Convert -1..1 to two 0..1 values.
	float tone_darken = max(tone * -1.0, 0.0);
	float tone_lighten = max(tone, 0.0);

	// Total light brightness. This is used to fade out tone where necessary.
	float light_brightness = pow(environment * environment_affect + (night * night_affect), 0.5);
	
	// Darkness.
	albedo *= 1.0 - tone_darken;//fade(1.0 - tone_darken, light_brightness);
	albedo += tone_lighten;// * light_brightness;
	
	// We use the albedo color here because we can't adjust the environment lighting (or hardware lighting would be wrong.)
	ALBEDO = albedo * fade(environment, environment_affect) * ambient_light + (night_light.rgb * night_affect * night * night_light_power);
	ALPHA = alpha;
	//ALBEDO = vec3(1.0) * ambient_light;
}
