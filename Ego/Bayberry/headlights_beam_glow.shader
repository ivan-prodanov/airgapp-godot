shader_type spatial;
render_mode blend_add,depth_draw_never,unshaded;

uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;

uniform float close_blend_start = 0.0;
uniform float close_blend_end = 0.0;
uniform float far_blend_start = 0.0;
uniform float far_blend_end = 0.0;
uniform float view_dot_normal_blend_start = 0.0;
uniform float view_dot_normal_blend_end = 0.0;
uniform float view_fwd_dot_normal_blend_start = 0.0;
uniform float view_fwd_dot_normal_blend_end = 0.0;

void fragment() {
	vec4 albedo_tex = texture(texture_albedo,UV);
	albedo_tex.rgb = mix(pow((albedo_tex.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex.rgb.rgb * (1.0 / 12.92),lessThan(albedo_tex.rgb,vec3(0.04045)));
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	
	float dist_to_vert = length(VERTEX);
	float close_fade = smoothstep(close_blend_start, close_blend_end, dist_to_vert);
	
	float far_fade = 1.0f - smoothstep(far_blend_start, far_blend_end, dist_to_vert);
	
	float view_dot_normal = dot(NORMAL, normalize(VERTEX));
	float parallel_view_fade = smoothstep(view_dot_normal_blend_start, view_dot_normal_blend_end, abs(view_dot_normal));
	
	float view_fwd_dot_normal = -NORMAL.z; //equal to dot(NORMAL, vec3(0.0, 0.0, -1.0));
	float parallel_fwd_view_fade = smoothstep(view_fwd_dot_normal_blend_start, view_fwd_dot_normal_blend_end, abs(view_fwd_dot_normal));
	
	ALPHA = albedo.a * albedo_tex.a * close_fade * far_fade * parallel_view_fade * parallel_fwd_view_fade;
}
