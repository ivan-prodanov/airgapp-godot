extends CPUParticles

onready var cloud_slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/CloudSlider")
export var cloud_amount = 0.0
onready var energy_site = find_parent("EnergySite*")

func _ready():
	if cloud_slider_node != null:
		cloud_slider_node.connect("update_cloud_cover", self, "_on_update_cloud_cover")
	if energy_site == null: return
	energy_site.connect("on_energy_site_update", self, "update_weather")
	update_weather(energy_site.data)

func update_weather(data: EnergySiteData):
	if data == null: return
	var weather = data.energy_site_summary.weather
	if weather == null: return
	var cloud_factor = weather.get("cloud_factor")
	if cloud_factor != null: _on_update_cloud_cover(cloud_factor)

func _on_update_cloud_cover(value):
	var remapped_value = remap_value(value, 0.0, 100.0, 0.0, cloud_amount)
	remapped_value = int(remapped_value)
	print("Should be emitting this many clouds: ", remapped_value)
	if remapped_value > 0:
		self.emitting = true
		self.amount = remapped_value
	elif remapped_value == 0:
		self.emitting = false
	
func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
