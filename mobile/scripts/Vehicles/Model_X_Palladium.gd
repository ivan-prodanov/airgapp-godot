tool 
extends "Palladium.gd"
class_name Model_X_Palladium

enum SeatCount{
	Seats_5 = 5, 
	Seats_6 = 6, 
	Seats_7 = 7, 
}

export (SeatCount) var seat_count setget set_seat_count

export (NodePath) var interior_5_seater_path: NodePath
export (NodePath) var interior_6_seater_left_path: NodePath
export (NodePath) var interior_6_seater_center_path: NodePath
export (NodePath) var interior_6_seater_right_path: NodePath
export (NodePath) var interior_7_seater_path: NodePath
export (NodePath) var interior_5_seater_extras_path: NodePath
export (NodePath) var interior_6_seater_extras_left_path: NodePath
export (NodePath) var interior_6_seater_extras_center_path: NodePath
export (NodePath) var interior_6_seater_extras_right_path: NodePath
export (NodePath) var interior_7_seater_extras_path: NodePath

onready var interior_5_seater: MeshInstance = get_node(interior_5_seater_path)

onready var interior_6_seater_left: MeshInstance = get_node(interior_6_seater_left_path)
onready var interior_6_seater_center: MeshInstance = get_node(interior_6_seater_center_path)
onready var interior_6_seater_right: MeshInstance = get_node(interior_6_seater_right_path)

onready var interior_7_seater: MeshInstance = get_node(interior_7_seater_path)
onready var interior_5_seater_extras: MeshInstance = get_node(interior_5_seater_extras_path)

onready var interior_6_seater_extras_left: MeshInstance = get_node(interior_6_seater_extras_left_path)
onready var interior_6_seater_extras_center: MeshInstance = get_node(interior_6_seater_extras_center_path)
onready var interior_6_seater_extras_right: MeshInstance = get_node(interior_6_seater_extras_right_path)

onready var interior_7_seater_extras: MeshInstance = get_node(interior_7_seater_extras_path)

onready var lr_door_top_animation: AnimationPlayer = get_node("LRDoorAnimationTop")
onready var rr_door_top_animation: AnimationPlayer = get_node("RRDoorAnimationTop")

func get_roof_fade_resource_names():
	return .get_roof_fade_resource_names() + ["Zero_Black_Fade", "Plastic_Black_Glossy_Fade", "Plastic_Black_Glossy"]

func set_default_state(animated: bool = false):
	.set_default_state(animated)
	set_has_spoiler(true)

func update(data: VehicleData, animated: bool = false, speed: float = 1.0):
	.update(data, animated, speed)
	set_has_spoiler(true)
	setup_seat_config(data)
	
func set_seat_count(count: int):
	seat_count = count
	
	set_node_visible(interior_5_seater, count == SeatCount.Seats_5)
	set_node_visible(interior_6_seater_left, count == SeatCount.Seats_6)
	set_node_visible(interior_6_seater_center, count == SeatCount.Seats_6)
	set_node_visible(interior_6_seater_right, count == SeatCount.Seats_6)
	set_node_visible(interior_7_seater, count == SeatCount.Seats_7)

	set_node_visible(interior_5_seater_extras, count == SeatCount.Seats_5)
	set_node_visible(interior_6_seater_extras_left, count == SeatCount.Seats_6)
	set_node_visible(interior_6_seater_extras_center, count == SeatCount.Seats_6)
	set_node_visible(interior_6_seater_extras_right, count == SeatCount.Seats_6)
	set_node_visible(interior_7_seater_extras, count == SeatCount.Seats_7)

func setup_seat_config(data: VehicleData):
	var has_3_rows = data.vehicle_config.third_row_seats != VehicleData.ThirdRowSeatType.NONE or data.vehicle_config.rear_seat_type == VehicleData.RearSeatType.EXECUTIVE
	
	if not has_3_rows:
		set_seat_count(SeatCount.Seats_5)
	else:
		if data.vehicle_config.rear_seat_type == VehicleData.RearSeatType.TWO_SEAT or data.vehicle_config.rear_seat_type == VehicleData.RearSeatType.EXECUTIVE or data.vehicle_config.rear_seat_type == null:
			set_seat_count(SeatCount.Seats_6)
		else:
			set_seat_count(SeatCount.Seats_7)
			
func set_lr_door_open(open, animated = false, speed: float = 1.0):
	if lr_door_open == open: return
	lr_door_open = open
	toggle_open(lr_door_top_animation, open, animated, speed)

func set_rr_door_open(open, animated = false, speed: float = 1.0):
	if rr_door_open == open: return
	rr_door_open = open
	toggle_open(rr_door_top_animation, open, animated, speed)

func get_skin_file_path(skin_name):
	return "res://" + local_dir + "/Textures/Skins/" + skin_name + ".png"

func set_interior_config(interior):
	if local_dir == null or local_dir == "": return
	
	var mat: SpatialMaterial
	match (interior):
		VehicleOptions.InteriorConfig.White, VehicleOptions.InteriorConfig.White2, VehicleOptions.InteriorConfig.WhiteCarbonFiber:
			mat = load("res://" + local_dir + "/Interior_Seats_White.material");
		VehicleOptions.InteriorConfig.Black, VehicleOptions.InteriorConfig.Black2, VehicleOptions.InteriorConfig.BlackCarbonFiber:
			mat = load("res://" + local_dir + "/Interior_Seats_Black.material");
		VehicleOptions.InteriorConfig.Cream, VehicleOptions.InteriorConfig.CreamCarbonFiber:
			mat = load("res://" + local_dir + "/Interior_Seats_Cream.material")
	if not mat: return ;
	apply_material(self, mat, "InteriorSeats");
	
	.set_interior_config(interior)
