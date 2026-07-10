shader_type spatial;
render_mode unshaded,skip_vertex_transform,cull_disabled, depth_draw_never;


uniform mediump vec3 c1  = vec3(0,0,0);
uniform mediump vec3 c1d = vec3(50,-50,0);
uniform mediump vec3 c2 =  vec3(100,0,0);
uniform mediump vec3 c2d  =  vec3(80,-40,0);

uniform mediump vec3 c1_edge= vec3(0,0,0);
uniform mediump vec3 c1d_edge= vec3(0,0,0);
uniform mediump vec3 c2_edge= vec3(0,0,0);
uniform mediump vec3 c2d_edge= vec3(0,0,0);

uniform mediump vec3 c1_adjacent= vec3(0,0,0);
uniform mediump vec3 c1d_adjacent= vec3(0,0,0);
uniform mediump vec3 c2_adjacent= vec3(0,0,0);
uniform mediump vec3 c2d_adjacent= vec3(0,0,0);

uniform lowp float u_weight = 0.25;


uniform vec4 color : hint_color= vec4(0.5, 0.5, 0.5, 1.0);
uniform vec4 u_color_inactive : hint_color= vec4(0.5, 0.5, 0.5, 1.0);
uniform float u_transition = 0;
uniform float u_side = 0;
uniform float u_adjacent_blend = 0;
uniform vec2 u_span = vec2(-5, 100);
uniform float u_dashed = -0.1;
uniform float u_distance = 0;
uniform highp vec3 u_bend;
uniform float u_stopline = 2000;


varying vec2 v_uv;
varying vec4 v_pos;
varying float v_blend;

vec3 pointold(float t) 
{
    float t2 = t * t;
    float t3 = t * t * t;
    float a  = 2.0 * t3 - 3.0 * t2 + 1.0;
    float b  = t3 - 2.0 * t2 + t;

    float c  = -2.0 * t3 + 3.0 * t2;
    float d  = t3 - t2;
    return (a * c1) + (b * c1d) + (c * c2) + (d * c2d);
}

vec4 point(float t) 
{
    float t2 = t * t;
    float t3 = t * t * t;
    float a  = 2.0 * t3 - 3.0 * t2 + 1.0;
    float b  = t3 - 2.0 * t2 + t;
    float c  = -2.0 * t3 + 3.0 * t2;
    float d  = t3 - t2;

    vec3 cen = (a * c1) + (b * c1d) + (c * c2) + (d * c2d);
    vec3 ee = (a * c1_edge) + (b * c1d_edge) + (c * c2_edge) + (d * c2d_edge);
    vec3 adj = (a * c1_adjacent) + (b * c1d_adjacent) + (c * c2_adjacent) + (d * c2d_adjacent);

    float trans_dist = (u_transition  * 350.0);
    float trans_window = 75.0;

    float inpoint = 100.0;
    float outpoint = 280.0;
    float blend = smoothstep(inpoint, inpoint+trans_window, cen.x + trans_dist) * smoothstep(outpoint+trans_window, outpoint, cen.x + trans_dist);
    vec3 blended_center_lane = mix(cen, adj, u_adjacent_blend);

    return vec4(mix(blended_center_lane, ee, blend), blend);
}

float smoothstepDir(float t) {
   float a = -2.0;
   float b = 3.0;
   return (3.0*a*t*t*t)+(2.0*b*t*t);
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

    vec4 splinePoints = point(lon);
    lat += u_side*0.47 * (1.0-splinePoints.w);
    v_blend = splinePoints.w;
    vec3 spline =splinePoints.xyz;
    float bend = smoothstep(u_bend.x, u_bend.y, spline.x + (splinePoints.w * 100.0));

    //spline.y *= bend * (1.0-splinePoints.w);
    spline.y += u_bend.z;

    spline.y *= bend;

    vec3 dir = derivative(lon) ;
    vec2 pos = rotate(vec2(lat*0.3 , 0.0), -atan(dir.y, dir.x) + smoothstepDir(bend)*0.14);
    vec3 pos2  =billboard (cam, spline, vec3(pos, 0.0));
    v_pos = vec4(spline.x + pos2.y, -spline.y+pos2.x,  -spline.z+pos2.z, 1.0);

	v_pos = vec4(v_pos.y, v_pos.z, -v_pos.x, 1.0);

    VERTEX = (MODELVIEW_MATRIX * v_pos).xyz;
}


void fragment()
{
	float lat = v_pos.y;
	float lon = -v_pos.z;
    float extraWeight = (1.0-v_blend) * 0.18;
    float suck = smoothstep(0.5, 1.0, v_blend);
    float stoplineFade = smoothstep(u_stopline+0.1, u_stopline-0.1, lon + abs(lat*0.5));

    vec4 c = mix(u_color_inactive, color, stoplineFade);
    float a = smoothstep(0.45+extraWeight, 0.2+extraWeight, abs(v_uv.x))
            * smoothstep(u_span.x*suck, (-2.0*suck) + 0.01, lon - (1.0-suck)*3.0)
            * (1.0-(lon/u_span.y));
	ALBEDO = c.rgb;
	ALPHA =  clamp(a, 0.0, 1.0) * c.a;

}