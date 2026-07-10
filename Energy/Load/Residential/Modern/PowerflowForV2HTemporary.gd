extends MeshInstance

var powerflow_offset = - 1
var solar_flow_color: Color
var vehicle_flow_color: Color
export var static_flow_color: Color
export var powerflow_state: int
export var UV_direction: int
export (float, - 100.0, 100.0) var phase_offset = 0.0
onready var vehicle_node = get_node_or_null("/root/Mobile/MainViewContainer/Viewport/root/ProductSwitcher/Slot/ROOT")
const WireDisplay = preload("res://Energy/Powerflow/Wire/WireDisplay.gd")
onready var tween = get_node_or_null("Tween")

func _ready():
	if vehicle_node != null:
		vehicle_node.connect("update_powershare_wires", self, "on_update_powershare_wires")
		
	solar_flow_color = EnergySitePowerflowWireDisplay.DEFAULT_WIRE_COLORS[EnergySiteData.Component.SOLAR]
	vehicle_flow_color = EnergySitePowerflowWireDisplay.DEFAULT_WIRE_COLORS[EnergySiteData.Component.VEHICLE_1]
	
func on_update_powershare_wires(charge_port_flow_state):
	match charge_port_flow_state:
		1:
			
			powerflow_state = - 1 * UV_direction
			self.get_surface_material(0).set_shader_param("flow_color", solar_flow_color)
		5:
			
			powerflow_state = 1 * UV_direction
			self.get_surface_material(0).set_shader_param("flow_color", vehicle_flow_color)
		_:
			powerflow_state = 0
			self.get_surface_material(0).set_shader_param("flow_color", static_flow_color)
	
func _process(_delta):
	var time = fmod(OS.get_ticks_msec() / 1000.0, get_surface_material(0).get_shader_param("pulse_frequency"))
	self.get_surface_material(0).set_shader_param("current_time", time)
	self.get_surface_material(0).set_shader_param("powerflow_state", powerflow_state)
