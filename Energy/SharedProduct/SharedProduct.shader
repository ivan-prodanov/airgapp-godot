shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, unshaded, world_vertex_coords, skip_vertex_transform;

uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D texture_mra : hint_white;

uniform vec4 glow_color : hint_color;
uniform float glow_strength : hint_range(0, 1);

uniform float alpha: hint_range(0, 1) = 1.0;

uniform vec3 LIGHT_DIRECTION = vec3(1.0, 0.0, 0.0);

varying vec2 v_ShineCoordinates;

void vertex() {
	v_ShineCoordinates = UV2.xy;
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = (WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
}

float lightStrength(vec3 normal_world, vec3 light_direction) {
	return pow(dot(normalize(light_direction), normal_world) * 0.5 + 0.5, 0.5);
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	//float glow_factor = glow_strength * COLOR.r;
	//glow_factor = 0.0;
	
	float light_strength = lightStrength(NORMAL, LIGHT_DIRECTION);
	
	vec3 color = albedo_tex.rgb * light_strength;
	
	float shine = mix(0.0, 1.0, (v_ShineCoordinates.x - 0.5)) * 1000.0;
	float shine_dark = mix(1.0, 0.95, smoothstep(0.0, 1.0, clamp(-v_ShineCoordinates.y + 2.5, 0.0, 1.0)));
	
	ALBEDO = color * mix(shine_dark, 1.0, clamp(shine, 0.0, 1.0));
	ALPHA = alpha;
	
	//EMISSION = glow_color.rgb * glow_factor;
}
