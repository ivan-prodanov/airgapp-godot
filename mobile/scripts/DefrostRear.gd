tool
extends MeshInstance
class_name DefrostRear

# iOS GLES2 fix (same as DefrostFront): VisualShader → plain Shader, and the UV.x it relies on doesn't
# interpolate on iOS, so derive it from VERTEX via the mesh AABB (UV.x = norm VERTEX.x, UV.y = norm
# VERTEX.z). This is the static gradient defrost (no noise/animation).
const _BODY := """uniform vec4 color : hint_color;
uniform float amplitude = 1.0;
uniform vec3 u_aabb_min;
uniform vec3 u_aabb_size;

varying vec2 quv;

void vertex() {
	quv = vec2((VERTEX.x - u_aabb_min.x) / max(u_aabb_size.x, 0.0001),
	           (VERTEX.z - u_aabb_min.z) / max(u_aabb_size.z, 0.0001));
}

void fragment(){
	ALBEDO = color.rgb;
	ALPHA = 1.0 - quv.x * amplitude;
}"""

var shader_mat: ShaderMaterial
var shader_default: Shader
var shader_above: Shader

var is_showing_above = false

func _make_shader(extra_render_mode):
	var s = Shader.new()
	s.code = "shader_type spatial;\nrender_mode unshaded" + extra_render_mode + ";\n" + _BODY
	return s

func _ready():
	shader_default = _make_shader("")
	shader_above = _make_shader(", cull_disabled")

	shader_mat = self.get_surface_material(0)
	if shader_mat != null and shader_mat is ShaderMaterial:
		shader_mat.shader = shader_default
		_set_aabb()

func _set_aabb():
	if mesh != null:
		var a = mesh.get_aabb()
		shader_mat.set_shader_param("u_aabb_min", a.position)
		shader_mat.set_shader_param("u_aabb_size", a.size)

func show_above(above: bool):
	is_showing_above = above
	if shader_mat != null:
		shader_mat.shader = shader_above if above else shader_default
		_set_aabb()
