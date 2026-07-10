shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

varying vec3 world_position;
uniform float ground_fade_height = 1.1;
uniform float ground_fade_falloff = 1.0;
uniform float arc_radius = 0.35;          // Radius of the arc shape (0-1, smaller due to bigger plane)
uniform float arc_falloff = 2.0;         // Falloff power (lower = softer, 1.0 = linear, 2.0 = quadratic, 4.0 = sharp)
uniform float edge_fade_width = 0.08;    // Width of fade zone at plane edges
uniform float arc_center_y_offset = 0.0; // Y offset of arc center (positive = down)

uniform float center_position_x;
uniform float center_position_y;
uniform float sunset_factor : hint_range(-1,1);

uniform float radius_1;         // Radius for color_1 to color_2 transition
uniform float radius_2;         // Radius for color_2 to color_3 transition
uniform float radius_3;   
uniform vec4 color_1_sunset : hint_color;
uniform vec4 color_2_sunset : hint_color;
uniform vec4 color_3_sunset : hint_color;
uniform vec4 color_4_sunset : hint_color;

uniform vec4 color_1_sunrise : hint_color;
uniform vec4 color_2_sunrise : hint_color;
uniform vec4 color_3_sunrise : hint_color;
uniform vec4 color_4_sunrise : hint_color;

uniform vec4 color_override : hint_color;
uniform float color_override_factor : hint_range(0,1);

// Linear gradient control
uniform vec4 linear_color_top : hint_color;   // Color at the top of the linear gradient
uniform vec4 linear_color_bottom : hint_color; // Color at the bottom of the linear gradient
uniform float day_strength;    // Strength of the blending between radial and linear gradients

uniform float bloom_factor : hint_range(0,1.3);
uniform float alpha : hint_range(0,1.0);

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	world_position = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

vec3 radialGradient(vec2 uv) {
    // Calculate the distance from the center for the radial gradient
	vec2 center_position = vec2(center_position_x, -center_position_y);
    float dist = distance(uv, center_position);
    
	// Pre-calculate all color transitions to avoid redundant mix operations
	vec3 calculated_color_1 = mix(color_1_sunrise.xyz, color_1_sunset.xyz, sunset_factor);
	vec3 calculated_color_2 = mix(color_2_sunrise.xyz, color_2_sunset.xyz, sunset_factor);
	vec3 calculated_color_3 = mix(color_3_sunrise.xyz, color_3_sunset.xyz, sunset_factor);
	vec3 calculated_color_4 = mix(color_4_sunrise.xyz, color_4_sunset.xyz, sunset_factor);
	
    // Use step functions and mix to avoid conditional branching while maintaining exact logic
    float t1 = clamp(dist / radius_1, 0.0, 1.0);
    float t2 = clamp((dist - radius_1) / (radius_2 - radius_1), 0.0, 1.0);
    float t3 = clamp((dist - radius_2) / (radius_3 - radius_2), 0.0, 1.0);
    
    vec3 zone1_color = mix(calculated_color_1, calculated_color_2, t1);
    vec3 zone2_color = mix(calculated_color_2, calculated_color_3, t2);
    vec3 zone3_color = mix(calculated_color_3, calculated_color_4, t3);
    
    // Select the appropriate zone color based on distance
    vec3 radial_color = calculated_color_4; // Default for dist > radius_3
    radial_color = mix(zone3_color, radial_color, step(radius_3, dist));
    radial_color = mix(zone2_color, radial_color, step(radius_2, dist));
    radial_color = mix(zone1_color, radial_color, step(radius_1, dist));
    
    // Linear gradient: uv.y is assumed to be the vertical axis for the sky
    float adjusted_y = (1.0 - uv.y);
    vec3 linear_color = mix(linear_color_bottom.xyz, linear_color_top.xyz, adjusted_y);
    
    return mix(radial_color, linear_color, day_strength);
}

void fragment() {
	ALBEDO = mix(radialGradient(UV), color_override.xyz, color_override_factor);

	// 1. Arc shape from center (power-based radial fade for smooth gradient)
	vec2 arc_center = vec2(0.5, 0.5 + arc_center_y_offset);
	float dist_from_center = length(UV - arc_center);

	// Power-based falloff: maintains arc shape even with very soft gradients
	// Normalized distance: 0 at center, 1 at arc_radius, >1 beyond
	float normalized_dist = dist_from_center / arc_radius;
	// Apply power function and clamp to [0,1]
	float arc_fade = clamp(1.0 - pow(normalized_dist, arc_falloff), 0.0, 1.0);

	// 2. Ground fade (controls flat bottom placement)
	float distance_from_ground = max(0.0, 1.0 - (UV.y * ground_fade_height) * ground_fade_falloff);

	// 3. Edge fade (ensures no clipping at plane edges)
	// Fade based on distance to nearest edge
	vec2 edge_dist = min(UV, 1.0 - UV); // Distance to nearest edge in each axis
	float min_edge_dist = min(edge_dist.x, edge_dist.y); // Distance to closest edge
	float edge_fade = smoothstep(0.0, edge_fade_width, min_edge_dist);

	// Combine all fades
	ALPHA = arc_fade * distance_from_ground * edge_fade * alpha;
}
