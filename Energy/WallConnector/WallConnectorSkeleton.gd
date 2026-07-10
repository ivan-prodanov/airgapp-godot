extends Skeleton



export (NodePath) var vehicle_garage_manager_path = ""
onready var vehicle_garage_manager = get_node_or_null(vehicle_garage_manager_path)

var charge_port_node: Spatial

var end_bone_name: String = "end"


func _ready():
	if vehicle_garage_manager != null:
		
		vehicle_garage_manager.connect("vehicle_charge_port_node_change", self, "on_vehicle_charge_port_node_change")
		
func on_vehicle_charge_port_node_change(spatial: Spatial):
	charge_port_node = spatial
	update_charge_port_end()

func update_charge_port_end():
	if charge_port_node == null: return
	var skel = self
	var bone_id = skel.find_bone(end_bone_name)
	skel.set_bone_disable_rest(bone_id, true)
	
	var t = skel.get_bone_rest(bone_id)
	t.origin = skel.global_transform.xform_inv(charge_port_node.global_transform.origin)
	
	skel.set_bone_pose(bone_id, t)
