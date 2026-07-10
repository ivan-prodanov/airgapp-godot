shader_type spatial;
render_mode unshaded, skip_vertex_transform;

varying vec2 worldpos;

// streaming textures from autopilot
uniform sampler2D bev_lines : hint_black;
uniform sampler2D bev_edges : hint_black;
uniform sampler2D bev_crosswalk : hint_black;

uniform vec4 background_color : hint_color = vec4(0.9,0.0,0.9,1.0);
uniform vec4 edge_color : hint_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 cloud_color : hint_color = vec4(.5, .5, .5, 1.0);
uniform vec2 bev_size = vec2(75.);
uniform vec2 ego_pos = vec2(0.5, 0.868);
uniform float show = 1;
uniform sampler2D bev_driveable : hint_white;
uniform sampler2D bev_3d : hint_white;
uniform vec4 road_color : hint_color = vec4(0.8,0.8,0.8,1.0);

void vertex()
{
	worldpos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xz;
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float blendEdge(vec2 uv, float p1, float p2)
{
	return smoothstep(p1, p2, uv.x) * smoothstep(1.0-p1, 1.0-p2, uv.x) * smoothstep(p1, p2, uv.y) * smoothstep(1.0-p1*0.1, 1.0-p2*0.1, uv.y);
}

vec4 sample(sampler2D image, vec2 uv) 
{
	vec4 c = texture(image, uv);
	float a = smoothstep(0.0, .7, smoothstep(0.2, 1.0, c.a));
	return vec4(c.rgb, a);
}

float linearstep(float begin, float end, float t) {
    return clamp((t - begin) / (end - begin), 0.0, 1.0);
}

vec4 blendOver(vec4 below, vec4 above)
{
	return vec4(
		mix(below.rgb, above.rgb, above.a),
		mix(below.a, 1.0, above.a) );
}

float crosswalkEdgeHighlight(float crosswalk_pct)
{
	const float peak_pct = 0.5;
	float pct = 1.0 - (abs(peak_pct - crosswalk_pct) / peak_pct);
	pct = pct * pct; // sharper crosswalk
	return pct;
}

void fragment()
{
	// common:
	float dayMode = step(0.5, background_color.g);

	// Edge fade
	vec2 worlduv = worldpos/bev_size +  ego_pos;
	float edgeFade = blendEdge(worlduv, 0.00, 0.2) * show;
	float fadeIn = clamp( edgeFade, 0.0, 1.0 );

	// Drivable space:
	float non_drivable_pct = texture(bev_driveable, UV).r;
	float ds = linearstep(0.16,0.8,non_drivable_pct);
	vec4 non_drivable_layer = vec4( road_color.rgb, ds);
	float non_drivable_any = smoothstep( 0.0, 0.2, non_drivable_pct);

	// Drivable edge:
	float edges_alpha = 0.8;
	float edge_color_day = 0.7;
	float edge_color_night = 0.3;
	float edges_pct = sample(bev_edges, UV).a;
	vec3 edges_color = vec3(1.0,1.0,1.0) * mix(edge_color_night, edge_color_day, dayMode);
	vec4 edges_layer = vec4( edges_color, edges_pct * edges_alpha );
	float edges_any = smoothstep( 0.0, 0.2, edges_pct);

	// Crosswalk
	float crosswalk_pct = texture(bev_crosswalk, UV).r;
	crosswalk_pct = crosswalkEdgeHighlight(crosswalk_pct);
	crosswalk_pct = mix( crosswalk_pct, 0.0, max( edges_any, non_drivable_any));
	float crosswalk_alpha = 0.25;
	vec4 crosswalk_layer = vec4(0.5, 0.5, 0.5, crosswalk_pct * crosswalk_alpha);

	// Final blending order:
	vec4 bg = vec4( background_color.rgb, 1.0);
	bg = blendOver(bg, crosswalk_layer);
	bg = blendOver(bg, non_drivable_layer);
	bg = blendOver(bg, edges_layer);
	bg = mix(background_color, bg, fadeIn );
	ALBEDO = bg.rgb;
}