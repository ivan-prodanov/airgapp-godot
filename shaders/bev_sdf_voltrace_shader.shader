shader_type spatial;

render_mode unshaded,blend_mix,depth_draw_never;

// Currently only for reference, a ray-traced SDF renderer.

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

uniform vec2 uv_world_dx = vec2(0.1, 0.0);
uniform vec2 uv_world_dy = vec2(0.0, 0.25);
uniform vec2 uv_world_dz = vec2(0.0, 0.1);

uniform vec3 u_world_crop_offset = vec3(0.0);
uniform vec3 u_world_crop_unit = vec3(0.01, 1.0, 0.01);
varying float v_crop;

varying vec3 v_world_pos;
varying vec3 v_camera_forward;

float cropToEdgePct(float vCrop)
{
	const float minCrop = 0.75;
	float t = (vCrop - minCrop) / (1.0 - minCrop);
	return clamp( t, 0.0, 1.0 );
}

vec3 colorFromWorldY(float worldHeight)
{
	float unitScale = clamp( worldHeight / fade_height, 0.0, 1.0 );
	float floorScale = clamp( worldHeight / fade_floor_height, 0.0, 1.0 );

	float mainGrey = mix( curb_gray, top_gray, unitScale );
	vec3 mainColor = vec3(mainGrey,mainGrey,mainGrey);
	vec3 finalColor = mix( background_color.rgb, mainColor, floorScale * fade_overall);
	return finalColor;
}

float sdfSampleToOpacity(float sdfValue) {
	float unclampedOpacity = (sdfValue - sdf_edge_min) / (sdf_edge_max - sdf_edge_min);
	float sdfOpacity = 1.0f - clamp(unclampedOpacity, 0.0, 1.0);
	return sdfOpacity;
}

void vertex()
{
	vec3 worldpos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_pos = worldpos;

	vec3 world_camera = (CAMERA_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	v_camera_forward = normalize(worldpos - world_camera);

	vec3 cropPos = abs( ( worldpos.xyz - u_world_crop_offset) / u_world_crop_unit );
	float cropVal = max( cropPos.x, cropPos.z );
	v_crop = cropVal;
}

float sampleVolumeByUV(vec2 uv)
{
	if ((uv.y <= 1.0f) && (uv.y >= 0.0f)
	 && (uv.x <= 1.0f) && (uv.x >= 0.0f))
	{
		return texture( sdf_volume_tex, uv ).g;
	} else {
		return 1.0f;
	}
}

vec3 sampleSDFNormalShading(vec2 uvCenter, float sdfCenter)
{
	float sdfDX = sampleVolumeByUV( uvCenter + uv_world_dx ) - sdfCenter;
	float sdfDY = sampleVolumeByUV( uvCenter + uv_world_dy ) - sdfCenter;
	float sdfDZ = sampleVolumeByUV( uvCenter + uv_world_dz ) - sdfCenter;

	vec3 sdfNormalDir = vec3( sdfDX, sdfDY, sdfDZ );
	float nDotL = dot(normalize(sdfNormalDir),normalize(vec3(1,1,1)));
	return vec3(0.5,0.5,0.5) + (vec3(1,1,1) * (nDotL * 0.5));
}

vec4 blendAtUVAndWorld(vec4 baseColor, vec2 uv, vec3 worldPos)
{
	float sdfValue = sampleVolumeByUV(uv);
	if (sdfValue > sdf_edge_max) return baseColor;

	float sdfOpacity = sdfSampleToOpacity(sdfValue);
	vec3 shading = sampleSDFNormalShading(uv, sdfValue);
	vec3 volColor = colorFromWorldY(worldPos.y) * shading;
	vec3 dst = volColor;
	if (baseColor.a > 0.0) {
		dst = mix( baseColor.rgb, volColor.rgb, sdfOpacity );
	}
	float dstA = mix( baseColor.a, 1.0, sdfOpacity );
	return vec4( dst, dstA );
}

vec2 clampUV(vec2 uv) {
	return clamp(uv, vec2(0,0), vec2(1,1));
}

vec4 volumeTrace(vec3 camFwd, vec2 startUV, float startUVY, vec3 worldPos)
{
	vec3 camMaxStep = camFwd;// * (1.0 / abs(camFwd.y));// * w2v_thickness_m * ;
	vec2 stepUV = ( uv_world_dx * camFwd.x ) + ( uv_world_dz * camFwd.z );
	float stepDYInUV = camFwd.y;
	vec2 stepYStep = uv_world_dy;

	vec4 result = background_color;
	result.a = 0.0;

	const float maxVoxelsWalk = 40.0f;
	const int totalSteps = 40;
	const float invTotalSteps = maxVoxelsWalk / float(totalSteps);
	// Multiple taps into volume (back to front):
	for (int i=totalSteps-1; i>=0; i--) {
		float unitStep = float(i) * invTotalSteps;
		vec2 uvDY = (stepYStep * floor(startUVY + (unitStep * stepDYInUV)));
		vec2 uv = clampUV(startUV + ( stepUV * unitStep )) + uvDY;
		vec3 pos = worldPos + (camMaxStep * unitStep);

		result = blendAtUVAndWorld(result, uv, pos);
	}

	return result;
}

void fragment()
{
	if (v_crop > 1.0) discard;

	vec4 result = volumeTrace(
		normalize(v_camera_forward),
		UV, UV2.x, v_world_pos );

	ALBEDO = result.rgb;
	ALPHA = result.a * fade_overall;
}