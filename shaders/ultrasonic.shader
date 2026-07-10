shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform lowp vec4 u_color = vec4(1,0,0,1);

varying lowp float v_dist;
varying lowp float v_opacity;
varying lowp float v_brightness;

uniform sampler2D alphaTexture;
uniform sampler2D colorRamp : hint_albedo;
 
void vertex() 
{
   v_dist = NORMAL.y;
   v_opacity = NORMAL.x * u_color.a;
   v_brightness = u_color.r;
}

void fragment() 
{
    float alpha = texture(alphaTexture, UV).a * v_opacity;
    vec4 color = texture(colorRamp, vec2(v_dist, 0.0));
	ALPHA = color.a * alpha;
	ALBEDO = color.rgb * v_brightness;
}
