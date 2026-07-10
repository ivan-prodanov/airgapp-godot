shader_type spatial;
render_mode unshaded,skip_vertex_transform,cull_disabled,depth_draw_never;

uniform mediump vec3 c1  = vec3(-20,0,0);
uniform mediump vec3 c1d = vec3(0,-50,0);
uniform mediump vec3 c2 =  vec3(100,0,0);
uniform mediump vec3 c2d  =  vec3(80,-40,0);
uniform lowp float u_weight = 2.5;

uniform vec2 u_span = vec2(-10, 100);
uniform float u_distance = 0;
uniform float u_opacity = 0.5;
uniform vec4 u_color = vec4(0.5);

uniform lowp sampler2D texture;

varying vec2 v_uv;
varying vec4 v_pos;

vec3 point(float t) {
    float t2 = t * t;
    float t3 = t * t * t;
    float a  = 2.0 * t3 - 3.0 * t2 + 1.0;
    float b  = t3 - 2.0 * t2 + t;

    float c  = -2.0 * t3 + 3.0 * t2;
    float d  = t3 - t2;
    return (a * c1) + (b * c1d) + (c * c2) + (d * c2d);
}

vec3 derivative(float t) {
    float tt = t * t;
    float a = 6.0 * tt - 6.0 * t;
    float b = 3.0 * tt - 4.0 * t + 1.0;
    float c = - 6.0 * tt + 6.0 * t;
    float d = 3.0 * tt - 2.0 * t;
    return (a * c1) + (b * c1d) + (c * c2) + (d * c2d);
}

vec2 rotate(vec2 v, float a) {
    float s = sin(a);
    float c = cos(a);
    mat2 m = mat2(vec2(c, -s), vec2(s, c));
    return m * v;
}

vec3 billboard(vec3 cam, vec3 spline,vec3 local)
{
    vec3 upVector = normalize(vec3(cam.z, cam.x, cam.x)); // impacts y/lat
    vec3 rightVector = normalize(vec3(1.0-cam.y, 0.0, cam.y)); // impact x/long;
    vec3 position = vec3(0.0);
    position += local.x * rightVector;
    position += local.y * upVector;
    return local;
}

void vertex() {
    vec3 cam = vec3(CAMERA_MATRIX[3][0],CAMERA_MATRIX[3][1],CAMERA_MATRIX[3][2]);
    vec4 apos = vec4(VERTEX, 1.0);

	float lat = apos.x;
	float lon = apos.z + 0.5;
	v_uv = vec2(lat, lon);

    vec3 spline = point(lon);
    vec3 dir = derivative(lon) ;
    vec2 pos = rotate(vec2(lat * u_weight, 0.0), -atan(dir.y, dir.x));
    vec3 pos2  =billboard (cam, spline, vec3(pos, 0.0));
    v_pos = vec4(spline.x + pos2.y, -spline.y+pos2.x,  -spline.z+pos2.z, 1.0);
	v_pos = vec4(v_pos.y, v_pos.z, -v_pos.x, 1.0);
	v_pos.y = 0.0;
    VERTEX = (MODELVIEW_MATRIX * v_pos).xyz;
	
}

float sawtooth(float x, float period)
{
  return abs(2.0*(x/period - floor(x/period + 0.5)));
}

void fragment()
{
	ALBEDO = texture(texture, mod(v_pos.zx*0.17 + vec2(u_distance*-0.2, 0.0), vec2(1.0))).rgb;
    ALPHA =  clamp(0.0, smoothstep(1.0, 0.1, abs(v_uv.x)) * u_opacity * smoothstep(u_span.x, -2.0, -v_pos.z) * (1.0-(-v_pos.z/u_span.y)), 1.0) *0.85;
}