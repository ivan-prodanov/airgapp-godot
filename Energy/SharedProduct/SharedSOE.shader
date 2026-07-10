shader_type spatial;
render_mode cull_disabled, unshaded, depth_draw_always;

uniform sampler2D texture_mask : hint_white;

uniform vec4 base_color : hint_color;
uniform vec4 pulse_color : hint_color;

const float TAU = 6.28318530718;

// A magic number, in SOE scale, that specifies the gradient from off to on. Mitigates aliasing issues.
uniform float pixel_scale : hint_range(0, 0.1);

// State of energy, from 0..1
uniform float soe : hint_range(0, 1) = 0.5;

// Offsets the pulse so it can be synced with powerflow
uniform float pulse_phase: hint_range(0, 1) = 0.0;
uniform float pulse_frequency: hint_range(0, 10) = 2.0;

uniform float pulse_strength: hint_range(0, 1) = 1.0;

void fragment() {
	vec4 mask_tex = texture(texture_mask, UV);
	
	float brightness = smoothstep(soe+pixel_scale*0.5, soe-pixel_scale*0.5, 1.0-UV.y);
	float pulse = pow(sin((TIME / pulse_frequency + pulse_phase) * TAU) * 0.5 + 0.5, 1.5);
	
	pulse = mix(1.0, pulse, pulse_strength);
	
	ALBEDO = mix(base_color.rgb, pulse_color.rgb, pulse);
	ALPHA = mask_tex.r * brightness;
}
