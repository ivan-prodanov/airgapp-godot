shader_type spatial;
render_mode skip_vertex_transform;

uniform float skybox_rot =  0.0;
uniform float metalic =  0.0;
uniform float roughness =  0.0;
uniform float specular = 0.0;
uniform vec4 color : hint_color = vec4(1.0);
uniform float skybox_contrib : hint_range(0,1) = 1.0;
uniform float skybox_intensity : hint_range(0,10) = 1.0;
uniform samplerCube skybox ;
uniform float skybox_scroll = 0;
uniform float in_editor = 0;

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
    v_up = pow(max(0.0, dot(normalize(NORMAL), vec3(0,1,0))), 3.0) * skybox_contrib * skybox_intensity;	
    v_view = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz - cam;				
    v_normal =  (WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
}

void fragment()
{
    ROUGHNESS = roughness;
    METALLIC = metalic;
    ALBEDO = color.rgb;
    SPECULAR = specular;

    vec3 skyUv = -normalize(reflect(normalize(v_view), normalize(v_normal)));
    mat3 skyboxTransform = rotateX(skybox_scroll);
    vec4 skytxt = texture(skybox, skyUv*skyboxTransform);

    EMISSION += vec3(skytxt.r * skytxt.r * 1.0)*v_up;
    ALPHA = color.a;
}
