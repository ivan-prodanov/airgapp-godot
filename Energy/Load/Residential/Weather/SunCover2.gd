extends MeshInstance

onready var cloud_slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/CloudSlider")
onready var slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/DaySlider")
onready var energy_site = find_parent("EnergySite*")
onready var sun_object = null
onready var alpha_tween = Tween.new()

var reference_cloud_alpha = 1.0
var reference_TOD_alpha = 1.0
var target_alpha = 1.0
var is_sun_tweening = false

func _ready():
	add_child(alpha_tween)
	sun_object = get_node_or_null("../SunObject")
	
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
	var cloud_factor = weather.get("cloud_factor")
	if cloud_factor != null: _on_update_cloud_cover(cloud_factor)
	var time_of_day = weather.get("time_of_day")
	if time_of_day != null: _on_time_of_day_change(time_of_day)

func _on_update_cloud_cover(value):
	var remapped_value = clamp(remap_value(value, 0.0, 50.0, 0.0, 1.0), 0, 1)
	reference_cloud_alpha = remapped_value
	set_final_surface_material(reference_cloud_alpha, reference_TOD_alpha)
	
func _on_time_of_day_change(value):
	var remapped_value = remap_value(value, 25.0, 75.0, 0.0, 1.0)
	remapped_value = 4.0 * (remapped_value - 0.5) * (remapped_value - 0.5)
	reference_TOD_alpha = 1.0 - remapped_value
	set_final_surface_material(reference_cloud_alpha, reference_TOD_alpha)

func set_final_surface_material(cloud_value, TOD_value):
	var final_alpha = min(cloud_value, TOD_value)
	if final_alpha != target_alpha:
		target_alpha = final_alpha
		get_surface_material(0).set_shader_param("alpha_factor", target_alpha)

func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
