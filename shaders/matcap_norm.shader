shader_type spatial;
render_mode unshaded, skip_vertex_transform;
uniform lowp sampler2D texture0: hint_albedo;
uniform lowp sampler2D normal_map : hint_normal;
uniform float u_distance = 0.;
uniform vec4 u_bgcolor :hint_color= vec4(0.0);
uniform vec3 u_highlight = vec3(1.0);
uniform vec3 u_highlight_mul = vec3(1.0);
uniform vec3 u_highlight_offset = vec3(0.0);
varying vec3 e;
//varying vec3 n;

// note: Tegra fails on "varying mat3"
varying vec3 v_TBN0;
varying vec3 v_TBN1;
varying vec3 v_TBN2;

void vertex()
{	
    vec3 cam = vec3(CAMERA_MATRIX[3][0],CAMERA_MATRIX[3][1],CAMERA_MATRIX[3][2]);
    mat3 normal_matrix = mat3(transpose(inverse(WORLD_MATRIX)));

    vec4 mp = WORLD_MATRIX * vec4(VERTEX, 1.0);
    e = normalize(mp.xyz - cam);
    e = mat3(INV_CAMERA_MATRIX) * e;

	mat3 TBN =  mat3(INV_CAMERA_MATRIX) * mat3(normalize((WORLD_MATRIX * vec4(TANGENT, 0)).xyz),
                                          normalize((WORLD_MATRIX * vec4(BINORMAL, 01)).xyz),
                                          normalize(normal_matrix * NORMAL));
    v_TBN0 = TBN[0];
    v_TBN1 = TBN[1];
    v_TBN2 = TBN[2];
	
    VERTEX = (INV_CAMERA_MATRIX * mp).xyz;
}

vec2 matcap(vec3 eye, vec3 norm)
{
    vec3 r = reflect(eye, norm);
    float m = 2.8284271247461903 * sqrt(r.z + 1.0);
    vec2 coord = r.xy / m + 0.5;
	return vec2(coord.x , 1.0-coord.y);
}

void fragment()
{
	vec3 norm_map = texture(normal_map, UV).xyz * 2.0 -1.0;
    vec3 n = normalize(mat3(v_TBN0,v_TBN1,v_TBN2) * norm_map);
	
    vec3 base = texture(texture0, matcap(normalize(e), normalize(n))).rgb + u_highlight_offset;
    float fadeOut = clamp((u_distance - 5.0) / 120.0, 0.0, 1.0);
    vec4 carColor = vec4(base * u_highlight * u_highlight_mul, 1.0);

    ALBEDO =  mix(carColor, u_bgcolor, fadeOut).rgb;



}