shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform float value;
uniform bool is_stormy = false;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	if (is_stormy){
		ALPHA = albedo.a * albedo_tex.a * ((1.0-UV.y) + 0.5);
		ALBEDO = albedo.rgb * albedo_tex.rgb * ((1.0-UV.y) * value);
	} else {
		ALPHA = albedo.a * albedo_tex.a;
		ALBEDO = albedo.rgb * albedo_tex.rgb * value;
	}
		
}
