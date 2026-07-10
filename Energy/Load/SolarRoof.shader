shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, unshaded, skip_vertex_transform;

uniform sampler2D texture_albedo: hint_albedo;
uniform sampler2D texture_mra: hint_black;

uniform float shine_angle: hint_range(-180, 180);
uniform float shine_sharpness = 0.05;
uniform vec4 shine_color: hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float shine_offset: hint_range(-10, 10) = 0.0;

const vec3 LIGHT_DIRECTION = vec3(20.0, 3.0, 0.0);

uniform float alpha: hint_range(0, 1) = 1.0;

float lightStrength(vec3 normal_world) {
	return pow(dot(normalize(LIGHT_DIRECTION), normal_world) * 0.5 + 0.5, 1.0);
}

// Rotates `uv` around the origin by `angle` radians.
vec2 rotate(vec2 uv, float angle) {
  float s = sin(angle);
  float c = cos(angle);
  uv.x = uv.x * c - uv.y * s;
  uv.y = uv.x * s + uv.y * c;
  return uv;
}

varying vec2 v_ShineUV;

void vertex() {
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = (WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
	// Not physically accurate.
	vec3 norm = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	v_ShineUV = rotate(UV2, shine_angle * 0.0174533);
}

// Returns the amount of shine for this pixel.
// n_v is the dot product of normal and view, used to fade out shine as the angle gets flat.
float shine_amount(float shine_multiplier) {
	float sharpness = 1.0 / shine_sharpness;
	float shine_coord = v_ShineUV.x - shine_offset * 0.1;
	float shine = smoothstep(-sharpness, sharpness, shine_coord);
	
	return shine * shine_multiplier;
}

// Mixes albedo and shine.
vec3 shine_albedo(vec3 albedo, float shine) {
	vec3 shine_final_color = shine_color.rgb;
	return albedo + (shine_color.rgb * shine);
}

void fragment() {
	vec3 albedo = texture(texture_albedo, UV).rgb;

	// Technically metalness-roughness-'shininess'.
	vec3 mra = texture(texture_mra, UV).rgb;
	
	float shine = shine_amount(0.5 * mra.b);
	ALBEDO = shine_albedo(albedo, shine) * mra.b * lightStrength(NORMAL) * 0.5;
	ALPHA = alpha;
}
