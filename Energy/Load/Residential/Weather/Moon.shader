shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform vec2 dark_circle_center;
uniform vec4 black : hint_color;
uniform float circle_radius_x = 0.53;
uniform float circle_radius_y = 0.53;
uniform float edge_softness = 0.1;
uniform float moon_radius = 0.4;
uniform float curve_vertical_scale = 0.3; // Controls vertical height of the crescent curve

uniform float phase : hint_range(0,1);
uniform bool is_crescent = true;
uniform float alpha: hint_range(0.0, 1.0) = 1.0;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	UV2=UV2*uv2_scale.xy+uv2_offset.xy;
}

float make_crescent(vec2 uv) {
	vec2 centered_uv = uv - vec2(0.5, 0.5);
	
	float dist_from_center = length(centered_uv);
	
	if (dist_from_center > moon_radius) {
		return 1.0;
	}
	float shadow_x = (phase - 0.5) * moon_radius * 1.0;
	
	// setting curve instensity to 0 at median point
	float curve_intensity = abs(phase - 0.5) * 2.0;
	
	float shadow_boundary;
	if (curve_intensity > 0.01) {
		float y_factor = centered_uv.y / (moon_radius * curve_vertical_scale);
		float curve_offset = (1.0 - y_factor * y_factor) * moon_radius * curve_intensity * 0.8;

		if (phase < 0.5) {
			// Waxing
			shadow_boundary = shadow_x - curve_offset;
		} else {
			// Waning 
			shadow_boundary = shadow_x + curve_offset;
		}
	} else {
		//straight
		shadow_boundary = shadow_x;
	}
	
	float calculated_edge_softness = edge_softness * (curve_intensity * 0.5) + 0.04;
	
	if (phase < 0.5) {
		// Waxing
		return 1.0 - smoothstep(shadow_boundary - calculated_edge_softness, shadow_boundary + calculated_edge_softness, centered_uv.x);
	} else {
		// Waning
		return smoothstep(shadow_boundary - calculated_edge_softness, shadow_boundary + calculated_edge_softness, centered_uv.x);
	}
}

float make_gibbous(vec2 uv) {
	vec2 centered_uv = uv - vec2(0.5, 0.5);
	
	float dist_from_center = length(centered_uv);
	
	if (dist_from_center > moon_radius) {
		return 1.0;
	}
	float shadow_x = (phase - 0.5) * moon_radius * 1.0;
	
	// setting curve intensity to 0 at median point
	float curve_intensity = abs(phase - 0.5) * 2.0;
	
	float shadow_boundary;
	if (curve_intensity > 0.01) {
		float y_factor = centered_uv.y / (moon_radius * curve_vertical_scale);
		float curve_offset = sqrt(1.0 - min(y_factor * y_factor, 1.0)) * moon_radius * curve_intensity * 0.6;

		if (phase > 0.5) {
			// Waning gibbous - shadow comes from right with concave curve
			shadow_boundary = shadow_x + curve_offset;
		} else {
			// Waxing gibbous - shadow comes from left with concave curve
			shadow_boundary = shadow_x - curve_offset;
		}
	} else {
		//straight
		shadow_boundary = shadow_x;
	}
	
	float calculated_edge_softness = edge_softness * (curve_intensity * 0.5) + 0.04;
	if (phase < 0.5) {
		// Waxing gibbous
		return smoothstep(shadow_boundary - calculated_edge_softness, shadow_boundary + calculated_edge_softness, centered_uv.x);
	} else {
		// Waning gibbous
		return 1.0 - smoothstep(shadow_boundary - calculated_edge_softness, shadow_boundary + calculated_edge_softness, centered_uv.x);
	}
}


void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	 if (is_crescent) {
		ALBEDO = mix((albedo.rgb * albedo_tex.rgb), (black.rgb * albedo_tex.rgb), 1.0 - make_crescent(UV));
	} else {
		ALBEDO = mix((albedo.rgb * albedo_tex.rgb), black.rgb, 1.0 - make_gibbous(UV));
	}
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	ALPHA = albedo.a * albedo_tex.a * alpha;
}
