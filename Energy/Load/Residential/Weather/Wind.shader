shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform float wave_amplitudeX : hint_range(0.0, 1.0) = 0.2;
uniform float wave_frequencyX : hint_range(0.1, 10.0) = 2.0;
uniform float wave_speedX : hint_range(0.0, 10.0) = 1.0;

uniform float wave_amplitudeZ : hint_range(0.0, 1.0) = 0.2;
uniform float wave_frequencyZ : hint_range(0.1, 10.0) = 2.0;
uniform float wave_speedZ : hint_range(0.0, 10.0) = 1.0;

const float TAU = 6.28318530718;
uniform float alpha_factor : hint_range(0.0, 1.0);

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	float waveX = sin(UV.x * wave_frequencyX * TAU + TIME * wave_speedX);
	float waveZ = sin(UV.x * wave_frequencyZ * TAU + TIME * wave_speedZ);
    VERTEX.y += waveX * wave_amplitudeX;
    VERTEX.z += waveZ * wave_amplitudeZ; // Adjust horizontal offset based on wave
}

void fragment() {
	vec2 base_uv = UV;
	vec2 center_point = (UV - vec2(0.25, 0.25)) * vec2(2.0, 2.0);
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA = albedo.a * albedo_tex.a * (0.6 - distance(UV, center_point)) * alpha_factor;
}