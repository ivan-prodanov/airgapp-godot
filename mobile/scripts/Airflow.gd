tool
extends MeshInstance
class_name Airflow

# iOS GLES2 fixes (renders identically on macOS):
#  - The airflow used VisualShader resources, which fall back to opaque white on iOS. Plain Shaders
#    with the same GLSL render correctly.
#  - The QuadMesh's UV channel does not interpolate on iOS (UV.x stays 0), collapsing the effect.
#    VERTEX does interpolate, so the quad UV is derived from VERTEX (matching Godot's QuadMesh UV
#    mapping: UV.x = VERTEX.x + 0.5, UV.y = 0.5 - VERTEX.y).
# The material stays SHARED across both airflow nodes (as in the original), so both nodes advance the
# same `time` each frame (effective delta*1.0) — i.e. the original animation speed is unchanged.
const _SHADER_BODY := """uniform vec4 color : hint_color;
uniform float time;
uniform sampler2D Noise;

varying vec2 quv;

void vertex() {
	quv = vec2(VERTEX.x + 0.5, 0.5 - VERTEX.y);
}

void fragment() {
	vec2 uvn = vec2(quv.x * 1.5, quv.y * 0.35 + time * -0.8);
	vec3 n = texture(Noise, uvn).rgb;
	float ampX = 1.0 - abs(quv.x - 0.5) * 2.0;
	float ampY = clamp(quv.y / 0.05, 0.0, 1.0);
	ALBEDO = color.rgb;
	ALPHA = dot(n, vec3(0.333333)) * (1.0 - quv.y) * ampY * ampX * 3.0;
}"""

var shader_mat: ShaderMaterial
var shader_default: Shader
var shader_above: Shader
var noise_tex: Texture = load("res://mobile/materials/airflow_noise.png")

enum WaveType{COLD, HEAT}
const defaultColors = {
	WaveType.COLD: Color("#FFFFFF"),
	WaveType.HEAT: Color("#EA4040")
}
const colorsWhenAbove = {
	WaveType.COLD: Color("#707070"),
	WaveType.HEAT: Color("#704040")
}

var currentWaveType = WaveType.COLD
var is_showing_above = false

func _make_shader(extra_render_mode):
	var s = Shader.new()
	s.code = "shader_type spatial;\nrender_mode blend_add, unshaded, shadows_disabled" + extra_render_mode + ";\n" + _SHADER_BODY
	return s

func _ready():
	shader_default = _make_shader("")
	shader_above = _make_shader(", depth_test_disable")

	# Keep the SHARED material (material_override is the same resource on both airflow nodes), just
	# swap its shader to the iOS-safe plain Shader. Preserves the original double-advance speed.
	shader_mat = material_override
	if shader_mat != null and shader_mat is ShaderMaterial:
		shader_mat.shader = shader_default
		shader_mat.set_shader_param("Noise", noise_tex)
		var rand = RandomNumberGenerator.new()
		rand.randomize()
		shader_mat.set_shader_param("time", rand.randf_range(0.0, 10.0))
		set_type(currentWaveType)

func show_above(above: bool):
	is_showing_above = above
	if shader_mat != null:
		shader_mat.shader = shader_above if above else shader_default
		shader_mat.set_shader_param("Noise", noise_tex)
		set_type(currentWaveType)

func set_type(type: int):
	self.currentWaveType = type
	if shader_mat != null:
		shader_mat.set_shader_param("color", get_color())

func get_color():
	if is_showing_above:
		return colorsWhenAbove.get(currentWaveType)
	return defaultColors.get(currentWaveType)

func _process(delta):
	if visible and shader_mat != null:
		var time = fmod(shader_mat.get_shader_param("time") + delta * 0.5, 10.0)
		shader_mat.set_shader_param("time", time)
