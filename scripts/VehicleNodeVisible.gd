tool 
extends Spatial
class_name VehicleNodeVisible

export (String, "vehicle_lights_changed") var event_type = "vehicle_lights_changed"




func _ready():
	var vehicle = find_parent("ROOT")
	if vehicle == null: return

	vehicle.connect(event_type, self, "update_visibility")

	update_visibility(vehicle)

func update_visibility(vehicle: Vehicle):
	if vehicle == null: return

	if should_be_visible(vehicle):
		show()
	else:
		hide()


func should_be_visible(_vehicle: Vehicle):
	return false
	