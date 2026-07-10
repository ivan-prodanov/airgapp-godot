shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color = vec4(0.14902, 0.14902, 0.14902, 1.0);
uniform float specular : hint_range(0,1) = 0.5;
uniform float metallic : hint_range(0,1) = 1.0;
uniform float roughness : hint_range(0,1) = 1.0;
uniform float ao_light_affect : hint_range(0,1) = 1.0;
uniform sampler2D texture_ambient_occlusion;

void fragment() {
	vec2 base_uv = UV;
	ALBEDO = albedo.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	AO = texture(texture_ambient_occlusion,base_uv).b;
	AO_LIGHT_AFFECT = ao_light_affect;
}
