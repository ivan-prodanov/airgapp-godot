shader_type spatial;
render_mode unshaded,skip_vertex_transform,cull_disabled, depth_draw_never;

uniform mediump vec3 c1_center  = vec3(-15,0,0);
uniform mediump vec3 c1d_center = vec3(50,-50,0);
uniform mediump vec3 c2_center =  vec3(100,0,0);
uniform mediump vec3 c2d_center  =  vec3(80,-40,0);

uniform mediump vec3 c1_left  = vec3(-15,3,0);
uniform mediump vec3 c1d_left = vec3(50,-50,0);
uniform mediump vec3 c2_left =  vec3(100,3,0);
uniform mediump vec3 c2d_left  =  vec3(80,-40,0);

uniform mediump vec3 c1_right  = vec3(-15,-3,0);
uniform mediump vec3 c1d_right = vec3(50,-50,0);
uniform mediump vec3 c2_right =  vec3(100,-3,0);
uniform mediump vec3 c2d_right  =  vec3(80,-40,0);

uniform float u_transition = 1;
uniform float u_lat_dist_from_ego = 3;
uniform float u_wipe = 0.0;
uniform float u_alpha = 1.0;
uniform vec4 color : hint_color = vec4(0, 0.42, 1, 1);

uniform vec2 u_span = vec2(-20, 100);

varying vec2 v_uv;
varying vec4 v_pos;
varying float v_blend;

vec3 point(float posx, float t)
{
    float t2 = t * t;
    float t3 = t * t * t;
    float a  = 2.0 * t3 - 3.0 * t2 + 1.0;
    float b  = t3 - 2.0 * t2 + t;
    float c  = -2.0 * t3 + 3.0 * t2;
    float d  = t3 - t2;

    vec3 center = (a * c1_center) + (b * c1d_center) + (c * c2_center) + (d * c2d_center);
    vec3 left = (a * c1_left) + (b * c1d_left) + (c * c2_left) + (d * c2d_left);
    vec3 right = (a * c1_right) + (b * c1d_right) + (c * c2_right) + (d * c2d_right);

    vec3 edge = (step(posx, -0.5) * left) + (step(0.5, posx) * right);

    return mix(center, edge, abs(posx)*u_transition) + vec3(0.0, posx *(1.- u_transition) * -0.35, 0.0);
}

void vertex() {
    vec4 apos = vec4(VERTEX, 1.0);
	float lat = apos.x;
	float lon = apos.z + 0.5;
	v_uv = vec2(lat, lon);
    vec3 spline = point(lat, lon);
    spline.y -= u_lat_dist_from_ego*(1.-u_transition);
    v_pos = vec4(spline.x, -spline.y,  -spline.z, 1.0);
	v_pos = vec4(v_pos.y, v_pos.z, -v_pos.x, 1.0);
    VERTEX = (MODELVIEW_MATRIX * v_pos).xyz;
}

void fragment()
{
    float itran = 1. - u_transition;
    ALBEDO = color.rgb;
    ALPHA =   smoothstep(0.99, 0.95, abs(v_uv.x + u_wipe*2.))
            * smoothstep(u_span.x * u_transition, (-2.0 * u_transition) + 0.01, -v_pos.z - (1.0 - u_transition) * 3.0)
            * clamp(0.0, (1.0 - (-v_pos.z / u_span.y)), 1.0)
            * smoothstep(50. + itran*100., 10., -v_pos.z)
            * smoothstep(-10. - itran*100., -2., -v_pos.z)
            * (0.2+itran*0.8) * color.a * u_alpha;

}
