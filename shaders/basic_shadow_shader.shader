shader_type spatial;
render_mode depth_draw_never, unshaded;

uniform sampler2D tex_frg_2;
uniform float alpha;
uniform float opacity = 1.0;
varying float v_fog;

void vertex()
{
	v_fog = clamp((-WORLD_MATRIX[3][2] - 5.0) / 120.0, 0.0, 1.0);
}

void fragment() {
// Texture:2
	vec3 n_out2p0;
	float n_out2p1;
	vec4 tex_frg_2_read = texture( tex_frg_2 , UV.xy );
	n_out2p0 = tex_frg_2_read.rgb;
	n_out2p1 = tex_frg_2_read.a;

// ScalarUniform:3
	float n_out3p0;
	n_out3p0 = alpha;

// ScalarOp:4
	float n_out4p0;
	n_out4p0 = n_out2p1 * n_out3p0;

// Output:0
	ALBEDO = n_out2p0;
	ALPHA = n_out4p0 * (1.0-v_fog) * opacity;

}
