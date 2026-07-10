shader_type spatial;
render_mode unshaded, skip_vertex_transform, cull_disabled;

uniform float dist = 0;
uniform float unit_blur = 0.1;
uniform sampler2D bev_layer : hint_white;
uniform sampler2D bev_line_color : hint_white;

uniform vec3 u_world_crop_offset = vec3(0.0);
uniform vec3 u_world_crop_unit = vec3(0.01, 1.0, 0.01);

varying vec2 worldpos;
varying float v_crop;
varying vec3 col;
// COLOR.r = color LUT
// COLOR.g = double line
// COLOR.b = dashed line
// COLOR.a = opacity (used be width)

void vertex()
{
	vec4 modelPos = vec4(VERTEX.x,0.0,VERTEX.z, 1.0);
	vec4 worldPos3d = (WORLD_MATRIX * modelPos);
	worldpos = worldPos3d.xz;
	VERTEX = (MODELVIEW_MATRIX * modelPos).xyz;
	
	// Sample color from texture in vertex shader:
	col = texture(bev_line_color, vec2(COLOR.r, 0.0)).rgb;

	vec3 cropPos = abs( ( worldPos3d.xyz - u_world_crop_offset) / u_world_crop_unit );
	float cropVal = max( cropPos.x, cropPos.z );
	v_crop = cropVal;
}

float dashed_line(vec2 uv, float dash_value, float dlb_value)
{
	float dash_size = 1.0;
	float alongWave = sin(worldpos.y*dash_size - dist*2.);
	float alongDashUnit = smoothstep(-unit_blur,unit_blur,alongWave);
	float alongDash = mix(1.0, alongDashUnit, dash_value);
	float acrossPaint = 1.0-(smoothstep(0.4, 0.1, abs(uv.x)) * dlb_value); // double line

	float acrossUnitSingle = abs(uv.x); // -1~1 to 0~1
	float acrossUnitDbl = abs(acrossUnitSingle - 0.5) * 2.0;
	float acrossUnit = mix( acrossUnitSingle, acrossUnitDbl, dlb_value);
	float acrossFade = 1.0 - (acrossUnit * acrossUnit);

	return  alongDash * acrossPaint * acrossFade;
}

float dotted_line(vec2 uv, float dash_value, float dlb_value)
{
	float split = 2.0 - step(0.1, dlb_value);
	float blur = unit_blur * 0.5;
	vec2 sub_uv =vec2(mod(uv.x+1.0,split)/split, mod(worldpos.y- dist*2., 1.0)*5.0);
	return smoothstep(0.5+blur, 0.5-blur, distance(sub_uv*vec2((1.0+dlb_value)*0.5*split, 1.0), vec2(0.5, 0.5)));
}

void fragment()
{
	if (v_crop < 1.0) discard;

	vec2 bevUv = worldpos/75.0;
	bevUv += vec2(0.5, .85);

	ALBEDO = col;

	float dash_raw = COLOR.b;// 0.0 is solid, 0.5 is dashed, 1.0 is dotted
	float dash_value = clamp(dash_raw*2.0, 0.0, 1.0); // 0~0.5 to 0~1
	dash_value *= dash_value;
	float is_dot = clamp((dash_raw-0.5)*2.0, 0.0, 1.0); // 0.5~1 to 0~1

	float dlb_line_raw = COLOR.g;
	float dlb_value = dlb_line_raw * dlb_line_raw * dlb_line_raw; // bias away from center

	float line = dashed_line(UV, dash_value, dlb_value);
	float dotted = dotted_line(UV, dash_value, dlb_value);
	float dashedness = mix(line, dotted, is_dot);

	float finalAlpha = dashedness * COLOR.a;
	ALPHA = finalAlpha;
}
