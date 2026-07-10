extends MeshInstance

onready var time_of_day = 99.9
onready var previous_time_of_day = 100
onready var cloud_albedo = Color(0.5, 0.5, 0.5, 1.0)
onready var TOD_albedo = 0.5
onready var is_night_time = false

onready var energy_site = find_parent("EnergySite*")
export (NodePath)onready var garage_door = get_node_or_null(garage_door)
export (NodePath)onready var window = get_node_or_null(window)
export (NodePath)onready var ground_reflection = get_node(ground_reflection)
export (NodePath)onready var terrain = get_node_or_null(terrain)
onready var cloud_slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/CloudSlider")
onready var day_slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/DaySlider")


onready var shading_values = {
	"Classic": {
		"light": 0.83, 
		"dark": 0.45, 
		"threshold": 0.6, 
		"garage_door_offset": 0.27
	}, 
	"Compound": {
		"light": 0.5, 
		"dark": 0.23, 
		"threshold": 0.4, 
		"garage_door_offset": 0.27
	}, 
	"Powershare": {
		"light": 0.5, 
		"dark": 0.3, 
		"threshold": 0.37, 
		"garage_door_offset": 0.0
	}
}


onready var current_shading_light = 0.83
onready var current_shading_dark = 0.45
onready var current_threshold = 0.6
onready var current_garage_door_offset = 0.27

onready var sunny_window_albedo = Color(0.45, 0.46, 0.49, 1.0)
onready var dark_window_albedo = Color(1.0, 0.98, 0.93, 1.0)
onready var terrain_light = 0.32
onready var terrain_dark = 0.2

onready var variant_key = "Classic"

func _ready():
	if energy_site == null: return
	
	set_shading_values_for_variant()
	
	energy_site.connect("on_energy_site_update", self, "update_weather")
	update_weather(energy_site.data)
	if cloud_slider_node != null: cloud_slider_node.connect("update_cloud_cover", self, "_on_update_cloud_cover")
	if day_slider_node != null: day_slider_node.connect("update_cloud_cover", self, "_on_update_cloud_cover")

func set_shading_values_for_variant():
	var site_variant = energy_site.data.get_site_variant()
	variant_key = "Classic"
	
	if site_variant == EnergySiteData.EnergySiteType.RESIDENTIAL_COMPOUND:
		variant_key = "Compound"
	elif site_variant == EnergySiteData.EnergySiteType.RESIDENTIAL_POWERSHARE:
		variant_key = "Powershare"
	
	
	current_shading_light = shading_values[variant_key]["light"]
	current_shading_dark = shading_values[variant_key]["dark"]
	current_threshold = shading_values[variant_key]["threshold"]
	current_garage_door_offset = shading_values[variant_key]["garage_door_offset"]
	
func update_weather(data: EnergySiteData):
	if data == null: return
	var weather = data.energy_site_summary.weather
	if weather == null: return
	time_of_day = weather.get("time_of_day")
	var cloud_factor = weather.get("cloud_factor")
	var is_night = weather.get("is_night")
	if time_of_day != null: _on_time_of_day_change(time_of_day)
	if cloud_factor != null: _on_update_cloud_cover(cloud_factor)
	if is_night != null: _on_is_night(is_night)

func _on_time_of_day_change(value):
	if value > 50:
		TOD_albedo = clamp(remap_value(value, 70, 100, current_shading_light, current_shading_dark), 0.0, 1.0)
	elif value <= 50:
		TOD_albedo = clamp(remap_value(value, 0, 30, current_shading_dark, current_shading_light), 0.0, 1.0)
		
func _on_update_cloud_cover(value):
	var shine_factor = remap_value(value, 0, 100, 1, 0)
	cloud_albedo = clamp(remap_value(value, 30, 100, current_shading_light, current_shading_dark), 0.0, 1.0)
	self.get_surface_material(0).set_shader_param("shine_factor", min(shine_factor, cloud_albedo))
	set_final_home_albedo()
	
func set_final_home_albedo():
	if cloud_albedo == null or TOD_albedo == null: return
		
	var final_albedo = min(cloud_albedo, TOD_albedo)
	self.get_surface_material(0).set_shader_param("albedo_dark", Color(final_albedo, final_albedo, final_albedo, 1.0))
	
	
	if is_night_time:
		garage_door.get_surface_material(0).set_shader_param("albedo_dark", Color(current_shading_dark - current_garage_door_offset, current_shading_dark - current_garage_door_offset, current_shading_dark - current_garage_door_offset, 1.0))
		window.get_surface_material(0).set_shader_param("glow_color", dark_window_albedo)
		ground_reflection.get_surface_material(0).set_shader_param("alpha", 1.0)
		terrain.get_surface_material(0).set_shader_param("albedo", Color(terrain_dark, terrain_dark, terrain_dark, 1.0))
		return
	
	var garage_color = max(final_albedo * 0.4, 0.18)
	if variant_key == "Powershare":
		garage_color = final_albedo
	
	
	
	
	
	if final_albedo < current_threshold:
		window.get_surface_material(0).set_shader_param("glow_color", dark_window_albedo)
		ground_reflection.get_surface_material(0).set_shader_param("alpha", 1.0)
		terrain.get_surface_material(0).set_shader_param("albedo", Color(terrain_dark, terrain_dark, terrain_dark, 1.0))
		garage_door.get_surface_material(0).set_shader_param("albedo_dark", Color(garage_color, garage_color, garage_color, 1.0))
	else:
		window.get_surface_material(0).set_shader_param("glow_color", sunny_window_albedo)
		ground_reflection.get_surface_material(0).set_shader_param("alpha", 0.2)
		terrain.get_surface_material(0).set_shader_param("albedo", Color(terrain_light, terrain_light, terrain_light, 1.0))
		garage_door.get_surface_material(0).set_shader_param("albedo_dark", Color(garage_color, garage_color, garage_color, 1.0))

func _on_is_night(is_night):
	is_night_time = is_night
	set_final_home_albedo()

func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
