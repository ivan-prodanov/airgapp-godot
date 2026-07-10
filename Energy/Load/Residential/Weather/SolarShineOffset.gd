extends MeshInstance

onready var slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/DaySlider")
onready var cloud_slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/CloudSlider")
onready var night_controller_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/IsNight")
export (NodePath)onready var tween = get_node(tween)
export (NodePath)onready var animation_controller = get_node(animation_controller)
export (NodePath)onready var frost = get_node(frost)
export var start_shine_angle = 114
export var end_shine_angle = 35
onready var energy_site = find_parent("EnergySite*")
onready var TOD_shine_factor = 1.0
onready var reference_cloud_shine = 1.0
onready var reference_TOD_shine = 1.0
onready var time_of_day = 99.9
onready var previous_time_of_day = 100
onready var shine_tween = Tween.new()
var use_smooth_transitions = true


func _ready():
	add_child(shine_tween)
	if energy_site == null: return
	energy_site.connect("on_energy_site_update", self, "update_weather")
	update_weather(energy_site.data)
	tween = self.get_child(0)
	
	if slider_node != null:
		slider_node.connect("update_time_of_day", self, "_on_time_of_day_change")
	if cloud_slider_node != null:
		cloud_slider_node.connect("update_cloud_cover", self, "_on_update_cloud_cover")
	if night_controller_node != null:
		night_controller_node.connect("is_night", self, "_on_is_night")
	
func update_weather(data: EnergySiteData):
	if data == null: return
	var weather = data.energy_site_summary.weather
	if weather == null: return
	previous_time_of_day = time_of_day
	if weather.get("time_of_day") != null:
				time_of_day = weather.get("time_of_day")
				animate_TOD(time_of_day)
	var cloud_factor = weather.get("cloud_factor")
	var is_night = weather.get("is_night")
	var snow_factor = weather.get("snow_factor")
	if cloud_factor != null: _on_update_cloud_cover(cloud_factor)
	if is_night != null: _on_is_night(is_night)
	if snow_factor != null: on_update_snow_cover(snow_factor)
	else: on_update_snow_cover(0)
	

func animate_TOD(time_of_day):
	tween.interpolate_property(animation_controller, "current_animation_value", previous_time_of_day, time_of_day, 0.9, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.start()

func _on_time_of_day_change(value):
	var shine_angle = remap_value(value, 0, 100, end_shine_angle, start_shine_angle)
	self.get_surface_material(0).set_shader_param("shine_angle", shine_angle)
	
	var new_TOD_shine
	if value > 50:
		new_TOD_shine = remap_value(value, 50, 100, 1, 0)
	else:
		new_TOD_shine = remap_value(value, 0, 50, 0, 1)
	
	if use_smooth_transitions:
		
		shine_tween.stop_all()
		var current_shine = get_current_shine_factor()
		var target_shine = min(reference_cloud_shine, new_TOD_shine)
		shine_tween.interpolate_method(self, "_animate_shine_factor", current_shine, target_shine, 0.5, Tween.EASE_OUT, Tween.TRANS_QUART)
		shine_tween.start()
	else:
		
		set_shine_factor_direct(min(reference_cloud_shine, new_TOD_shine))
	
	reference_TOD_shine = new_TOD_shine
	TOD_shine_factor = new_TOD_shine
		
func _on_update_cloud_cover(value):
	var new_cloud_shine = remap_value(value, 0, 100, 1, 0)
	
	if use_smooth_transitions:
		
		shine_tween.stop_all()
		var current_shine = get_current_shine_factor()
		var target_shine = min(new_cloud_shine, reference_TOD_shine)
		shine_tween.interpolate_method(self, "_animate_shine_factor", current_shine, target_shine, 0.5, Tween.EASE_OUT, Tween.TRANS_QUART)
		shine_tween.start()
	else:
		
		set_shine_factor_direct(min(new_cloud_shine, reference_TOD_shine))
	
	reference_cloud_shine = new_cloud_shine
	
func _on_is_night(is_night):
	if is_night:
		if use_smooth_transitions:
			transition_solar_panels_smoothly(0.0)
		else:
			set_shine_factor_direct(0.0)
	else:
		if use_smooth_transitions:
			transition_solar_panels_smoothly(min(reference_cloud_shine, reference_TOD_shine))
		else:
			set_shine_factor_direct(min(reference_cloud_shine, reference_TOD_shine))

func transition_solar_panels_smoothly(target_shine):
	shine_tween.stop_all()
	var current_shine = get_current_shine_factor()
	shine_tween.interpolate_method(self, "_animate_shine_factor", current_shine, target_shine, 0.5, Tween.EASE_OUT, Tween.TRANS_QUART)
	shine_tween.start()

func get_current_shine_factor():
	return self.get_surface_material(0).get_shader_param("shine_factor")

func _animate_shine_factor(shine_value):
	set_shine_factor_direct(shine_value)

func set_shine_factor_direct(shine_value):
	self.get_surface_material(0).set_shader_param("shine_factor", shine_value)
		
func set_final_shine_factor():
	print("the reference cloud shine is ", reference_cloud_shine)
	print("the reference TOD shine is ", reference_TOD_shine)
	var final_shine_factor = min(reference_cloud_shine, reference_TOD_shine)
	set_shine_factor_direct(final_shine_factor)


func _on_time_of_day_change_instant(value):
	use_smooth_transitions = false
	_on_time_of_day_change(value)
	use_smooth_transitions = true
	
func on_update_snow_cover(snow_factor):
	if frost == null: return
	print("showing a snow factor of ", snow_factor)
	frost.visible = (snow_factor > 1.0)

func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
	
func _process(delta):
	if tween.is_active():
		_on_time_of_day_change(animation_controller.current_animation_value)
