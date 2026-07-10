extends Node



export (NodePath) var cable_stowed_path = ""
export (NodePath) var cable_path = ""

onready var cable_stowed = get_node_or_null(cable_stowed_path)
onready var cable = get_node_or_null(cable_path)

export (NodePath) var vehicle_garage_manager_path = ""
onready var vehicle_garage_manager = get_node_or_null(vehicle_garage_manager_path)

func _ready():
	process_priority = 10

	if vehicle_garage_manager != null:
		vehicle_garage_manager.connect("vehicle_1_plugged_in_change", self, "on_vehicle_1_plugged_in_change")
		on_vehicle_1_plugged_in_change(vehicle_garage_manager.shown, false)
		
		vehicle_garage_manager.connect("vehicle_2_plugged_in_change", self, "on_vehicle_2_plugged_in_change")
		on_vehicle_2_plugged_in_change(vehicle_garage_manager.shown, false)

func on_vehicle_1_plugged_in_change(plugged_in: bool, animate: bool):
	if cable != null: cable.visible = plugged_in
	if cable_stowed != null: cable_stowed.visible = not plugged_in
	
func on_vehicle_2_plugged_in_change(plugged_in: bool, animate: bool):
	if cable != null: cable.visible = plugged_in
	if cable_stowed != null: cable_stowed.visible = not plugged_in
