
shader_type spatial;
render_mode unshaded, skip_vertex_transform, cull_disabled, depth_test_disable;

uniform sampler2D u_font : hint_albedo;

void vertex()
{
	vec4 pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
    pos /= pos.w;
	
    VERTEX.xy = pos.xy +  (UV2 * vec2(1.0/VIEWPORT_SIZE.x * .02 , 1.0/-VIEWPORT_SIZE.y * .02));
    VERTEX.z = pos.z;
}

void fragment()
{
	ALBEDO = mix(vec3(COLOR.a), COLOR.rgb, texture(u_font, UV).r);
}