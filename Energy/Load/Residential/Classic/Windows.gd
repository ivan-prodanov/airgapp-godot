extends MeshInstance

onready var energy_site = find_parent("EnergySite*")
onready var slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/DaySlider")

func _ready():
	if energy_site == null: return
	if slider_node != null:
		slider_node.connect("update_time_of_day", self, "_on_time_of_day_change")

	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)

func get_material():
	return get_surface_material(0)

func update(data: EnergySiteData):
	if data == null: return
	
	var grid_component = data.get_grid_component()
	if grid_component == null: return

	var battery_component = data.get_battery_component()
	var vehicle_component = data.get_vehicle_component()

	var properties = grid_component.get("properties", null)
	if properties == null: return
	
	var island_status = properties.get("islandStatus", null)
	if island_status == null: return
	
	var weather = data.energy_site_summary.weather
	if weather == null: return
	var time_of_day = weather.get("time_of_day")
	if time_of_day != null: _on_time_of_day_change(time_of_day)
	
	var brightness = 1.0
	var night_light_power = 1
	var intensity = 1.0

	var island_status_upper = island_status.to_upper()
	
	match island_status_upper:
		"OFF_GRID_UNINTENTIONAL_WAIT_FOR_SOLAR", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_JUMP_START", "OFF_GRID_UNINTENTIONAL_OVERLOAD", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER_MANUAL_BACKUP", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER_LOW_SOE", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER_NO_INVERTERS_READY", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER_RETRIES_EXHAUSTED":
			brightness = 0.1
			night_light_power = 0
			intensity = 0

	if battery_component != null:
		var battery_visible = battery_component.get("visible", true)
		if battery_visible == false and island_status_upper == "OFF_GRID_UNINTENTIONAL":
			
			brightness = 0.1
			night_light_power = 0
			intensity = 0

			if vehicle_component != null:
				var vehicle_properties = vehicle_component.get("properties", null)
				if vehicle_properties != null:
					var vehicle_direction = vehicle_properties.get("direction", null)
					
					if vehicle_direction == 1:
						brightness = 0.8
						night_light_power = 1
						intensity = 1.0

	
	get_material().set_shader_param("brightness", brightness)
	get_material().set_shader_param("night_light_power", night_light_power)
	get_material().set_shader_param("intensity", intensity)

func _on_time_of_day_change(value):
	if value > 50:
		var remapped_value = remap_value(value, 50.0, 100.0, 1.0, 0.0)
		self.get_surface_material(0).set_shader_param("day_factor", remapped_value)
	else:
		var remapped_value = remap_value(value, 0.0, 50.0, 0.0, 1.0)
		self.get_surface_material(0).set_shader_param("day_factor", remapped_value)
	
func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
