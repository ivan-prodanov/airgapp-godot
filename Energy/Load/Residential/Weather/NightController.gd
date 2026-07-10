extends Node

onready var night_controller_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/IsNight")
onready var house_shadow = get_node_or_null("/root/Mobile/MainViewContainer/Viewport/root/ProductSwitcher/Slot/EnergySite/SiteRoot/Spatial/SpriteShadow")
export (NodePath)onready var gradient = get_node(gradient)
export (NodePath)onready var sun_object = get_node(sun_object)
export (NodePath)onready var stars = get_node(stars)
export (NodePath)onready var moon = get_node(moon)
onready var energy_site = find_parent("EnergySite*")

func _ready():
	if night_controller_node != null:
		night_controller_node.connect("is_night", self, "set_night")
		
	if energy_site == null: return
	energy_site.connect("on_energy_site_update", self, "update_weather")
	update_weather(energy_site.data)

func update_weather(data: EnergySiteData):
	if data == null: return
	var weather = data.energy_site_summary.weather
	if weather == null: return
	var is_night = weather.get("is_night")
	var cloud_factor = weather.get("cloud_factor")
	if is_night != null: show_night(is_night, cloud_factor)
	else: show_night(false, null)
		
func set_night(is_night):
	show_night(is_night, null)

func show_night(is_night, cloud_factor):
	
	print("IS night??? ", is_night)
	if is_night:
		moon.visible = true
		stars.visible = true
		






	else:
		moon.visible = false
		stars.visible = false

func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
