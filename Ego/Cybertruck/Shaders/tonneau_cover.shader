shader_type spatial;
render_mode cull_back;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D texture_ao : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);

varying float v_desired_view_alpha;
varying vec3 v_vertex_world;

void vertex()
{
	vec3 cam_world = CAMERA_MATRIX[3].xyz;
	v_vertex_world = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float dist_to_vert = length(v_vertex_world - cam_world);
	vec3 cam_to_vertex = normalize(v_vertex_world - cam_world);
	vec3 cam_fwd_xz_world = normalize(vec3(CAMERA_MATRIX[2][0],0.0,CAMERA_MATRIX[2][2]));
	vec3 normal_world =  normalize(WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float perpendicular_pct = (1.0f - abs(dot(normal_world, cam_to_vertex))) * abs(cam_fwd_xz_world.z);
	float angle_based_alpha = smoothstep(0.6, 0.8, perpendicular_pct);
	float distance_based_alpha = smoothstep(6.0, 8.0, dist_to_vert);
	v_desired_view_alpha = max(angle_based_alpha, distance_based_alpha);
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	AO = texture(texture_ao, base_uv).g;
	AO_LIGHT_AFFECT = 1.0;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	
	const float egoOffsetInWorld = -1.488; // Will need to be moved to uniform later
	const float tonneauOffsetInEgoSpace = 1.142;
	float position_alpha = step(tonneauOffsetInEgoSpace + egoOffsetInWorld, v_vertex_world.z);
	ALPHA = v_desired_view_alpha * position_alpha;
}
