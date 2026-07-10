tool 
extends Vehicle
class_name Model_X

enum SeatCount{
	Seats_5 = 5, 
	Seats_6 = 6, 
	Seats_7 = 7, 
}

export (SeatCount) var seat_count setget set_seat_count

export (ExteriorTrim) var exterior_trim setget set_exterior_trim

export (NodePath) var interior_5_seater_path: NodePath
export (NodePath) var interior_6_seater_path: NodePath
export (NodePath) var interior_7_seater_path: NodePath

export (NodePath) var interior_5_seater_rhd_path: NodePath
export (NodePath) var interior_6_seater_rhd_path: NodePath
export (NodePath) var interior_7_seater_rhd_path: NodePath

onready var interior_5_seater: MeshInstance = get_node(interior_5_seater_path)
onready var interior_6_seater: MeshInstance = get_node(interior_6_seater_path)
onready var interior_7_seater: MeshInstance = get_node(interior_7_seater_path)

onready var interior_5_rhd_seater: MeshInstance = get_node(interior_5_seater_rhd_path)
onready var interior_6_rhd_seater: MeshInstance = get_node(interior_6_seater_rhd_path)
onready var interior_7_rhd_seater: MeshInstance = get_node(interior_7_seater_rhd_path)

onready var lr_door_top_animation: AnimationPlayer = get_node("LRDoorAnimationTop")
onready var rr_door_top_animation: AnimationPlayer = get_node("RRDoorAnimationTop")

func get_roof_fade_resource_names():
	return ["PaintFade", 
			"ExteriorFade", 
			"InteriorFade", 
			"Glass_Fade", 
			"Glass_Tinted_Fade", 
			"Glass_Interior_Fade", 
			"GlassFadeSkybox", 
			"GlassTintedFadeSkybox", 
			"Glass_Interior_Tinted_Fade"]



func set_default_state(animated: bool = false):
	.set_default_state(animated)
	set_has_spoiler(true)

func set_exterior_trim(trim: int):
	if trim == exterior_trim: return
	exterior_trim = trim
	print("set_exterior_trim: " + String(trim))

	var material: SpatialMaterial
	match (trim):
		ExteriorTrim.Original:
			material = load("res://" + local_dir + "/Exterior.material")
		ExteriorTrim.Black:
			material = load("res://" + local_dir + "/Exterior_Black_Trim_Colorizer.material")
	if material == null: return

	material = material.duplicate()
	apply_material(self, material, "Exterior")

func set_exterior_trim_str(trim: String):
	if trim.empty(): return
	var value = ExteriorTrimMap.get(trim, ExteriorTrim.Original)
	set_exterior_trim(value)

func update(data: VehicleData, animated: bool = false, speed: float = 1.0):
	.update(data, animated, speed)
	set_has_spoiler(true)
	setup_seat_config(data)
	set_exterior_trim_str(data.vehicle_config.exterior_trim_override)

func set_seat_count(count: int):
	seat_count = count
	
	set_node_visible(interior_5_seater, count == SeatCount.Seats_5 and not RHD)
	set_node_visible(interior_6_seater, count == SeatCount.Seats_6 and not RHD)
	set_node_visible(interior_7_seater, count == SeatCount.Seats_7 and not RHD)
	set_node_visible(interior_5_rhd_seater, count == SeatCount.Seats_5 and RHD)
	set_node_visible(interior_6_rhd_seater, count == SeatCount.Seats_6 and RHD)
	set_node_visible(interior_7_rhd_seater, count == SeatCount.Seats_7 and RHD)

func set_rhd(rhd):
	RHD = rhd
	set_seat_count(seat_count)

func setup_seat_config(data: VehicleData):
	var has_3_rows = data.vehicle_config.third_row_seats != VehicleData.ThirdRowSeatType.NONE
	
	if not has_3_rows:
		set_seat_count(SeatCount.Seats_5)
	else:
		if data.vehicle_config.rear_seat_type == VehicleData.RearSeatType.TWO_SEAT or data.vehicle_config.rear_seat_type == null:
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

func set_turn_signal_r_state(state: int):
	turn_signal_r_state = state
	set_node_visible(turn_signal_r, state == 1)
	
func set_turn_signal_l_state(state: int):
	turn_signal_l_state = state
	set_node_visible(turn_signal_l, state == 1)
