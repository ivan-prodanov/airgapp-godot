shader_type spatial;

render_mode unshaded, cull_disabled;

uniform vec4 background_color : hint_color = vec4(0.9,0.9,0.9,1.0);
uniform float curb_gray = 0.5;
uniform float top_gray = 0.9;
uniform float fade_floor_height = 0.15;
uniform float fade_height = 2.0;
uniform float fade_overall = 1.0;

varying vec3 worldpos;

void vertex()
{
	worldpos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment()
{
	float worldHeight = worldpos.y;
	float unitScale = clamp( worldHeight / fade_height, 0.0, 1.0 );
	float floorScale = clamp( worldHeight / fade_floor_height, 0.0, 1.0 );

	float mainGrey = mix( curb_gray, top_gray, unitScale );
	vec3 mainColor = vec3(mainGrey,mainGrey,mainGrey);
	vec3 finalColor = mix( background_color.rgb, mainColor, floorScale * fade_overall);
	ALBEDO = finalColor;
	//ALPHA= frag.a;
}
