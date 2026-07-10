tool 
extends Spatial
class_name ChargeCable

onready var cable: MeshInstance = get_node("Chargeport_Connection_Spatial/Charger_Handle/Charger_Cable")
onready var shader_mat: ShaderMaterial = cable.get_surface_material(0)

export (String) var charge_port_color
export (VehicleData.VehicleChargeState.FlowState) var charge_port_flow_state

var frequency: float = 1.5

func _ready():
	shader_mat.set_shader_param("pulse_frequency", frequency)

func set_charging_state(state: VehicleData.VehicleChargeState):
	if state.charge_port_color == charge_port_color and state.charge_port_flow_state == charge_port_flow_state: return
	charge_port_color = state.charge_port_color
	charge_port_flow_state = state.charge_port_flow_state
	
	shader_mat.set_shader_param("current_time", 0)
		
	shader_mat.set_shader_param("flow_color", Color(charge_port_color))
	shader_mat.set_shader_param("flow_state", charge_port_flow_state)

func _process(delta):
	if charge_port_flow_state == VehicleData.VehicleChargeState.FlowState.Disabled: return

	var shader_time = shader_mat.get_shader_param("current_time")
	shader_mat.set_shader_param("current_time", fmod(shader_time + delta, frequency))
