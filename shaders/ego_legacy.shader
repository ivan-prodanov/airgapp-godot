shader_type spatial;
render_mode skip_vertex_transform;

uniform sampler2D u_normalmap : hint_normal;
uniform sampler2D u_mra;
uniform sampler2D u_color : hint_albedo;

uniform float skybox_rot =  0.0;
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
    v_up = pow(max(0.0, dot(normalize(NORMAL), vec3(0,0,1))), 2.0) * skybox_contrib * skybox_intensity;	
    v_view = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz - cam;				
    v_normal =  (WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	BINORMAL = (MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz;
	TANGENT = (MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz;
}

void fragment()
{
	vec4 mra = texture(u_mra, UV);
	vec4 nmap =  texture(u_normalmap, UV);
	vec4 col =  texture(u_color, UV, -3.0);

	METALLIC = mra.x*mra.x*.6;
	ROUGHNESS = mra.y;
	
	AO = pow(mra.z, 1.0);
    AO_LIGHT_AFFECT = 1.2;
	
	NORMALMAP = vec3(nmap.r, 1.0-nmap.g, nmap.b);	
	ALBEDO = (pow(col.rgb, vec3(1.2))*1.1) - 0.04;
	vec3 skyUv = -normalize(reflect(normalize(v_view), normalize(v_normal)));
    mat3 skyboxTransform = rotateX(skybox_scroll);
    vec4 skytxt = texture(skybox, skyUv*skyboxTransform);

	ALBEDO = mix(ALBEDO, vec3(skytxt.r * skytxt.r * 1.0), v_up*skytxt.r);

}
