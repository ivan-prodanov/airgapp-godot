shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never, skip_vertex_transform;

uniform float u_opacity = 1.0;
uniform vec4 u_color = vec4(0.5);
varying float v_fog;
varying vec2 worldpos;
uniform sampler2D bev_layer : hint_white;

void vertex()
{
	worldpos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xz;
	v_fog = 1.0-clamp((-WORLD_MATRIX[3][2] - 5.0) / 120.0, 0.0, 1.0);
	
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;	
}

void fragment() {
	vec2 bevUv = worldpos/75.0;
	bevUv += vec2(0.5, .85);
	
	float bev_mask = smoothstep(0.75, 1.0, texture(bev_layer,bevUv).r);
    float y_fade = smoothstep(0.0, 0.7, (0.5-abs(UV.x- 0.5)) * 2.0);
    float x_fade = smoothstep(0.1, 0.3, (0.5-abs(UV.y- 0.5)) * 2.0);
    float mask = y_fade*y_fade*y_fade * x_fade;
	//mask += 1.0;
	ALBEDO = u_color.rgb;
    ALPHA = mask * u_opacity * u_color.a * v_fog * bev_mask;
}