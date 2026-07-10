extends Spatial


onready var cloud_slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/CloudSlider")
onready var slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/DaySlider")
onready var rain_slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/RainSlider")
onready var night_button = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/IsNight")
onready var energy_site = find_parent("EnergySite*")
onready var lightning_tween = Tween.new()
onready var partial_cloud_tween = Tween.new()
onready var very_cloud_tween = Tween.new()

export (bool)onready var is_sun_parented
export (NodePath)onready var partially_cloudy_parent = get_node(partially_cloudy_parent)
export (NodePath)onready var very_cloudy_parent = get_node(very_cloudy_parent)
export (NodePath)onready var lightning_bolt = get_node(lightning_bolt)
export (NodePath)onready var fog = get_node(fog)
export (NodePath)onready var snow = get_node(snow)

onready var cloudy_night_override = 20.0
var lightning_timer = 0.0
var lightning_active = false
var current_partial_alpha = 0.0
var current_very_alpha = 0.0
var is_night = false
var previous_is_night = false
var previous_cloud_factor = - 100.0
var previous_rain_factor = - 100.0
var previous_snow_factor = - 100.0
var previous_time_of_day = null
var has_been_initialized = false
var base_sunset_factor = 0.0
var current_cloud_factor = 0.0
var sunset_factor = 0.0
var time_of_day_opacity_multiplier = 1.0

func _ready():
	add_child(lightning_tween)
	add_child(partial_cloud_tween)
	add_child(very_cloud_tween)
	if snow != null: snow = snow.get_child(0)
	if cloud_slider_node != null:
		cloud_slider_node.connect("update_cloud_cover", self, "_on_update_cloud_cover")
	if rain_slider_node != null:
		rain_slider_node.connect("update_rain_amount", self, "_on_update_rain_amount")
	if slider_node != null:
		slider_node.connect("update_time_of_day", self, "_on_time_of_day_change")
	if night_button != null:
		night_button.connect("is_night", self, "on_night_change")
	if energy_site == null: return
	energy_site.connect("on_energy_site_update", self, "update_weather")
	update_weather(energy_site.data)

func update_weather(data: EnergySiteData):
	if data == null: return
	var weather = data.energy_site_summary.weather
	if weather == null: return
	is_night = weather.get("is_night")
	var cloud_factor = weather.get("cloud_factor")
	if cloud_factor == null: cloud_factor = 0

	
	if not has_been_initialized or cloud_factor != previous_cloud_factor or is_night != previous_is_night:
		_on_update_cloud_cover(cloud_factor)
		previous_cloud_factor = cloud_factor
		previous_is_night = is_night
	else:
		print("[CLOUD COVER]: skipping cloud update due to similar value")

	var time_of_day = weather.get("time_of_day")
	if not has_been_initialized or time_of_day != previous_time_of_day:
		_on_time_of_day_change(time_of_day)
		previous_time_of_day = time_of_day

	var rain_factor = weather.get("rain_factor")
	var effective_rain = rain_factor if rain_factor != null else 0
	if not has_been_initialized or effective_rain != previous_rain_factor:
		_on_update_rain_amount(effective_rain)
		previous_rain_factor = effective_rain

	var snow_factor = weather.get("snow_factor")
	var effective_snow = snow_factor if snow_factor != null else 0
	if not has_been_initialized or effective_snow != previous_snow_factor:
		on_update_snow_factor(effective_snow)
		previous_snow_factor = effective_snow

	
	has_been_initialized = true
		
func on_update_snow_factor(snow_factor):
	if snow == null: return

	snow.emitting = snow_factor > 1.0
	snow.visible = snow_factor > 1.0

func _on_time_of_day_change(value):
	if value == null: return

	
	if value > 85:
		base_sunset_factor = clamp(remap_value(value, 85, 90, 0.0, 1.0), 0.0, 1.0)
	elif value < 15:
		base_sunset_factor = clamp(remap_value(value, 10, 15, 1.0, 0.0), 0.0, 1.0)
	else:
		base_sunset_factor = 0.0

	
	
	var effective_value = 0 if is_night else value
	if effective_value < 15:
		time_of_day_opacity_multiplier = clamp(remap_value(effective_value, 0, 15, 0.3, 1.0), 0.3, 1.0)
	elif effective_value > 85:
		time_of_day_opacity_multiplier = clamp(remap_value(effective_value, 85, 100, 1.0, 0.3), 0.3, 1.0)
	else:
		time_of_day_opacity_multiplier = 1.0

	
	_update_effective_sunset_factor()

	
	_update_cloud_opacity()

