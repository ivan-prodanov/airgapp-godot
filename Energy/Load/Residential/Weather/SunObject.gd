extends MeshInstance

onready var cloud_slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/CloudSlider")
onready var slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/DaySlider")
onready var energy_site = find_parent("EnergySite*")
onready var sun_cover = get_child(1)
onready var reference_cloud_alpha = 1.0
onready var reference_TOD_alpha = 1.0
onready var reference_final_alpha = 0.0
onready var reference_surface_color = Color(1.0, 1.0, 1.0, 1.0)
onready var base_sunset_color = Color(1.0, 1.0, 1.0, 1.0)
onready var current_cloud_factor = 0.0
onready var alpha_tween = Tween.new()
onready var color_tween = Tween.new()
onready var is_night = false
var use_smooth_transitions = true
var previous_cloud_factor = null
var previous_time_of_day = 0

func _ready():
	add_child(alpha_tween)
	add_child(color_tween)
	
	if cloud_slider_node != null:
		cloud_slider_node.connect("update_cloud_cover", self, "_on_update_cloud_cover")
	if slider_node != null:
		slider_node.connect("update_time_of_day", self, "_on_time_of_day_change")
	if energy_site == null: return
	energy_site.connect("on_energy_site_update", self, "update_weather")
	update_weather(energy_site.data)

func update_weather(data: EnergySiteData):
	if data == null: return
	var weather = data.energy_site_summary.weather
	if weather == null: return
	is_night = weather.get("is_night")
	if is_night:
		alpha_tween.stop_all()
		set_material_alpha(0)
		return
	var cloud_factor = weather.get("cloud_factor")
	if cloud_factor != null and cloud_factor != previous_cloud_factor:
		_on_update_cloud_cover(cloud_factor)
		previous_cloud_factor = cloud_factor
	var time_of_day = weather.get("time_of_day")
	var effective_time = time_of_day if time_of_day != null else 0
	if effective_time != previous_time_of_day:
		_on_time_of_day_change(effective_time)
		previous_time_of_day = effective_time

func _on_update_cloud_cover(value):
	
	if is_night:
		alpha_tween.stop_all()
		set_material_alpha(0)
		return

	
	current_cloud_factor = value

	var remapped_value = remap_value(value, 0.0, 100.0, 0.0, 1.0)
	var new_cloud_alpha = clamp((1.1 - remapped_value), 0, 1)

	if use_smooth_transitions:
		
		alpha_tween.stop_all()
		alpha_tween.interpolate_method(self, "_animate_alpha", get_current_alpha(), calculate_final_alpha(new_cloud_alpha, reference_TOD_alpha), 0.5, Tween.EASE_OUT, Tween.TRANS_QUART)
		alpha_tween.start()
	else:
		
		set_material_alpha(calculate_final_alpha(new_cloud_alpha, reference_TOD_alpha))

	reference_cloud_alpha = new_cloud_alpha

	
	_update_effective_sunset_color()
	
func _on_time_of_day_change(value):
	
	if is_night:
		alpha_tween.stop_all()
		set_material_alpha(0)
		return
	var remapped_value = remap_value(value, 0.0, 100.0, 0.0, 1.0)
	remapped_value = 4.0 * (remapped_value - 0.5) * (remapped_value - 0.5)
	var new_TOD_alpha = 0.0
	base_sunset_color = Color(1.0, 1.0, 1.0, 1.0)
	if value != 0:
		new_TOD_alpha = 1.0 - remapped_value
		base_sunset_color = Color(
			clamp(1.0, 0.0, 1.0), 
			clamp(1.2 - (remapped_value * 0.7772), 0.0, 1.0), 
			clamp(1.2 - (remapped_value * 0.93), 0.0, 1.0), 
			1.0
		)

	if use_smooth_transitions:
		alpha_tween.stop_all()
		alpha_tween.interpolate_method(self, "_animate_alpha", get_current_alpha(), calculate_final_alpha(reference_cloud_alpha, new_TOD_alpha), 0.5, Tween.EASE_OUT, Tween.TRANS_QUART)
		alpha_tween.start()
	else:
		set_material_alpha(calculate_final_alpha(reference_cloud_alpha, new_TOD_alpha))

	
	_update_effective_sunset_color()
	reference_TOD_alpha = new_TOD_alpha

func _update_effective_sunset_color():
	
	
	var cloud_dampening = (current_cloud_factor / 100.0) * 0.5
	var white_color = Color(1.0, 1.0, 1.0, 1.0)
	var effective_color = base_sunset_color.linear_interpolate(white_color, cloud_dampening)

	set_material_color(effective_color)
	reference_surface_color = effective_color

func fade_away(fade_to):
	if fade_to == null:
		alpha_tween.stop_all()
		if is_night:
			set_material_alpha(0)
		else:
			alpha_tween.interpolate_method(self, "_animate_alpha", get_current_alpha(), reference_final_alpha, 0.5, Tween.EASE_OUT, Tween.TRANS_QUART)
			alpha_tween.start()
		return
		
	alpha_tween.stop_all()
	alpha_tween.interpolate_method(self, "_animate_alpha", get_current_alpha(), fade_to, 0.5, Tween.EASE_OUT, Tween.TRANS_QUART)
	alpha_tween.start()

func get_current_alpha():
	var current_material = self.get_surface_material(0)
	if current_material != null:
		var alpha = current_material.get_shader_param("alpha_factor")
		return alpha if alpha != null else calculate_final_alpha(reference_cloud_alpha, reference_TOD_alpha)
	else:
		return calculate_final_alpha(reference_cloud_alpha, reference_TOD_alpha)

func get_current_color():
	var current_material = self.get_surface_material(0)
	if current_material != null:
		var color = current_material.get_shader_param("albedo")
		return color if color != null else reference_surface_color
	else:
		return reference_surface_color

func _animate_alpha(alpha_value):
	set_material_alpha(alpha_value)

func _animate_color(color_value):
	set_material_color(color_value)

func set_material_alpha(alpha_value):
	var current_material = self.get_surface_material(0)
	if current_material != null:
		current_material.set_shader_param("alpha_factor", alpha_value)
	else:
		print("Warning: SunObject material not found for alpha")

func set_material_color(color_value):
	var current_material = self.get_surface_material(0)
	if current_material != null:
		current_material.set_shader_param("albedo", color_value)
	else:
		print("Warning: SunObject material not found for color")

func calculate_final_alpha(reference_cloud_alpha, reference_TOD_alpha):
	reference_final_alpha = min(reference_cloud_alpha, reference_TOD_alpha)
	return reference_final_alpha
	
func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
