shader_type spatial;
render_mode cull_back;


uniform float pulse_length: hint_range(1.0, 100.0);
uniform float pulse_frequency: hint_range(0.05, 10.0);

uniform float snake_fraction: hint_range(0.0, 1.0);
uniform float snake_exponent: hint_range(0.1, 10.0) = 2.0;

// 0: disabled, 1: flowing, 2: pulse, 3: solid
uniform int flow_state = 0;
uniform vec4 flow_color: hint_color;

uniform float current_time = 0.0;

uniform sampler2D texture_bc: hint_white;
uniform sampler2D texture_mra: hint_white;

uniform float alpha_decrease_offset_begin = 1.0;
uniform float alpha_decrease_offset_end = 1.0;

void fragment() {
	float pulse_exponent = 1.0;
	float time_offset = current_time / pulse_frequency;
	
	vec4 bc_value = texture(texture_bc, UV); // BC, used for AO and alpha
	ROUGHNESS = texture(texture_mra, UV).g; // Get the green channel (roughness) only
	if (flow_state == 0) {
		ALBEDO = bc_value.rgb * 0.2;
		EMISSION = flow_color.rgb * 0.0;
	} else if (flow_state == 1) {
		float flow_amount = pow(max(1.0 - fract(time_offset - 1.0 * (pow((UV.x) / pulse_length, pulse_exponent))) / snake_fraction, 0.0), snake_exponent);
		ALBEDO = bc_value.rgb * (1.0 - flow_amount) * 0.2;
		EMISSION = (flow_color.rgb * flow_amount);
	} else if (flow_state == 2) {
		ALBEDO = bc_value.rgb * 0.2;
		EMISSION = flow_color.rgb * sin(radians(180.0*time_offset)) * 0.7;
	} else if (flow_state == 3) {
		ALBEDO = bc_value.rgb * 0.2;
		EMISSION = flow_color.rgb * 0.5;
	} else if (flow_state == 5) {
		float flow_amount = pow(max(1.0 - fract(time_offset + 1.0 * (pow((UV.x) / pulse_length, pulse_exponent))) / snake_fraction, 0.0), snake_exponent);
		ALBEDO = bc_value.rgb * (1.0 - flow_amount) * 0.2;
		EMISSION = (flow_color.rgb * flow_amount);
	}
	
	ALPHA = bc_value.a - smoothstep(alpha_decrease_offset_begin, alpha_decrease_offset_end, (1.0 - UV.x));
}
