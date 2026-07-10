shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;

// Inputs:
uniform sampler2D texture_custom : hint_white;
// and COLOR (default is white with full alpha)

void vertex()
{
	// default transform
}

void fragment() {
	vec4 textureVal = texture( texture_custom, UV.xy );
	vec4 vertexColor = COLOR.rgba;

	vec4 finalVal = textureVal * vertexColor;

	ALBEDO = finalVal.rgb;
    ALPHA = finalVal.a;
}