func _on_update_cloud_cover(value):
	
	current_cloud_factor = value
	_update_effective_sunset_factor()

	var remapped_value = clamp(remap_value(value, 0.0, 60.0, 0.1, 1.0), 0, 1)
	var remapped_value_very = clamp(remap_value(value, 50.0, 100.0, 0.6, 1.0), 0, 1)

	
	animate_partial_cloud_alpha(current_partial_alpha, remapped_value, 1.0)
	current_partial_alpha = remapped_value

	
	var target_very_alpha = remapped_value_very if value > 50 else 0.0
	animate_very_cloud_alpha(current_very_alpha, target_very_alpha, 1.0)
	current_very_alpha = target_very_alpha

	
	fog.visible = fog != null and value > 50
	fog.emitting = fog != null and value > 50
	
func on_night_change(is_night_passed):
	
	is_night = is_night_passed
	_on_update_cloud_cover(100)
	
func fade_away(fade_to):
	if fade_to == null:
		fade_to = (previous_cloud_factor / 100)
	animate_partial_cloud_alpha(current_very_alpha, fade_to, 2.0)
	animate_very_cloud_alpha(current_very_alpha, fade_to, 2.0)
	
func animate_partial_cloud_alpha(from_alpha: float, to_alpha: float, duration: float):
	partial_cloud_tween.stop_all()
	partial_cloud_tween.interpolate_method(self, "_set_partial_cloud_alpha", from_alpha, to_alpha, duration, Tween.TRANS_SINE, Tween.EASE_OUT)
	partial_cloud_tween.start()

func animate_very_cloud_alpha(from_alpha: float, to_alpha: float, duration: float):
	very_cloud_tween.stop_all()
	very_cloud_tween.interpolate_method(self, "_set_very_cloud_alpha", from_alpha, to_alpha, duration, Tween.TRANS_SINE, Tween.EASE_OUT)
	very_cloud_tween.start()

func _set_partial_cloud_alpha(alpha: float):
	
	var effective_alpha = alpha * time_of_day_opacity_multiplier
	for child in partially_cloudy_parent.get_children():
		var material = child.get_surface_material(0)
		material.set_shader_param("alpha_factor", effective_alpha)

func _set_very_cloud_alpha(alpha: float):
	
	var effective_alpha = alpha * time_of_day_opacity_multiplier
	for child in very_cloudy_parent.get_children():
		var material = child.get_surface_material(0)
		material.set_shader_param("alpha_factor", effective_alpha)

func _update_effective_sunset_factor():
	
	if is_night:
		sunset_factor = 0
		_update_cloud_sunset_factor()
		return
	var cloud_dampening = 1.0 - (current_cloud_factor / 100.0)
	sunset_factor = min(1.0, (base_sunset_factor * cloud_dampening) * 1.5)

	
	_update_cloud_sunset_factor()

func _update_cloud_sunset_factor():
	
	for child in partially_cloudy_parent.get_children():
		var material = child.get_surface_material(0)
		if material != null and material.shader.has_param("sunset_factor"):
			material.set_shader_param("sunset_factor", sunset_factor)

	for child in very_cloudy_parent.get_children():
		var material = child.get_surface_material(0)
		if material != null and material.shader.has_param("sunset_factor"):
			material.set_shader_param("sunset_factor", sunset_factor)

func _update_cloud_opacity():
	
	_set_partial_cloud_alpha(current_partial_alpha)
	_set_very_cloud_alpha(current_very_alpha)

func _on_update_rain_amount(rain_factor):
	if lightning_bolt == null: return
	if rain_factor > 80 and not lightning_active:
		trigger_lightning_flash()
	else:
		hide_lightning()
		
func hide_lightning():
	lightning_bolt.visible = false
	
func trigger_lightning_flash():
	lightning_bolt.visible = true
	lightning_active = true
	
	
	get_tree().create_timer(1.5).connect("timeout", self, "_start_lightning_sequence")
	
	

func _start_lightning_sequence():
	
	lightning_tween.interpolate_method(self, "_set_lightning_factor", 1.0, 0.0, 0.15)
	lightning_tween.start()
	
	if not lightning_tween.is_connected("tween_completed", self, "_on_lightning_step"):
		lightning_tween.connect("tween_completed", self, "_on_lightning_step")

var lightning_step = 0

func _on_lightning_step(object, key):
	var material = lightning_bolt.get_surface_material(0)
	lightning_step += 1
	
	match lightning_step:
		1:
			lightning_tween.interpolate_method(self, "_set_lightning_factor", 0.0, 1.0, 0.12)
		2:
			lightning_tween.interpolate_method(self, "_set_lightning_factor", 1.0, 0.2, 0.08)
		3:
			lightning_tween.interpolate_method(self, "_set_lightning_factor", 0.2, 1.0, 0.18)
		4:
			lightning_step = 0
			lightning_active = false
			
			var delay = rand_range(2.0, 8.0)
			get_tree().create_timer(delay).connect("timeout", self, "_enable_next_lightning")
			return
	
	lightning_tween.start()

func _set_lightning_factor(value):
	if lightning_bolt != null:
		lightning_bolt.get_surface_material(0).set_shader_param("lightning_factor", value)

func _enable_next_lightning():
	lightning_active = false
	
func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
