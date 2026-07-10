shader_type spatial;
render_mode blend_add,depth_draw_never,unshaded;

uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;

uniform float close_blend_start = 0.0;
uniform float close_blend_end = 0.0;
uniform float far_blend_start = 0.0;
uniform float far_blend_end = 0.0;
uniform float view_dot_normal_blend_start = 0.0;
uniform float view_dot_normal_blend_end = 0.0;
uniform float view_fwd_dot_normal_blend_start = 0.0;
uniform float view_fwd_dot_normal_blend_end = 0.0;

varying vec3 v_vertex_world;
varying float v_vertex_height_camera_space;

void vertex() {
	vec3 cam_world = CAMERA_MATRIX[3].xyz;
	v_vertex_world = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_vertex_height_camera_space = v_vertex_world.y - cam_world.y;
	//MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],CAMERA_MATRIX[1],CAMERA_MATRIX[2],WORLD_MATRIX[3]);
}




void fragment() {
	vec4 albedo_tex = texture(texture_albedo,UV);
	albedo_tex.rgb = mix(pow((albedo_tex.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex.rgb.rgb * (1.0 / 12.92),lessThan(albedo_tex.rgb,vec3(0.04045)));
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	
	float dist_to_vert = length(VERTEX);
	float close_fade = smoothstep(close_blend_start, close_blend_end, dist_to_vert);
	
	float far_fade = 1.0f - smoothstep(far_blend_start, far_blend_end, dist_to_vert);
	
	float view_dot_normal = dot(NORMAL, normalize(VERTEX));
	float parallel_view_fade = smoothstep(view_dot_normal_blend_start, view_dot_normal_blend_end, abs(view_dot_normal));
	
	float view_fwd_dot_normal = -NORMAL.z; //equal to dot(NORMAL, vec3(0.0, 0.0, -1.0));
	float parallel_fwd_view_fade = smoothstep(view_fwd_dot_normal_blend_start, view_fwd_dot_normal_blend_end, abs(view_fwd_dot_normal));
	
	ALPHA = albedo.a * albedo_tex.a * close_fade * far_fade * parallel_view_fade * parallel_fwd_view_fade;

	//float close_to_car = 1.0f - smoothstep(-2.5, -2.4, v_vertex_world.z);
	//ALPHA *= close_to_car;
	
	//float height = 1.0f - smoothstep(-0.5, -0.3, vertex_height_camera_space);
	//ALPHA *= height;
//	if (v_vertex_world.z < -4.0)
//	{
//		ALPHA *= 1.0f - smoothstep(-4.0, -d5.0, v_vertex_world.z);
//	}
}
