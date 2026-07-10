shader_type spatial;
render_mode  unshaded, skip_vertex_transform , depth_draw_never, cull_disabled, blend_add;

uniform vec4 u_top_color:hint_color = vec4(0.85,0.85,0.85,1.0);
uniform vec4 u_bottom_color:hint_color = vec4(0.15,0.15,0.15,1.0);
uniform float opacity = 1;

uniform vec3 divisions = vec3(256, 360, 12);
uniform vec3 volume_meters = vec3(100, 100, 4);
uniform vec3 position_offset_meters = vec3(0, 0, 0);
//varying vec2 worldpos;
varying vec3 v_color;
varying vec3 v_pos;
varying float v_z;
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
	float rightSize = step(divisions.x*0.5, pCol);

	vec3 grid_coord = vec3(pCol, pRow, pDepth) * voxel_size;
	grid_coord = vec3(grid_coord.x, grid_coord.z, grid_coord.y);

	v_pos = VERTEX;
	//worldpos = (WORLD_MATRIX * vec4(grid_coord.x,0.0,grid_coord.z, 1.0)).xz;	
	NORMAL = normalize(VERTEX);
	VERTEX *= vec3(0.35,0.08, 0.16);
	VERTEX *= 1.0 - step(320, pRow);
	VERTEX*= abs(rightSize - step(1.1, abs(UV.y)));
	VERTEX += grid_coord;
	v_z = pRow;

	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

	v_color = mix(u_bottom_color, u_top_color, pDepth/divisions.z).rgb;
}

void fragment()
{
	ALBEDO = v_color;
	ALPHA = opacity * smoothstep(0.47, 0.43, length(mod((v_pos.xy+vec2(1))*vec2(2.0, 0.5), vec2(1.0)) - vec2(0.5))) * 0.33;
}
