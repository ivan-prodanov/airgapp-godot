shader_type spatial;

uniform float metallic_bright =  0.0;
uniform float metallic_dark =  0.0;
uniform float metallic_away_and_up =  0.0;
uniform float roughness_bright =  0.0;
uniform float roughness_dark =  0.0;
uniform float roughness_away_and_up =  0.0;
uniform vec4 color_bright : hint_color = vec4(1.0);
uniform vec4 color_dark : hint_color = vec4(0.0);
uniform vec4 color_away_and_up : hint_color = vec4(0.0);
uniform float blend_start = 0.0;
uniform float blend_end = 1.0;
uniform sampler2D ao;
uniform sampler2D custom_albedo_texture;

varying vec3 v_color;
varying float v_roughness;
varying float v_metallic;

void vertex()
{
    vec3 cam_world = vec3(CAMERA_MATRIX[3][0],CAMERA_MATRIX[3][1],CAMERA_MATRIX[3][2]);
	vec3 view_world = normalize((WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz - cam_world);
	vec3 normal_world = normalize(WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vec3 reflect_view_world = normalize(reflect(view_world, normal_world));
	float view_dot_reflect = dot(reflect_view_world, view_world);
	float coef_away = smoothstep(blend_start, blend_end, abs(view_dot_reflect));
	float coef_away_and_up = clamp(max(0.0, view_dot_reflect) * dot(reflect_view_world, vec3(0.0, 1.0, 0.0)), 0.0, 1.0);
	
	v_color = mix(color_dark.rgb, color_bright.rgb, coef_away);
	v_color = mix(v_color, color_away_and_up.rgb, coef_away_and_up);
	
	v_roughness = mix(roughness_dark, roughness_bright, coef_away);
	v_roughness = mix(v_roughness, roughness_away_and_up, coef_away_and_up);
	
	v_metallic = mix(metallic_dark, metallic_bright, coef_away);
	v_metallic = mix(v_metallic, metallic_away_and_up, coef_away_and_up);
}

void fragment()
{    
	AO = texture(ao, UV).b;
	AO_LIGHT_AFFECT = 1.0;
	
	vec4 custom_color = texture(custom_albedo_texture, UV2);
	vec3 final_color = mix(v_color, custom_color.rgb / 7.0, custom_color.a);
	
	ALBEDO = final_color;
	ROUGHNESS = mix(v_roughness, 0.9, custom_color.a);
	METALLIC = mix(v_metallic, 0.0, custom_color.a);
}
