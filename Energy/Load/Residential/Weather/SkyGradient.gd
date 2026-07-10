extends MeshInstance
onready var sun_center = get_node_or_null("../SunCenter")
onready var material = self.get_surface_material(0)
onready var base_sunset_factor = 0.0
onready var sunset_factor = 0.0
onready var current_cloud_factor = 0.0
onready var slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/DaySlider")
onready var cloud_slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/CloudSlider")
onready var animation_node = get_node_or_null("../SunCenterAnimation/AnimationPlayer")
onready var gradient_center_node = get_node_or_null("../SunCenterAnimation/SunCenterEmpty")
onready var alpha_tween = Tween.new()
var animation_length = 1.0
onready var day_strength = 1.0
var previous_time_of_day = null
var previous_cloud_factor = null

onready var energy_site = find_parent("EnergySite*")

func _ready():
	add_child(alpha_tween)
	if sun_center == null:
		sun_center = self
	if slider_node != null:
		slider_node.connect("update_time_of_day", self, "_on_time_of_day_change")
	if cloud_slider_node != null:
		cloud_slider_node.connect("update_cloud_cover", self, "_on_update_cloud_cover")
	if animation_node != null:
		animation_length = animation_node.get_animation("SunHaloAction").length
		
	if energy_site == null: return
	energy_site.connect("on_energy_site_update", self, "update_weather")
	update_weather(energy_site.data)

func update_weather(data: EnergySiteData):
	if data == null or data.energy_site_summary == null or data.energy_site_summary.weather == null:
		self.visible = false
		return
	self.visible = true
	var weather = data.energy_site_summary.weather
	var time_of_day = weather.get("time_of_day")
	if time_of_day == null and weather.has("time_of_day"):
		print("WEATHER DOESNT HAVE TIME OF DAY, fading away sky")
		fade_away(0)
	var cloud_factor = weather.get("cloud_factor")
	if time_of_day != null and time_of_day != previous_time_of_day:
		_on_time_of_day_change(time_of_day)
		previous_time_of_day = time_of_day
	if cloud_factor != null and cloud_factor != previous_cloud_factor:
		_on_update_cloud_cover(cloud_factor)
		previous_cloud_factor = cloud_factor
	
func _on_update_cloud_cover(value):
	if value == null: return

	
	current_cloud_factor = value
	_update_effective_sunset_factor()

	var remapped_value = clamp(remap_value(value, 40.0, 100.0, 0.0, 1.0), 0, 1)
	self.get_surface_material(0).set_shader_param("color_override", Color(0.5, 0.5, 0.5, 1.0))
	self.get_surface_material(0).set_shader_param("color_override_factor", remapped_value)
	
func _on_time_of_day_change(value):
	var gradient_center_y = clamp(remap_value(gradient_center_node.transform.origin.y, - 2, 1.081, 0.673, 0.507), 0.673, 0.507)
	var gradient_center_x = clamp(remap_value(gradient_center_node.transform.origin.z, - 3.937, 3.973, 0.125, 0.8), 0.125, 0.8)
	var sunset_start_height = 0.46

	if value > 85:
		day_strength = clamp(remap_value(value, 85, 90, 1.0, 0.0), 0.0, 1.0)
		base_sunset_factor = - 1
	elif value < 15:
		day_strength = clamp(remap_value(value, 10, 15, 0.0, 1.0), 0.0, 1.0)
		base_sunset_factor = 1
	else:
		day_strength = 1
		base_sunset_factor = 0.0

	
	_update_effective_sunset_factor()

	material.set_shader_param("center_position_x", gradient_center_x)
	material.set_shader_param("center_position_y", - gradient_center_y)
	material.set_shader_param("day_strength", day_strength)

func _update_effective_sunset_factor():
	
	var cloud_dampening = 1.0 - (current_cloud_factor / 100.0)
	sunset_factor = base_sunset_factor * cloud_dampening
	material.set_shader_param("sunset_factor", sunset_factor)

func fade_away(fade_to):
	var current_alpha = self.get_surface_material(0).get_shader_param("alpha")
	if current_alpha == null:
		current_alpha = 1.0
	
	alpha_tween.stop_all()
	alpha_tween.interpolate_method(self, "_animate_alpha", current_alpha, fade_to, 0.5, Tween.EASE_OUT, Tween.TRANS_SINE)
	alpha_tween.start()

func _animate_alpha(alpha_value):
	self.get_surface_material(0).set_shader_param("alpha", alpha_value)

func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
