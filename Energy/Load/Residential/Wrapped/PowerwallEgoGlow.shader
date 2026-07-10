shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec4 color_gradient_inner : hint_color;
uniform vec4 color_gradient_outer : hint_color;

uniform vec2 box_size = vec2(0.2, 0.2);
uniform vec2 box_size_2 = vec2(0.2, 0.2);
uniform vec2 box_center = vec2(0.0, 0.0);
uniform vec2 box_center_2 = vec2(0.0, 0.0);
uniform float falloff = 0.1;
uniform float blend_box = 0.1;
uniform float visibility = 0.0;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}

// Signed distance function for a box, see https://iquilezles.org/articles/distfunctions2d/
float sdBox(vec2 p, vec2 b, vec2 rand_factor) {
   vec2 d = abs(p) - b ;
   float flat_box = max(d.x, d.y); // Sharp edge behavior
   float smooth_box = length(max(d, 0.0)) + min(flat_box, 0.0); // Smooth corner bevahior
   return mix(flat_box, smooth_box, blend_box); // Adjust blend_box to get the desired rectangle shape
}

void fragment() {
	vec2 base_uv = abs(UV - 0.5) * 2.0;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	
    vec2 local_pos = base_uv - box_center;
	vec2 local_pos_2 = base_uv - box_center_2;

    // Compute the distance from the box edge
    float d = sdBox(local_pos, box_size, vec2(0.0,0.0));
	float d_2 = sdBox(local_pos_2, box_size_2, vec2(0.0,0.0));

    // Map the distance to a gradient
    float gradient = smoothstep(falloff, 0.0, d); 
	float gradient_2 = smoothstep(falloff, 0.0, d_2); 

    vec3 color = mix(color_gradient_outer.xyz, color_gradient_inner.xyz, gradient_2); 
	float calculated_alpha = mix(color_gradient_outer.a, color_gradient_inner.a, gradient) * visibility;

    ALBEDO = color;
	ALPHA = calculated_alpha;
	
	
}
