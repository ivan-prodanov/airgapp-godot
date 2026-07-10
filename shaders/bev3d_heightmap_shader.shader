shader_type spatial;
render_mode unshaded, blend_mix, skip_vertex_transform;
//options: unshaded, blend_mix, skip_vertex_transform, cull_disabled;

uniform vec4 bottom_color : hint_color = vec4(0.9,0.9,0.9,1.0);
uniform vec4 top_color : hint_color = vec4(0.9,0.9,0.9,1.0);
uniform vec4 warning_color : hint_color = vec4(1.0,0.0,0.0,1.0);
uniform float voxel_alpha = 0.2f;
uniform float voxel_use_warning_map = 0.0;

varying float heightmap_coord;

uniform sampler2D bev3d_height_map : hint_black;
uniform sampler2D bev3d_warning_map : hint_black;

const float voxel_height_m = 0.1f; // full scale would be 0.33f
const float voxel_max_height_cells = 12.0f;
const float voxel_max_color_cells = 7.0;
const float voxel_fade_in_cells = 6.0;
const float voxel_fade_power = 1.61;

void vertex()
{
	vec4 localCoord = vec4(VERTEX, 1.0);
	float rawH = texture(bev3d_height_map, UV).r;
	float unitH = clamp( rawH * 255.0, 0, voxel_max_height_cells );
	heightmap_coord = unitH;
	localCoord.y += unitH * voxel_height_m; // should be 0.33 for full height

	VERTEX = (MODELVIEW_MATRIX * localCoord).xyz;
}

void fragment()
{
	//float raw_h = texture(bev3d_height_map, UV).r * (255.0 / voxel_height);
	float h = heightmap_coord;
	if (h < 0.1) discard;

	float uh = min(1.0, h / voxel_max_color_cells);

	//return background_color;
	float alpha = voxel_alpha * pow( min(1.0, h / voxel_fade_in_cells), voxel_fade_power );
	ALPHA = alpha;

	vec3 color = mix(bottom_color.rgb, top_color.rgb, uh);

	float heightmap_warning = ((voxel_use_warning_map < 0.5) ? 0.0 :
		texture(bev3d_warning_map, UV).r);
	color = mix(color, warning_color.rgb, heightmap_warning);

	//vec3 color = vec3(1,0,0);
	ALBEDO = color;

}