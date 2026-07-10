shader_type spatial;
render_mode unshaded, skip_vertex_transform;
uniform lowp sampler2D texture0: hint_albedo;


uniform vec4 u_bgcolor : hint_color = vec4(0.0);
uniform vec3 u_highlight = vec3(1.0, 1.0, 1.0);
uniform vec3 u_highlight_mul = vec3(1.0, 1.0, 1.0);
uniform vec3 u_highlight_offset = vec3(0.0);
varying vec3 e;
varying vec3 n;
varying float v_fog;
void vertex()
{	
	v_fog = clamp((-WORLD_MATRIX[3][2] - 5.0) / 120.0, 0.0, 1.0);
    vec3 cam = vec3(CAMERA_MATRIX[3][0],CAMERA_MATRIX[3][1],CAMERA_MATRIX[3][2]);
    mat3 normal_matrix = mat3(transpose(inverse(WORLD_MATRIX)));
    n = normalize(normal_matrix * NORMAL);
    vec4 mp = WORLD_MATRIX * vec4(VERTEX, 1.0);
    e = normalize(mp.xyz - cam);
    n = mat3(INV_CAMERA_MATRIX) * n;
    e = mat3(INV_CAMERA_MATRIX) * e;
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
    vec3 base = texture(texture0, matcap(normalize(e), normalize(n))).rgb + u_highlight_offset;
    vec4 carColor = vec4(base * u_highlight * u_highlight_mul, 1.0);

    ALBEDO =  mix(carColor, u_bgcolor, v_fog).rgb;	

}