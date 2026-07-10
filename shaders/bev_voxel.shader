shader_type spatial;
render_mode  unshaded, skip_vertex_transform , depth_draw_always, cull_front;

uniform vec4 u_top_color:hint_color = vec4(0.85,0.85,0.85,1.0);
uniform vec4 u_bottom_color:hint_color = vec4(0.15,0.15,0.15,1.0);

uniform vec3 divisions = vec3(256, 360, 12);
uniform vec3 volume_meters = vec3(100, 100, 4);
uniform vec3 position_offset_meters = vec3(0, 0, 0);
uniform float opacity = 1;
varying vec3 v_color;
varying vec3 v_pos;
varying float v_z;
varying float v_clip;
void vertex()
{
	vec3 voxel_size = volume_meters / divisions;
	float layer_count = divisions.x * divisions.y;

    // Vectex array (VERTEX.x) is just a list of cell indices.  Convert this to x,y,z (grid_coord)
	float idx = UV.x;
	float pDepth = floor(idx/layer_count);
	float w = mod(idx , layer_count);
	float pRow = floor(w / divisions.x);         
	float pCol = mod(w, divisions.x);

	vec3 grid_coord = vec3(pCol, pRow, pDepth) * voxel_size;
	grid_coord = vec3(grid_coord.x, grid_coord.z, grid_coord.y);

	v_pos = VERTEX;

	NORMAL = normalize(VERTEX);
	VERTEX *= 0.18;
	VERTEX += grid_coord;
	v_clip = 1.0 - step(319, pRow);
	
	VERTEX *= 1.0 - step(320, pRow);
	v_z = pRow;

	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

	v_color = mix(u_bottom_color, u_top_color, pDepth/divisions.z).rgb;
}

void fragment()
{
	ALBEDO = v_color;
	ALPHA = 0.0;
	ALPHA += step(0.9999, v_pos.z) * smoothstep(0.5, 0.4, length(v_pos.xy)) * v_clip;
	ALPHA *= smoothstep(0, 5, v_z) * opacity;
}