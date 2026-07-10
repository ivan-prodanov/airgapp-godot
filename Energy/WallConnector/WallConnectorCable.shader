shader_type spatial;
render_mode unshaded, cull_back, skip_vertex_transform;

uniform float pulse_length: hint_range(1.0, 100.0);
uniform float pulse_frequency: hint_range(0.05, 10.0);

uniform float snake_fraction: hint_range(0.0, 1.0);
uniform float snake_exponent: hint_range(0.1, 10.0) = 2.0;

uniform float state = 0.0;

uniform vec4 base_color: hint_color;
uniform vec4 flow_color: hint_color;

uniform float current_time = 0.0;

void vertex() {
	float z_depth_offset_factor = 0.2;
	POSITION = (PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0)) - vec4(0.0, 0.0, z_depth_offset_factor * COLOR.g, 0.0);
}

void fragment() {
	if(state > 1.5) {
		discard;
	}
	
	float pulse_exponent = 1.0;
	
	float pulse_exponent_computed = pulse_exponent;
	
	if(state > 0.0) {
		pulse_exponent_computed = 1.0 / pulse_exponent;
	}
	
	float offset = 0.0;
	
	float time_offset = TIME / pulse_frequency;
	
	// 0..1
	float amount = pow(max(1.0 - fract(time_offset + state * (pow((UV.x) / pulse_length, pulse_exponent_computed) + (offset / pulse_length))) / snake_fraction, 0.0), snake_exponent);
	
	amount *= abs(state);

	vec4 color = mix(base_color, flow_color, smoothstep(0.0, 1.0, amount));
  
	ALPHA = color.a;
	ALBEDO = (color.rgb * 1.0);
	
	//ALBEDO = vec3(1.0) * UV.x;
}
