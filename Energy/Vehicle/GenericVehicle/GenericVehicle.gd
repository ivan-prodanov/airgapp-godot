extends Spatial




var vehicle_id: String

export (NodePath) var charge_port_path: String
onready var charge_port = get_node(charge_port_path)

func update(data: VehicleData):
	vehicle_id = data.get("id")
	
func set_charge_port_open(open, animated):
	pass
	
func set_reverse_lights_on(on):
	pass
	
func set_brake_lights_on(on):
	pass
