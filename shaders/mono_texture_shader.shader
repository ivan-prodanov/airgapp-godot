shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;

// Inputs:
uniform sampler2D texture_custom : hint_white;
uniform vec4 main_color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float alpha_power = 1.0;

void vertex()
{
	// default transform
}

void fragment() {
	float monoOpacity = texture( texture_custom, UV.xy ).g;
	monoOpacity = pow( monoOpacity, alpha_power);

	if (monoOpacity < 0.01) discard;

	vec4 finalColor = main_color;
	float finalAlpha = main_color.a * monoOpacity;

	ALBEDO = finalColor.rgb;
    ALPHA = finalAlpha;
}
