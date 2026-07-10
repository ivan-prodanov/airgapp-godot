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
uniform sampler2D transition_albedo_texture;
uniform float transition_z_pos = 100.0;

const float fractal_scale = 6.0;
const float fractal_octaves = 3.0;
const float lightning_glow_width = 0.1;
const float lightning_brightness = 0.15;
const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);

varying float v_up;
varying vec3 v_view;
varying vec3 v_normal;
varying vec3 v_skyUv;
varying vec3 v_vertex_pos;

mat3 rotateX(float rad) {
    float c = cos(rad);
    float s = sin(rad);
    return mat3(
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, c, s),
        vec3(0.0, -s, c)
    );
} 

float fractal_noise(vec2 p, float time) {
    float value = 0.0;
    float amplitude = 1.0;
    for(int i = 0; i < int(fractal_octaves); i++) {
        value += sin(p.x * amplitude + time) * cos(p.y * amplitude - time * 0.5) / amplitude;
        amplitude *= 2.0;
        p *= 2.0;
    }
    return value;
}

void vertex()
{
    vec3 cam = vec3(CAMERA_MATRIX[3][0],CAMERA_MATRIX[3][1],CAMERA_MATRIX[3][2]);
    v_up = pow(max(0.0, dot(normalize(NORMAL), vec3(0,1,0))), 2.0) * skybox_contrib * skybox_intensity;	
    v_view = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz - cam;				
    v_normal =  (WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
	v_vertex_pos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
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
	
	vec2 fractal_uv = UV2 * fractal_scale;
	float base_distance = transition_z_pos - v_vertex_pos.z;
	float fractal = fractal_noise(fractal_uv, base_distance);
	
	float lightning_edge = fractal + base_distance * 3.0;
	float transition_pct = smoothstep(-0.3, 0.3, lightning_edge);
	
	float lightning_distance = abs(lightning_edge);
	float lightning_mask = 1.0 - smoothstep(0.0, lightning_glow_width, lightning_distance);
	
	float flicker = sin(base_distance + fractal * 10.0) * 0.5 + 0.5;
	float lightning_intensity = lightning_mask * flicker * lightning_brightness;
	
	float lightning_emission = lightning_intensity * lightning_mask;
	vec4 custom_color = vec4(0.0);
	vec3 final_color;
	float alpha; 
	if (transition_pct > 0.5)
	{
		custom_color = texture(transition_albedo_texture, UV2);
		final_color = mix(color.rgb, custom_color.rgb / 10.0, custom_color.a);
		final_color -= lightning_emission;
		alpha = 1.0;
	}
	else
	{
		final_color = vec3(0.0);
		alpha = lightning_emission;
	}

    ROUGHNESS = mix(ROUGHNESS, 0.9, custom_color.a);
	METALLIC = mix(METALLIC, 0.0, custom_color.a);
    ALBEDO = final_color;
	ALPHA = alpha;
	EMISSION += vec3(skytxt.r * skytxt.r * 1.0) * v_up;
	
    float dither_threshold = fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy))) * 0.1;
	ALPHA_SCISSOR = dither_threshold;
}
