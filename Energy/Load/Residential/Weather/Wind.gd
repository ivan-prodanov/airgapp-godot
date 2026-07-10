extends CPUParticles

export (NodePath)onready var fog = get_node(fog)
onready var energy_site = find_parent("EnergySite*")
onready var max_wind_particles = 33.0
onready var wind_slider_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/WindSlider")

func _ready():
	if energy_site == null: return
	energy_site.connect("on_energy_site_update", self, "update_weather")
	update_weather(energy_site.data)
	
	if wind_slider_node != null:
		wind_slider_node.connect("update_wind_amount", self, "on_update_wind_amount")

func update_weather(data: EnergySiteData):
	if data == null: return
	var weather = data.energy_site_summary.weather
	if weather == null: return
	var wind_speed = weather.get("wind_speed")
	if wind_speed != null: on_update_wind_amount(wind_speed)
	
func on_update_wind_amount(wind_speed):
	if fog == null: return
	var fog_speed = clamp(remap_value(wind_speed, 50.0, 85.0, - 0.026, - 0.033), - 0.4, 0)
	fog.gravity.x = fog_speed
	
	if wind_speed == null: return
	var wind_alpha = clamp(remap_value(wind_speed, 60.0, 85.0, 0.5, 1.0), 0.0, 1.0)
	wind_speed = clamp(remap_value(wind_speed, 50.0, 85.0, 15.0, max_wind_particles), 0.0, max_wind_particles)
	self.amount = wind_speed
	if wind_speed > 0.1:
		self.visible = true
		self.emitting = true
	else:
		self.visible = false
		self.emitting = false
	self.get_material_override().set_shader_param("alpha_factor", wind_alpha)
	
func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
