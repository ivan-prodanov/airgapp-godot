extends MeshInstance


class_name EnergySitePowerflowWireDisplay

class Wire:
	var direction = PowerflowDisplay.Direction.FLOW_OUT

	
	var source = EnergySiteData.Component.BATTERY

	var wire_color_override = ""

	
	func _init(in_direction = PowerflowDisplay.Direction.IDLE, in_source = EnergySiteData.Component.BATTERY, in_wire_color_override = ""):
		direction = in_direction
		source = in_source
		wire_color_override = in_wire_color_override






export (float, - 100.0, 100.0) var phase_offset = 0.0

var wire = Wire.new()

var base_color = Color8(56, 56, 56, 255)



const DEFAULT_WIRE_COLORS = {
	2: Color("#ffc107"), 
	3: Color("#00E286"), 
	4: Color("#aaaaaa"), 
	5: Color("#aaaaaa"), 
	6: Color("#aaaaaa"), 
	7: Color("#00E286"), 
	8: Color("#00E286"), 
	9: Color("#aaaaaa"), 
}


var powerflow_offset = - 1


export var wire_terminate_at = 1000

func _ready():
	make_material_unique()
	
	var material = get_material()
	
	material.set_shader_param("base_color", base_color)
	material.set_shader_param("flow_color", get_wire_color())

	var energy_site = find_parent("EnergySite*")

	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)

func update(data: EnergySiteData):
	powerflow_offset = data.energy_site_config.eng_settings.get("powerflowOffset", - 1)
	
func make_material_unique():
	set_surface_material(0, get_material().duplicate())

func get_material():
	return get_surface_material(0)

func get_wire_color():
	if wire.wire_color_override != "":
		return Color(wire.wire_color_override)
	
	return DEFAULT_WIRE_COLORS[wire.source]

func _process(_delta):
	var time = fmod(OS.get_ticks_msec() / 1000.0, get_material().get_shader_param("pulse_frequency"))
	
	if powerflow_offset >= 0:
		time = powerflow_offset * get_material().get_shader_param("pulse_frequency")
		
	var material = get_material()
	material.set_shader_param("current_time", time)
	material.set_shader_param("powerflow_state", wire.direction)
	material.set_shader_param("flow_color", get_wire_color())
	material.set_shader_param("phase_offset", phase_offset if wire.direction < 0 else - phase_offset)
	material.set_shader_param("wire_terminate_at", wire_terminate_at)
