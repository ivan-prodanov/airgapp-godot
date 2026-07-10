shader_type spatial;
render_mode unshaded, skip_vertex_transform;

void vertex()
{
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	POINT_SIZE = UV.x*-150. / VERTEX.z;
}

void fragment()
{
	ALBEDO = COLOR.rgb;	
	ALPHA = COLOR.a * smoothstep(.5, 0.4, distance(POINT_COORD, vec2(0.5))); 
}
