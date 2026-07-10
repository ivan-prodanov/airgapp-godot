shader_type spatial;
render_mode cull_front, unshaded;

const float pulse_frequency = 2.2;
const float pulse_speed = 0.25;
const float two_pi = 6.2831853071795865;
const vec2 cell_count = vec2( 14.0 , 40.0 );

uniform float ca_offset_factor;
uniform float speed_time_line;
uniform float travel_dist;
uniform float overall_brightness;
uniform float color_invert;
uniform float pulse_time;
uniform float triangle_fade = 1.0;

// 2dNoise. Source : https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);
	float res = mix( mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x), mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}

vec3 tile_noise(vec3 mod_x, vec3 mod_y)
{
	return (vec3( 
			noise( vec2( mod_x.x, mod_y.x ) * 100.0 ),
			noise( vec2( mod_x.y, mod_y.y ) * 100.0 ),
			noise( vec2( mod_x.z, mod_y.z ) * 100.0 )
		) + 1.0) * 0.5;
}

// separate channels for chromatic aberration
vec3 gridCompute( vec2 uv, vec2 ca_offset ){
	// Operating on 3 different uv's at a time as an optimization
	vec3 uvs_x = vec3( uv.x - ca_offset.x, uv.x, uv.x + ca_offset.x );
	vec3 uvs_y = vec3( uv.y - ca_offset.y, uv.y, uv.y + ca_offset.y );
	
	// lines
	vec2 line_width = vec2( 0.2, 0.02 );
	line_width.x += - uv.y * 0.15;
	line_width.y += 0.1 * pow( ( uv.y ), 2.0 ) * speed_time_line;
	line_width.y += min( 1.0, pulse_time ) * smoothstep(0.8, 1.0, sin( fract ( (uvs_y.g - pulse_time * pulse_speed) * pulse_frequency) * two_pi ) ) * 0.18 * (0.5 + (1.0 - uv.y) * 0.5) * (1.0 - speed_time_line);
	line_width.y *= triangle_fade;
	float line_blur_x = 0.5 + 0.5 * speed_time_line;
	
	vec3 x_mod = fract( uvs_x * cell_count.x ); // 0 to 1 for each cell in X direction
	float line_width_with_blur_x = line_width.x * line_blur_x;
	vec3 line_x = 1.0 - smoothstep( 0.0, line_width_with_blur_x, x_mod );
	line_x += smoothstep( 1.0 - line_width_with_blur_x, 1.0, x_mod ); // Full opacity at the start and end of each cell
	
	vec3 y_mod = fract( ( uvs_y - travel_dist ) * cell_count.y ); // 0 to 1 for each cell in Y direction
	vec3 line_y = 1.0 - smoothstep( 0.0, line_width.y, y_mod );
	line_y += smoothstep( 1.0 - line_width.y, 1.0, y_mod ); // Full opacity at the start and end of each cell
	vec3 lines = max( line_x, line_y );
	
	// tiles
	vec3 mod_y = floor( ( uvs_y - travel_dist ) * cell_count.y ) / cell_count.y; // Cell "number", an int for 0 to cell count
    vec3 mod_x = floor( ( uvs_x ) * cell_count.x ) / cell_count.x;
	vec3 tile_noise = tile_noise(mod_x, mod_y); // Random noise for the cell. This is "constant" for each X,Y cell number
	float tile_pass_through = 2.0 - speed_time_line * 1.15; // Threshold to determine which cells should be visible
	vec3 tiles = step( tile_pass_through, tile_noise );
	vec3 opacity = max( tiles, lines );
	return opacity;
}

void fragment() {
	
	float ca_intensity = ( noise( UV * 500.0 - TIME * 10.0 ) + 1.0 ) * 0.5;
	float ca_offset_amount = ca_offset_factor * ca_intensity;
	vec2 ca_offset = vec2( ca_offset_amount, ca_offset_amount * 0.1 );
	
	vec3 col = gridCompute(UV, ca_offset);
	
	// mod brightness of tunnel
	col += vec3( smoothstep( 0.1, 280.0, -VERTEX.z ) );
	col *= 0.1 + smoothstep(5.0, 15.0, length(VERTEX)) * 0.9;
	col = mix(col, (1.0 - col), color_invert);
	col *= overall_brightness;
	ALBEDO = col;
	
	ALPHA = smoothstep(0.0, 0.05, 1.0 - UV.y);
}