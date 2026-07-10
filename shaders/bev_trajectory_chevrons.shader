shader_type spatial;
render_mode cull_disabled, specular_disabled, unshaded, shadows_disabled, ambient_light_disabled;

uniform sampler2D chevron_texture : hint_white;
uniform vec4 chevron_color : hint_color;

varying float v_acceleration_feeling; //encoded from app to vertex shader as VERTEX.Y

void vertex() {
	v_acceleration_feeling = VERTEX.y;
	VERTEX.y = 0.0f;
}

void fragment() {

	vec4 chevron_tex = texture(chevron_texture, UV);
	float scaled_accel = v_acceleration_feeling * (1.0f - chevron_tex.r);
	vec3 final_color = mix(COLOR.rgb, chevron_color.rgb, scaled_accel);

	ALBEDO = final_color;

	float from_center_pct = abs(0.5f - UV.x) * 2.0;
	float side_fade = smoothstep(0.4, 0.45, (1.0f - from_center_pct));
	ALPHA = COLOR.a * side_fade;
}
