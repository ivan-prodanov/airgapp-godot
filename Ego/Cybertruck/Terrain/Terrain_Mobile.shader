shader_type spatial;
render_mode depth_draw_always;

uniform sampler2D color_map;
uniform float color_repeat_factor = 1.0;
uniform vec2 color_repeat_offset = vec2(0.0, 0.0);
uniform float color_map_factor = 1.0;

uniform vec4 color_at : hint_color;
uniform vec4 color_away : hint_color;

uniform float fade_start_dist_sq;
uniform float fade_end_dist_sq;

uniform float cyber_terrain_fade_in = 1.0;

varying float v_distance_alpha;

void vertex()
{	
	VERTEX.y *= cyber_terrain_fade_in;
	
	vec3 vertex_world = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float vertex_dist_sq = vertex_world.x * vertex_world.x + vertex_world.z * vertex_world.z;
	v_distance_alpha = 1.0f - smoothstep(fade_start_dist_sq, fade_end_dist_sq, vertex_dist_sq);
}

void fragment()
{
	vec4 color_map_color = texture(color_map, UV * color_repeat_factor + color_repeat_offset);
	
	ALBEDO = color_map_factor * color_map_color.rgb + color_at.rgb;
  METALLIC = 1.0;
  ROUGHNESS = 0.8;
	
	ALPHA = color_map_color.a * cyber_terrain_fade_in * v_distance_alpha;
}