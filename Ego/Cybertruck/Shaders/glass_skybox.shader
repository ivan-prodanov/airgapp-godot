shader_type spatial;

uniform float skybox_rot =  0.0;
uniform float metalic =  0.0;
uniform float roughness_parallel =  0.0;
uniform float roughness_perpendicular = 0.0;
uniform float specular = 0.0;
uniform vec4 color : hint_color = vec4(1.0);
uniform float alpha_perpendicular = 255.0;
uniform float roughness_saturated = 0.7;
uniform float color_mix_factor : hint_range(0.0, 1.0) = 0.0;

varying vec3 v_view;
varying float v_roughness;
varying float v_alpha;

void vertex()
{
	vec3 cam_world = vec3(CAMERA_MATRIX[3][0],CAMERA_MATRIX[3][1],CAMERA_MATRIX[3][2]);
	vec3 cam_fwd_world = vec3(CAMERA_MATRIX[2][0],CAMERA_MATRIX[2][1],CAMERA_MATRIX[2][2]);
	vec3 normal_world =  normalize(WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
	v_view = normalize((WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz - cam_world);
	float perpendicular_pct = 1.0f - abs(dot(normal_world, cam_fwd_world));
	
	v_roughness = mix(roughness_parallel, roughness_perpendicular, perpendicular_pct);
	v_alpha = mix(color.a, (alpha_perpendicular / 255.0), perpendicular_pct);
}

void fragment()
{
	ROUGHNESS = mix(v_roughness, roughness_saturated, color_mix_factor);
	METALLIC = metalic;
	ALBEDO = color.rgb;
	SPECULAR = mix(specular, 0.0, color_mix_factor * 0.5);
	ALPHA = v_alpha;
}
