shader_type spatial;

render_mode unshaded,blend_mix,depth_draw_never;

// Inputs:
uniform sampler2D sdf_volume_tex : hint_white;
uniform float sdf_edge_min = 0.4;
uniform float sdf_edge_max = 0.6;

uniform vec4 background_color : hint_color = vec4(0.9,0.9,0.9,1.0);
uniform float curb_gray = 0.5;
uniform float top_gray = 0.9;
uniform float fade_floor_height = 0.15;
uniform float fade_height = 2.0;
uniform float fade_overall = 1.0;
uniform float sdf_delta_to_shade = 2.5;
uniform float sdf_shade_max = 0.9;

uniform vec3 u_ego_space_min = vec3( -0.73, 0,  0.97 );
uniform vec3 u_ego_space_max = vec3(  0.73, 2, -3.72 );
uniform vec3 u_ego_space_scale = vec3(  1.0, 50.0, 1.0 );
uniform float u_ego_warn_dist = 2.0;
uniform float u_ego_warn_bright = 1.0;

uniform vec2 uv_world_dx = vec2(0.1, 0.0);
uniform vec2 uv_world_dy = vec2(0.0, 0.25);
uniform vec2 uv_world_dz = vec2(0.0, 0.1);

uniform vec3 u_world_crop_offset = vec3(0.0);
uniform vec3 u_world_crop_unit = vec3(0.01, 1.0, 0.01);
varying vec2 v_crop2;

varying vec3 v_world_pos;

float cropToEdgePct(float vCrop)
{
	const float minCrop = 0.5;
	float t = (vCrop - minCrop) / (1.0 - minCrop);
	return clamp( t, 0.0, 1.0 );
}

vec4 colorFromWorldY(float worldHeight)
{
	float unitScale = clamp( worldHeight / fade_height, 0.0, 1.0 );
	float floorScale = clamp( worldHeight / fade_floor_height, 0.0, 1.0 );

	float mainGrey = mix( curb_gray, top_gray, unitScale );
	vec3 mainColor = vec3(mainGrey,mainGrey,mainGrey);
	vec3 finalColor = mix( background_color.rgb, mainColor, floorScale * fade_overall);
	float finalAlpha = sqrt( 1.0 - unitScale );
	return vec4( finalColor, finalAlpha );
}

float sdfSampleToOpacity(float sdfValue) {
	float unclampedOpacity = (sdfValue - sdf_edge_min) / (sdf_edge_max - sdf_edge_min);
	float sdfOpacity = 1.0f - clamp(unclampedOpacity, 0.0, 1.0);
	return sdfOpacity;
}

vec3 blendByEgoDistance(vec3 baseColor, vec3 worldPos)
{
	vec3 nearestEgoPos = clamp(worldPos, u_ego_space_min, u_ego_space_max );
	float distToEgo = length( ( worldPos - nearestEgoPos ) * u_ego_space_scale );

	float warnPct = 1.0 - clamp( distToEgo / u_ego_warn_dist, 0.0, 1.0 );
	vec3 warnColor = vec3(1.0, 1.0 - warnPct, 0.0) * u_ego_warn_bright;

	return mix( baseColor, warnColor, warnPct );
}

void vertex()
{
	vec3 worldpos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_pos = worldpos;

	vec3 cropPos = ( ( worldpos.xyz - u_world_crop_offset) / u_world_crop_unit );
	v_crop2 = cropPos.xz;
}

vec3 sampleSDFNormalShading(vec2 uvCenter, float sdfCenter)
{
	// For simplicity, approximate the shading by taking the derivative
	// of the SDF in the UV.x (volume X) direction, and simply darking
	// the stronger values. sdf_delta_to_shade is in units of shade/delta_sdf.
	float dirDX = mix( 1.0, -1.0, step(0.5, uvCenter.x) ); // towards center to avoid edge
	vec2 uvDX = uvCenter + (uv_world_dx*dirDX);
	float rawSdfDX = texture(sdf_volume_tex,uvDX).g;
	float sdfDeltaDX = (rawSdfDX - sdfCenter)*dirDX;

	float rawNdotLApprox = abs(sdfDeltaDX * sdf_delta_to_shade);
	float shade = 1.0f - clamp( rawNdotLApprox, 0.0, sdf_shade_max );
	return vec3(1,1,1) * shade;
}

void fragment()
{
	float sdfValue = texture( sdf_volume_tex, UV ).g;
	if (sdfValue > sdf_edge_max) discard;

	vec2 cropSpace = abs(v_crop2);
	float v_crop = max( cropSpace.x, cropSpace.y );
	if (v_crop > 1.0) discard;

	vec4 baseColor = colorFromWorldY(v_world_pos.y);
	vec3 volColor = baseColor.rgb;
	volColor = blendByEgoDistance( volColor, v_world_pos );
	volColor *= sampleSDFNormalShading( UV, sdfValue );

	float volAlpha = fade_overall
		* sdfSampleToOpacity(sdfValue)
		* baseColor.a
		* (1.0 - cropToEdgePct(v_crop));

	ALBEDO = volColor;
	ALPHA = volAlpha;
}
