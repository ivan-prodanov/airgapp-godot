shader_type spatial;
render_mode unshaded, cull_back, skip_vertex_transform;

uniform float pulse_length: hint_range(1.0, 100.0);
uniform float pulse_frequency: hint_range(0.05, 10.0);
//uniform float pulse_power: hint_range(0.1, 10.0);
//uniform float pulse_offset: hint_range(-0.5, 0.5);

uniform float spw_solar_offset: hint_range(-100.0, 100.0);

uniform float snake_fraction: hint_range(0.0, 1.0);
uniform float snake_exponent: hint_range(0.1, 10.0) = 2.0;

uniform vec2 powerflow_state_0 = vec2(-1.0);
uniform vec2 powerflow_state_1 = vec2(1.0, 2.0);
uniform vec2 powerflow_state_2 = vec2(1.0);
uniform vec2 powerflow_state_3 = vec2(1.0);
uniform vec2 powerflow_state_4 = vec2(1.0);
uniform vec2 powerflow_state_5 = vec2(1.0);
uniform vec2 powerflow_state_6 = vec2(1.0);
uniform vec2 powerflow_state_7 = vec2(2.0);

uniform vec4 base_color: hint_color;
uniform vec4 flow_color: hint_color;

uniform float current_time = 0.0;

uniform float path_fade: hint_range(0.0, 1.0) = 0.0;
uniform float path_fade_length = 4.0;

const float path_fade_transition_length = 0.2;

void vertex() {
	float z_depth_offset_factor = 0.2;
	POSITION = (PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0)) - vec4(0.0, 0.0, z_depth_offset_factor * COLOR.g, 0.0);
}

void fragment() {
	int path_index = int(floor(UV.y * 16.0));
	
	float state = 0.0;
	
	if(path_index == 0)       state = powerflow_state_0.x;
	else if(path_index == 1)  state = powerflow_state_0.y;
	else if(path_index == 2)  state = powerflow_state_1.x;
	else if(path_index == 3)  state = powerflow_state_1.y;
	else if(path_index == 4)  state = powerflow_state_2.x;
	else if(path_index == 5)  state = powerflow_state_2.y;
	else if(path_index == 6)  state = powerflow_state_3.x;
	else if(path_index == 7)  state = powerflow_state_3.y;
	else if(path_index == 8)  state = powerflow_state_4.x;
	else if(path_index == 9)  state = powerflow_state_4.y;
	else if(path_index == 10) state = powerflow_state_5.x;
	else if(path_index == 11) state = powerflow_state_5.y;
	else if(path_index == 12) state = powerflow_state_6.x;
	else if(path_index == 13) state = powerflow_state_6.y;
	else if(path_index == 14) state = powerflow_state_7.x;
	else if(path_index == 15) state = powerflow_state_7.y;

	if(state > 1.5) {
		discard;
	}
	
	float pulse_exponent = 1.0;
	
	float pulse_exponent_computed = pulse_exponent;
	if(state > 0.0) {
		pulse_exponent_computed = 1.0 / pulse_exponent;
	}
	
	float offset = 0.0;
	
	if(path_index >= 10 && path_index <= 11) {
		offset = spw_solar_offset;
		
		// Handle solar powerwall flow inverse.
		if(powerflow_state_0.y > 0.0) {
			offset = -offset;
		}
	}
	
	float time_offset = current_time / pulse_frequency;
	
	// 0..1
	float amount = pow(max(1.0 - fract(time_offset + state * (pow((UV.x) / pulse_length, pulse_exponent_computed) + (offset / pulse_length))) / snake_fraction, 0.0), snake_exponent);
	
	amount *= abs(state);

	vec4 color = mix(base_color, flow_color, smoothstep(0.0, 1.0, amount));
	ALPHA = color.a * (1.0 - COLOR.r);
	ALBEDO = (color.rgb * 1.0);

	// For vehicle paths, we have the ability to use `path_fade` to fade them out from the end, to transition from stowed to plugged-in.
	if (path_index >= 14) {
		float path_fade_fraction = smoothstep(-path_fade_transition_length, 0.0, 1.0 - ((UV.x / path_fade_length) + (smoothstep(0.0, 1.0, path_fade) * (1.0 + path_fade_transition_length))));
		
		ALPHA *= path_fade_fraction;
	}
  
	if (path_index == 3) {
		ALBEDO /= ALPHA;
	}
}
