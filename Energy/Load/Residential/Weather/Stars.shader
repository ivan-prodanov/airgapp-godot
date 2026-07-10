shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;

uniform highp float star_density = 0.05; 
uniform highp float twinkle_speed = 1.0;
uniform highp float scale = 20.0; 
uniform vec4 background_color: hint_color = vec4(0.0, 0.0, 0.0, 1.0); // Black default for testing
uniform highp float base_brightness: hint_range(-0.5, 0.5) = 0.1;

uniform vec4 star_color_top : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 star_color_bottom : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float base_star_size : hint_range(0.0, 0.1) = 0.02;

float hash(vec2 p) {
    p = mod(p, 289.0);
    p = mod(p * 34.0 + 1.0, 289.0);
    p = mod(p * 34.0 + 1.0, 289.0);
    return fract(p.x * p.y / 289.0);
}

void vertex() {
    // Uncomment if you need custom UV scaling
    // UV = UV * vec2(scale) + vec2(0.0); // Example; adjust as needed
}

void fragment() {
    highp vec2 uv = UV * scale;
    highp vec2 grid_id = floor(uv);
    grid_id = fract(grid_id * 0.01); // Aggressive wrap to keep values small (prevents precision loss on large grids)
    highp vec2 grid_pos = fract(uv);
    
    highp vec3 base_color = vec3(0.0, 0.0, 0.0);
    highp float star_count = 0.0; // Debug tracker
    
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            highp vec2 offset = vec2(float(x), float(y));
            highp vec2 neighbor_id = grid_id + offset;
            
            highp float rand = hash(neighbor_id);
            
            if (rand < star_density) {
                highp vec2 star_pos = vec2(hash(neighbor_id + vec2(0.1)), hash(neighbor_id + vec2(0.2)));
                highp float dist = length(grid_pos - star_pos - offset);
                
                highp float twinkle = sin(TIME * twinkle_speed + hash(neighbor_id + vec2(0.3)) * 6.28) * 0.5 + 0.5;
                highp float star_size = base_star_size * (0.5 + 0.5 * twinkle); 
                highp float brightness = clamp(base_brightness + 0.5 * twinkle, 0.0, 1.0);
                
                highp float star = smoothstep(star_size, star_size * 0.5, dist);
                base_color += vec3(star * brightness);
				
                star_count += 1.0;
            }
        }
    }
    
	if (star_count == 0.0) {
        base_color += vec3(0.2, 0.0, 0.0); // Red tint (running but no stars)
    }
	vec3 star_color = mix(star_color_top.rgb, star_color_bottom.rgb, UV.y -0.1);
    vec3 final_pixel = mix(background_color.rgb, star_color.rgb, base_color.r);
    ALBEDO = clamp(final_pixel, vec3(0.0), vec3(1.0));
	ALPHA = 1.0;
}