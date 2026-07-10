extends Spatial

onready var slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/DaySlider")
onready var animation_node = get_child(1)
var animation_length = 1.0
var previous_time_of_day = - 1
onready var energy_site = find_parent("EnergySite*")

func _ready():
	if slider_node != null:
		slider_node.connect("update_time_of_day", self, "_on_time_of_day_change")
	if animation_node != null:
		animation_length = animation_node.get_animation("SunHaloAction").length
	
	if energy_site == null: return
	energy_site.connect("on_energy_site_update", self, "update_weather")
	update_weather(energy_site.data)
		
	
func update_weather(data: EnergySiteData):
	if data == null: return
	var weather = data.energy_site_summary.weather
	if weather == null: return
	var time_of_day = weather.get("time_of_day")
	if time_of_day != null: _on_time_of_day_change(time_of_day)
	else:
		_on_time_of_day_change(35)

func _on_time_of_day_change(value):
	var remapped_value = remap_value(value, 0.0, 100.0, 0.0, animation_length)
	animation_node.seek(remapped_value, true)
	animation_node.play("SunHaloAction")
	animation_node.stop()
	
func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
