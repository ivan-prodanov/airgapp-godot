shader_type spatial;

render_mode unshaded;
uniform sampler2D shadow_atlas;

void fragment()
{
	vec3 shadow =  texture(shadow_atlas, UV).rgb;
	ALBEDO = vec3(0.0);
	ALPHA = 1.0-shadow.r;
}