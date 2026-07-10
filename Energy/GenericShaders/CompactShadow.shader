// Extremely efficient shader that uses the green channel as shadow brightness: white is pure shade, black is no shade.
shader_type spatial;
render_mode unshaded, blend_mix;

uniform float strength: hint_range(0, 2) = 1.0;
uniform float exponent: hint_range(0.1, 10.0) = 1.0;
uniform float alpha: hint_range(0, 1) = 1.0;
uniform vec4 color: hint_color;
uniform sampler2D texture_shadow: hint_white;

highp float rand(vec2 co) {
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

void fragment() {
	ALBEDO = color.rgb;
	float temp_alpha = pow(1.0 - texture(texture_shadow, UV).g, exponent) * strength - ((rand(FRAGCOORD.xy) - 0.5) / 64.0);
	ALPHA = temp_alpha * alpha;
}