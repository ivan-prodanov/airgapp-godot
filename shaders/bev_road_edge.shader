shader_type spatial;

render_mode unshaded, blend_mix, skip_vertex_transform;

uniform vec4 background_color : hint_color = vec4(0.9,0.9,0.9,1.0);
uniform vec4 road_color : hint_color = vec4(0.8,0.8,0.8,1.0);
uniform vec4 curb_color : hint_color = vec4(0.5,0.5,0.5,1.0);
uniform vec4 curb_ao : hint_color = vec4(0.6,0.6,0.6,0.5);
uniform vec4 curb_side : hint_color = vec4(0.2,0.2,0.2,1.0);
uniform vec4 curb_outter : hint_color = vec4(0.91,0.91,0.91,1.0);

varying vec2 worldpos;

uniform sampler2D bev_layer : hint_white;
uniform sampler2D points_mask : hint_white;
uniform float top;
uniform float show = 1;

const float o = 0.35;

const float CURB_INNER = 0.35;
const float CURB_WIDTH = 0.13;
const float CURB_OUTER = CURB_INNER - CURB_WIDTH;
const float AO_SHADOW = CURB_INNER + 0.3;
const float FEATHER = 0.005;

void vertex()
{
	worldpos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xz;
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float blendEdge(vec2 uv, float p1, float p2)
{
	return smoothstep(p1, p2, uv.x) * smoothstep(1.0-p1, 1.0-p2, uv.x) * smoothstep(p1, p2, uv.y) * smoothstep(1.0-p1*0.1, 1.0-p2*0.1, uv.y);
}

vec4 topLayer(float x, float edge_mask, vec2 uv)
{	
	float curb_top = smoothstep(CURB_OUTER, CURB_OUTER - FEATHER,  x);
	float road_edge = smoothstep(CURB_INNER, CURB_INNER - FEATHER, x);
	float sidewalk = smoothstep(0.0, 0.2,  x)*(curb_top);

	vec4 ret;
	ret.rgb = mix(mix(mix(background_color.rgb,curb_color.rgb, edge_mask) , background_color.rgb, curb_top), mix(background_color.rgb, curb_outter.rgb, edge_mask), sidewalk);
	ret.a = blendEdge(uv, 0.0, 0.05) * road_edge;
	return ret;
}

vec4 bottomLayer(float x, float edge_mask,  vec2 uv)
{	
	float x2 = smoothstep(AO_SHADOW, CURB_INNER, x) * step(CURB_INNER,x);
	x = smoothstep(CURB_INNER - FEATHER, CURB_INNER, x);
	vec4 ret;
	ret.rgb  = mix(mix(mix(background_color.rgb,curb_side.rgb, edge_mask) , road_color.rgb, x), curb_ao.rgb,  x2*curb_ao.a*edge_mask);
	ret.a = blendEdge(uv, 0.025, 0.4);
	return ret;
}

void fragment()
{
	float edge_mask = texture(points_mask, UV).r;
	float x = texture(bev_layer, UV).r;
	float x2 = texture(bev_layer, UV+vec2(0.0, 0.025)).r;
	float x3 = texture(bev_layer, UV-vec2(0.0, 0.025)).r;
	x = x*0.666 + x2*0.167 + x3*0.167 - o;
	
	vec2 worlduv = worldpos/75.0 + vec2(0.5) + vec2(0.0, 0.368);
	//worlduv = UV;
	vec4 frag = mix(bottomLayer(x, edge_mask, worlduv), topLayer(x, edge_mask, worlduv), top);

	ALBEDO = mix(background_color.rgb, frag.rgb, show);
	//ALBEDO += vec3(edge_mask)*0.4; // debug
	
	ALPHA= frag.a;
//	ALBEDO = vec3(0.0);

}
