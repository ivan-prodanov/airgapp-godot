tool
extends MeshInstance
class_name DefrostFront

# iOS GLES2 fix (same family as the airflow): the front defrost used a VisualShader (opaque fallback
# on iOS) and its effect relies on UV.x, which doesn't interpolate on iOS for this mesh either. So
# rebuild as a plain Shader and derive the UV from VERTEX (which DOES interpolate). This mesh's UV
# maps as UV.x = normalized VERTEX.x and UV.y = normalized VERTEX.z, using the mesh AABB (passed as
# uniforms). u_noise is bound to the baked .stex (the procedural NoiseTexture samples wrong on iOS).
const _BODY := """uniform sampler2D u_noise;
uniform float time;
uniform vec4 color : hint_color;
uniform vec3 u_aabb_min;
uniform vec3 u_aabb_size;

varying vec2 quv;

void vertex() {
	quv = vec2((VERTEX.x - u_aabb_min.x) / max(u_aabb_size.x, 0.0001),
	           (VERTEX.z - u_aabb_min.z) / max(u_aabb_size.z, 0.0001));
}

void fragment(){
	ALBEDO = color.rgb;
	float alpha = texture(u_noise, vec2(quv.x * 0.2 + time * 0.5, quv.y)).r;
	ALPHA = alpha * quv.x;
}"""

var shader_mat: ShaderMaterial
var shader_default: Shader
var shader_above: Shader
var noise_tex: Texture = load("res://mobile/materials/airflow_noise.png")

var is_showing_above = false

func _make_shader(extra_render_mode):
	var s = Shader.new()
	s.code = "shader_type spatial;\nrender_mode unshaded, cull_disabled" + extra_render_mode + ";\n" + _BODY
	return s

func _ready():
	shader_default = _make_shader("")
	shader_above = _make_shader(", depth_test_disable")

	shader_mat = self.get_surface_material(0)
	if shader_mat != null and shader_mat is ShaderMaterial:
		shader_mat.shader = shader_default
		shader_mat.set_shader_param("u_noise", noise_tex)
		_set_aabb()
		var rand = RandomNumberGenerator.new()
		rand.randomize()
		shader_mat.set_shader_param("time", rand.randf_range(0.0, 10.0))

func _set_aabb():
	if mesh != null:
		var aabb = mesh.get_aabb()
		shader_mat.set_shader_param("u_aabb_min", aabb.position)
		shader_mat.set_shader_param("u_aabb_size", aabb.size)

func show_above(above: bool):
	is_showing_above = above
	if shader_mat != null:
		shader_mat.shader = shader_above if above else shader_default
		shader_mat.set_shader_param("u_noise", noise_tex)
		_set_aabb()

func _process(delta):
	if visible and shader_mat != null:
		var time = fmod(shader_mat.get_shader_param("time") + delta * 0.5, 10.0)
		shader_mat.set_shader_param("time", time)
