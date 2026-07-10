shader_type spatial;
render_mode depth_draw_never, unshaded;

uniform float invert_texture = 0;
uniform vec4 u_color : hint_color;
uniform sampler2D u_texture : hint_black;
varying float v_fog;

void vertex() {
	v_fog = 1.0-clamp((-WORLD_MATRIX[3][2] - 5.0) / 120.0, 0.0, 1.0);
}

void fragment() {
	float v = abs(invert_texture - texture(u_texture, UV).r);
	ALBEDO = u_color.rgb;
	ALPHA = v * u_color.a * v_fog ;
}