extends MeshInstance
class_name PowerflowDisplay







onready var theme_manager = get_node_or_null("/root/Mobile/ThemeManager")

export (NodePath) var skeleton_path


var base_color_light = Color(0.8, 0.8, 0.8, 1.0)
var base_color_dark = Color8(56, 56, 56, 255)



export (float) var spw_solar_offset = 0.0;


var powerflow_offset = - 1.0;

enum Connection{
	BATTERY = 0, 
	SPW_BATTERY = 1, 

	LOAD = 3, 

	
	GRID = 4, 

	
	GENERATOR = 5, 

	
	GRID_WITH_GENERATOR = 6, 

	
	GENERATOR_WITH_GRID = 7, 

	SOLAR_PANEL = 8, 
	SOLAR_ROOF = 9, 

	SPW_SOLAR_PANEL = 10, 
	SPW_SOLAR_ROOF = 11, 

	
	VEHICLE_1 = 15, 
}

enum Direction{
	
	HIDDEN = 2, 

	
	IDLE = 0, 

	
	FLOW_OUT = - 1, 

	
	FLOW_IN = 1
}




var powerflow_config: Array = [
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
	Direction.HIDDEN, 
]

func _ready():
	process_priority = 15

	if theme_manager != null:
		theme_manager.connect("set_app_theme", self, "update_theme")
		update_theme(theme_manager.app_theme)

	make_material_unique()

	get_material().set_shader_param("spw_solar_offset", spw_solar_offset)

func make_material_unique():
	set_surface_material(0, get_material().duplicate())

func get_material():
	return get_surface_material(0)

func update_theme(theme):
	get_material().set_shader_param("base_color", base_color_light if theme == ThemeManager.ThemeType.LIGHT else base_color_dark)


func is_valid_connection(connection: int):
	return connection >= 0 and connection <= powerflow_config.size()

func set_all_path_direction(state: int):
	for index in powerflow_config.size():
		powerflow_config[index] = state



func set_path_direction(connection: int, direction: int):
	if not is_valid_connection(connection): return

	powerflow_config[connection] = direction


func get_powerflow_state(connection: int):
	if not is_valid_connection(connection): return Direction.HIDDEN

	return powerflow_config[connection]

func _process(_delta):
	update_powerflow_state()

	var time = fmod(OS.get_ticks_msec() / 1000.0, get_material().get_shader_param("pulse_frequency"))
	if powerflow_offset >= 0:
		time = powerflow_offset * get_material().get_shader_param("pulse_frequency")

	get_material().set_shader_param("current_time", time)


func update_powerflow_state():
	var material = get_material()

	for index in powerflow_config.size() / 2:
		material.set_shader_param("powerflow_state_%d" % index, 
			Vector2(get_powerflow_state(index * 2 + 0), get_powerflow_state(index * 2 + 1)))


