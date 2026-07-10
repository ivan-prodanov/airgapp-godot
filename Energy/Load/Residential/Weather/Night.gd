extends MeshInstance


export (NodePath)onready var moon = get_node(moon)
export var phase = 0.3
onready var is_crescent = true
onready var energy_site = find_parent("EnergySite*")

var is_rainbow_active = false
var rainbow_time = 0.0
export var rainbow_speed = 1.0
var original_star_color: Color

func _ready():
	if energy_site == null: return
	energy_site.connect("on_energy_site_update", self, "update_weather")
	update_weather(energy_site.data)



func update_weather(data: EnergySiteData):
	if data == null or data.energy_site_summary == null or data.energy_site_summary.weather == null: return
	var moon_phase = data.energy_site_summary.weather.get("moon_phase")
	if moon_phase != null: set_moon_phase(moon_phase)
	
func set_moon_phase(moon_phase):
	if moon:
		var remapped_phase = 0.0
		if moon_phase <= 0.25:
			
			remapped_phase = remap_value(moon_phase, 0.0, 0.25, 0.0, 0.5)
			is_crescent = true
		elif moon_phase > 0.75:
			
			remapped_phase = remap_value(moon_phase, 0.75, 1.0, 0.5, 1.0)
			is_crescent = true
		elif moon_phase > 0.25 and moon_phase < 0.5:
			
			remapped_phase = remap_value(moon_phase, 0.25, 0.5, 0.5, 1.0)
			is_crescent = false
		else:
			
			remapped_phase = remap_value(moon_phase, 0.5, 0.75, 0.0, 0.5)
			is_crescent = false
		remapped_phase = 1.0 - remapped_phase
		
		moon.get_surface_material(0).set_shader_param("phase", remapped_phase)
		moon.get_surface_material(0).set_shader_param("is_crescent", is_crescent)
		














































		
func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
