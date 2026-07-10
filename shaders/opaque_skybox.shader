shader_type spatial;
render_mode skip_vertex_transform;

uniform float skybox_rot =  0.0;
uniform float metallic =  0.0;
uniform float roughness =  0.0;
uniform vec4 color : hint_color = vec4(1.0);
uniform float skybox_contrib : hint_range(0,1) = 1.0;
uniform float skybox_intensity : hint_range(0,10) = 1.0;
uniform samplerCube skybox ;
uniform float skybox_scroll = 0;
uniform sampler2D ao ;
uniform float ao_intensity = 1.0;
uniform sampler2D custom_albedo_texture;

varying float v_up;
varying vec3 v_view;
varying vec3 v_normal;
varying vec3 v_skyUv;

mat3 rotateX(float rad) {
    float c = cos(rad);
    float s = sin(rad);
    return mat3(
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, c, s),
        vec3(0.0, -s, c)
    );
}

void vertex()
{
    vec3 cam = vec3(CAMERA_MATRIX[3][0],CAMERA_MATRIX[3][1],CAMERA_MATRIX[3][2]);
    v_up = pow(max(0.0, dot(normalize(NORMAL), vec3(0,1,0))), 2.0) * skybox_contrib * skybox_intensity;	
    v_view = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz - cam;				
    v_normal =  (WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
}

void fragment()
{
    ROUGHNESS = roughness;
    METALLIC = metallic;

    AO = texture(ao, UV).b;
    AO_LIGHT_AFFECT = ao_intensity;


    vec3 skyUv = -normalize(reflect(normalize(v_view), normalize(v_normal)));
    mat3 skyboxTransform = rotateX(skybox_scroll);
    vec4 skytxt = texture(skybox, skyUv*skyboxTransform);
	
	vec4 custom_color = texture(custom_albedo_texture, UV2);
	vec3 final_color = mix(color.rgb, custom_color.rgb / 10.0, custom_color.a);

    ROUGHNESS = mix(ROUGHNESS, 0.9, custom_color.a);
	METALLIC = mix(METALLIC, 0.0, custom_color.a);
    ALBEDO = final_color;
	EMISSION += vec3(skytxt.r * skytxt.r * 1.0) * v_up;
}
