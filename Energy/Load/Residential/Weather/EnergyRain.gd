extends Spatial

onready var rain_slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/RainSlider")
export (NodePath)onready var rain_drops = get_node(rain_drops)
export (NodePath)onready var ground_splash = get_node(ground_splash)
export (NodePath)onready var roof_splash_left = get_node(roof_splash_left)
export (NodePath)onready var roof_splash_right = get_node(roof_splash_right)

onready var energy_site = find_parent("EnergySite*")

var remapped_value = 1
var previous_rain_factor = - 100

func _ready():
	if rain_slider_node != null:
		rain_slider_node.connect("update_rain_amount", self, "_on_update_rain_amount")

	if energy_site == null: return
	energy_site.connect("on_energy_site_update", self, "update_weather")
	update_weather(energy_site.data)

func update_weather(data: EnergySiteData):
	if data == null: return
	var weather = data.energy_site_summary.weather
	if weather == null or weather.empty():
		rain_drops.visible = false
		roof_splash_right.visible = false
		roof_splash_left.visible = false
		ground_splash.visible = false
		return
	else:
		rain_drops.visible = true
		roof_splash_right.visible = true
		roof_splash_left.visible = true
		ground_splash.visible = true
	var rain_factor = weather.get("rain_factor")
	if rain_factor != null and rain_factor != previous_rain_factor:
		_on_update_rain_amount(rain_factor)
		previous_rain_factor = rain_factor

func _on_update_rain_amount(value):
	var remapped_value_drops = remap_value(value, 0.0, 100.0, 0.0, 500)
	var remapped_value_splash = remap_value(value, 0.0, 100.0, 0.0, 50.0)
	if remapped_value_drops > 0:
		
		self.visible = true
		rain_drops.visible = true
		rain_drops.emitting = true
		ground_splash.emitting = true
		roof_splash_left.emitting = true
		roof_splash_right.emitting = true
		
		ground_splash.visible = true
		roof_splash_left.visible = true
		roof_splash_right.visible = true
		
		rain_drops.amount = remapped_value_drops
		ground_splash.amount = ceil(remapped_value_splash)
		roof_splash_left.amount = ceil(remapped_value_splash * 0.6)
		roof_splash_right.amount = ceil(remapped_value_splash * 0.6)
		
	elif remapped_value_drops == 0:
		self.visible = false
		rain_drops.visible = false
		rain_drops.emitting = false
		ground_splash.emitting = false
		roof_splash_left.emitting = false
		roof_splash_right.emitting = false
		
		ground_splash.visible = false
		roof_splash_left.visible = false
		roof_splash_right.visible = false
			
func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
