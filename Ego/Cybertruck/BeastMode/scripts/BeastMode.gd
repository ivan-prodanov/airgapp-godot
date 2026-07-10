extends Spatial

export (float) var time_to_activate_easter_egg

var timer: Timer
var light: DirectionalLight
var tween: Tween
var tunnel: Spatial
var tunnel_material: ShaderMaterial

var isLaunched = false
var isPrimed = false
var isCheetahStanceReady = false
var rng = RandomNumberGenerator.new()
var speedTimeLine = 0
var timeOn = 0
var cheetahTimeOn = 0
var travelDist = 0
var triangleFade = 0

export (Color) var bg_color: Color setget set_bg_color
export (float) var scene_brightness = 1 setget set_scene_brightness
export (bool) var color_inversion_enabled setget enable_color_inversion
export (float) var light_intensity_modifier = 1
export (bool) var enable_reverse_line_movement setget set_enable_reverse_line_movement

func _ready():
	tween = $Scaler / Tween
	timer = $Scaler / Timer
	light = $Scaler / DirectionalLight
	
	tunnel = $Scaler / Tunnel
	tunnel_material = tunnel.get_child(0).get_surface_material(0)
	
	reset()
	
func _process(delta):
	if isLaunched:
		timeOn += delta
		var easter_egg_time = max(0.0, timeOn - time_to_activate_easter_egg)
		
		speedTimeLine += (1 - speedTimeLine) * 0.1
		var easter_egg_speed_pct = EaseInOutQuad(min(1.0, easter_egg_time * 0.5));
		travelDist += delta * speedTimeLine * 0.2 + delta * easter_egg_speed_pct * 0.25;
		var ca_offset_factor = (0.0001 + min(0.01, easter_egg_time * 0.005)) * speedTimeLine
		
		tunnel_material.set_shader_param("ca_offset_factor", ca_offset_factor)
		tunnel_material.set_shader_param("speed_time_line", speedTimeLine)
		if isPrimed:
			light.light_energy = rng.randf_range(10.0, 30.0) * light_intensity_modifier
	elif isCheetahStanceReady:
		cheetahTimeOn += delta
		tunnel_material.set_shader_param("pulse_time", cheetahTimeOn)

	tunnel_material.set_shader_param("travel_dist", travelDist)
	tunnel_material.set_shader_param("triangle_fade", max(triangleFade, 0.0))

func prime():
	reset()
	
	isPrimed = true
	
	tunnel.show()
	
	var blendInTime = 2.7
	tween.interpolate_property(light, "light_energy", 
		0, 12, blendInTime, Tween.TRANS_QUART, Tween.EASE_OUT)
		
	tween.interpolate_property(tunnel, "translation:z", 
		- 70, - 34.7, blendInTime, Tween.TRANS_QUART, Tween.EASE_OUT)
	
	if enable_reverse_line_movement:
		tween.interpolate_property(self, "travelDist", 
			0, - 0.035, blendInTime * 2.8, Tween.TRANS_CIRC, Tween.EASE_OUT);
	
	tween.interpolate_property(self, "triangleFade", 
		- 1.0, 1.0, blendInTime, Tween.TRANS_QUAD, Tween.EASE_OUT);
	
	tween.start()
	
	
	
func cheetah_stance_ready():
	isCheetahStanceReady = true

func go():
	isLaunched = true
	
	if enable_reverse_line_movement:
		tween.stop(self, "travelDist")
	
	
func stop():
	if (isPrimed):
		var fadeoutTime = 2.0 if isLaunched else 1.0
		tween.interpolate_property(tunnel, "translation:z", 
		tunnel.translation.z, 45, fadeoutTime)
		
		tween.interpolate_property(light, "light_energy", 
		light.light_energy, 0, fadeoutTime, Tween.TRANS_QUART, Tween.EASE_OUT)
		
	timer.start()
	tween.start()
	
	isPrimed = false
	isLaunched = false
	isCheetahStanceReady = false
	
func reset_shader():
	tunnel_material.set_shader_param("speed_time_line", 0)
	tunnel_material.set_shader_param("travel_dist", 0)
	tunnel_material.set_shader_param("ca_offset_factor", 0)
	tunnel_material.set_shader_param("pulse_time", 0)
	set_bg_color(bg_color)

func reset():
	timer.stop()
	isPrimed = false
	isLaunched = false
	isCheetahStanceReady = false
	speedTimeLine = 0
	timeOn = 0
	cheetahTimeOn = 0
	travelDist = 0
	triangleFade = 0
	tunnel.hide()
	reset_shader()
	
	tween.start()
	
func _on_Timer_timeout():
	reset()


func EaseInOutQuad(x: float):
	return 2 * x * x if x < 0.5 else 1 - pow( - 2 * x + 2, 2) / 2;

func EaseOutCubic(x: float):
	return 1.0 - pow(1.0 - x, 3.0);

func set_bg_color(color: Color):
	bg_color = color
	var is_dark_bg = bg_color.g < 0.5
	if is_dark_bg:
		set_scene_brightness(0.7)
		enable_color_inversion(false)
		light_intensity_modifier = 1.0
	else:
		set_scene_brightness(1.0)
		enable_color_inversion(true)
		light_intensity_modifier = 0.5

func set_scene_brightness(brightness: float):
	scene_brightness = brightness
	tunnel_material.set_shader_param("overall_brightness", scene_brightness)
	
func enable_color_inversion(enable: bool):
	color_inversion_enabled = enable
	tunnel_material.set_shader_param("color_invert", 1.0 if color_inversion_enabled else 0.0)

func set_enable_reverse_line_movement(enable: bool):
	enable_reverse_line_movement = enable
