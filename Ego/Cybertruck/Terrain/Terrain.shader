shader_type spatial;
render_mode depth_draw_always;

uniform sampler2D color_map;
uniform vec2 color_repeat_offset = vec2(0.0, 0.0);
uniform float color_map_factor = 1.0;
uniform float color_map_flat_factor = 1.0;
uniform float distance_dim_factor;
uniform float roughness;
uniform float metallic;

uniform sampler2D ao;
uniform float ao_light_affect;

uniform vec4 color : hint_color;

uniform float fade_start_dist_sq;
uniform float fade_end_dist_sq;

uniform float cyber_terrain_fade_in = 1.0;

varying float v_normal_up_factor;
varying float v_vertex_far_factor;
varying float v_distance_dim_factor;
varying float v_distance_alpha;

void vertex()
{	
	VERTEX.y *= cyber_terrain_fade_in;
	
	vec3 vertex_world = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 normal_world = normalize(WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
	v_normal_up_factor = smoothstep(0.98, 1.0, normal_world.y);
	
	vec3 vertex_camera = (INV_CAMERA_MATRIX * vec4(vertex_world, 1.0)).xyz;
	v_vertex_far_factor = smoothstep(5.0, 15.0, -vertex_camera.z);
	
	float vertex_dist_sq = vertex_world.x * vertex_world.x + vertex_world.z * vertex_world.z;
	v_distance_alpha = 1.0f - smoothstep(fade_start_dist_sq, fade_end_dist_sq, vertex_dist_sq);
	
	v_distance_dim_factor = max( 0.0, min( 1.0, length( VERTEX.xz ) * 0.1 ) );
}

void fragment()
{
	vec4 color_map_color = texture(color_map, UV + color_repeat_offset);
	float color_map_contribution = color_map_factor + v_normal_up_factor * v_vertex_far_factor * color_map_flat_factor;
	
	ALBEDO = ( 1.0 - v_distance_dim_factor * distance_dim_factor ) * color_map_contribution * color_map_color.rgb + color.rgb;
	ALPHA = color_map_color.a * color.a * cyber_terrain_fade_in * v_distance_alpha;
	
	ROUGHNESS = clamp( roughness + v_distance_dim_factor * 0.2, 0.0, 1.0 );
	METALLIC = metallic;
	
	AO = texture(ao, UV).b;
	AO_LIGHT_AFFECT = ao_light_affect;
}