tool 
extends "res://mobile/scripts/Vehicles/Model_3.gd"

export (bool) var has_stalk setget set_has_stalk
export (bool) var has_fascia_cam setget set_has_fascia_cam
export (bool) var has_rear_display setget set_has_rear_display

export (NodePath) var turn_signal_rear_l_path: NodePath
export (NodePath) var turn_signal_rear_r_path: NodePath
export (NodePath) var rear_seats_path: NodePath
export (NodePath) var doorcard_lf_path: NodePath
export (NodePath) var doorcard_lf_rhd_path: NodePath
export (NodePath) var doorcard_rf_path: NodePath
export (NodePath) var doorcard_rf_rhd_path: NodePath
export (NodePath) var stalk_path: NodePath
export (NodePath) var stalk_rhd_path: NodePath
export (NodePath) var center_console_path: NodePath
export (NodePath) var center_console_no_display_path: NodePath
export (NodePath) var fascia_cam_path: NodePath
export (NodePath) var seat_buttom_lf_path: NodePath
export (NodePath) var seat_buttom_rf_path: NodePath
export (NodePath) var seat_buttom_d50_lf_path: NodePath
export (NodePath) var seat_buttom_d50_rf_path: NodePath
export (NodePath) var tweeter_lf_path: NodePath
export (NodePath) var tweeter_rf_path: NodePath
export (NodePath) var sill_plate_path: NodePath

export (Array, NodePath) var bumper_base_paths
export (Array, NodePath) var bumper_perf_paths

export (Array, NodePath) var seat_base_paths
export (Array, NodePath) var seat_perf_paths

onready var turn_signal_rear_l: MeshInstance = get_node_or_null(turn_signal_rear_l_path)
onready var turn_signal_rear_r: MeshInstance = get_node_or_null(turn_signal_rear_r_path)
onready var rear_seats: MeshInstance = get_node_or_null(rear_seats_path)
onready var doorcard_lf: MeshInstance = get_node_or_null(doorcard_lf_path)
onready var doorcard_lf_rhd: MeshInstance = get_node_or_null(doorcard_lf_rhd_path)
onready var doorcard_rf: MeshInstance = get_node_or_null(doorcard_rf_path)
onready var doorcard_rf_rhd: MeshInstance = get_node_or_null(doorcard_rf_rhd_path)
onready var stalk: MeshInstance = get_node_or_null(stalk_path)
onready var stalk_rhd: MeshInstance = get_node_or_null(stalk_rhd_path)
onready var center_console: MeshInstance = get_node_or_null(center_console_path)
onready var center_console_no_display: MeshInstance = get_node_or_null(center_console_no_display_path)
onready var fascia_cam: MeshInstance = get_node_or_null(fascia_cam_path)
onready var seat_buttom_lf: MeshInstance = get_node_or_null(seat_buttom_lf_path)
onready var seat_buttom_rf: MeshInstance = get_node_or_null(seat_buttom_rf_path)
onready var seat_buttom_d50_lf: MeshInstance = get_node_or_null(seat_buttom_d50_lf_path)
onready var seat_buttom_d50_rf: MeshInstance = get_node_or_null(seat_buttom_d50_rf_path)
onready var tweeter_lf: MeshInstance = get_node_or_null(tweeter_lf_path)
onready var tweeter_rf: MeshInstance = get_node_or_null(tweeter_rf_path)
onready var sill_plate: MeshInstance = get_node_or_null(sill_plate_path)

var bumpers_base: Array
var bumpers_perf: Array
var seats_base: Array
var seats_perf: Array

func _enter_tree():
	interior_upper_trim_materials = {
		VehicleOptions.InteriorUpperTrimType.BLACK: ["Upper_Trim_Black_Fade.tres", "Upper_Trim_Black.tres", "Upper_Trim_Plastic_Black.tres"], 
		VehicleOptions.InteriorUpperTrimType.GREY: ["Upper_Trim_Grey_Fade.tres", "Upper_Trim_Grey.tres", "Upper_Trim_Plastic_Grey.tres"]
	}
	self.interior_upper_trim_type = VehicleOptions.InteriorUpperTrimType.GREY
	self.badging_material_type = VehicleOptions.BadgingMaterialType.CHROME_SILVER
	._enter_tree()

func _ready():
	for base_bumper_path in bumper_base_paths:
		bumpers_base.append(get_node_or_null(base_bumper_path))

	for perf_bumper_path in bumper_perf_paths:
		bumpers_perf.append(get_node_or_null(perf_bumper_path))

	for base_seat_path in seat_base_paths:
		seats_base.append(get_node_or_null(base_seat_path))

	for perf_seat_path in seat_perf_paths:
		seats_perf.append(get_node_or_null(perf_seat_path))

func get_roof_fade_resource_names():
	return ["Exterior_Fade", 
			"Interior_Fade", 
			"Glass_Fade", 
			"Glass_Tinted_Fade", 
			"Glass_Interior_Fade", 
			"GlassFadeSkybox", 
			"GlassTintedFadeSkybox", 
			"Glass_Interior_Tinted_Fade", 
			"Plastic_Black_Fade", 
			"Plastic_White_Fade", 
			"Plastic_Graphite_Fade", 
			"Fabric_Black_Fade", 
			"Fabric_Grey_Dark_Fade", 
			"Upper_Trim_Fade", 
			"Mirror_Fade", 
			"Chrome_Fade"]
	
func set_is_performance(is_perf):
	
	for base_bumper in bumpers_base:
		set_node_visible(base_bumper, not is_perf)

	for base_seat in seats_base:
		set_node_visible(base_seat, not is_perf)

	
	for perf_bumper in bumpers_perf:
		set_node_visible(perf_bumper, is_perf)

	for perf_seat in seats_perf:
		set_node_visible(perf_seat, is_perf)

	set_has_spoiler(is_perf)

	
	set_interior_config(interior_config)
	
func set_has_stalk(stalk_on):
	has_stalk = stalk_on;
	
	if RHD:
		set_node_visible(stalk_rhd, stalk_on);
	else:
		set_node_visible(stalk, stalk_on);
		
func set_has_fascia_cam(has_cam):
	has_fascia_cam = has_cam
	set_node_visible(fascia_cam, has_cam)

func set_has_rear_display(has_display):
	has_rear_display = has_display
	set_node_visible(center_console, has_display)
	set_node_visible(center_console_no_display, not has_display)

func set_exterior_trim_str(trim: String):
	var value = ExteriorTrimMap.get(trim, ExteriorTrim.Original)
	set_exterior_trim(value)

func set_fascia_type(type):
	.set_fascia_type(type)
	
	set_is_performance(type == VehicleOptions.FasciaType.POPPYSEED_PERF)
	set_interior_config(interior_config)
	set_has_rear_display(type != VehicleOptions.FasciaType.POPPYSEED_D50)
	
	
	var is_d50: bool = (fascia_type == VehicleOptions.FasciaType.POPPYSEED_D50)
	set_node_visible(seat_buttom_lf, not is_d50)
	set_node_visible(seat_buttom_rf, not is_d50)
	set_node_visible(seat_buttom_d50_lf, is_d50)
	set_node_visible(seat_buttom_d50_rf, is_d50)
	set_node_visible(tweeter_lf, not is_d50)
	set_node_visible(tweeter_rf, not is_d50)
	set_node_visible(sill_plate, not is_d50)

func set_interior_config(interior):
	interior_config = interior;
	
	var seats_mat: SpatialMaterial
	var seats_mat_perf: SpatialMaterial
	var decor_mat: SpatialMaterial
	var decor_mat_perf: SpatialMaterial

	var is_d50: bool = (fascia_type == VehicleOptions.FasciaType.POPPYSEED_D50)
	if is_d50:
		decor_mat = load("res://" + local_dir + "/Decor_Textile.material")
		seats_mat = load("res://" + local_dir + "/Interior_Seats_Textile.material")
	elif interior == VehicleOptions.InteriorConfig.White or \
	interior == VehicleOptions.InteriorConfig.White2:
		decor_mat = load("res://" + local_dir + "/Decor_White.material")
		decor_mat_perf = decor_mat
		seats_mat = load("res://" + local_dir + "/Interior_Seats_White.material")
		seats_mat_perf = load("res://" + local_dir + "/Interior_Seats_Perf_White.material")
	elif interior == VehicleOptions.InteriorConfig.Black or \
	interior == VehicleOptions.InteriorConfig.Black2:
		decor_mat = load("res://" + local_dir + "/Decor_Black.material")
		decor_mat_perf = decor_mat
		seats_mat = load("res://" + local_dir + "/Interior_Seats_Black.material")
		seats_mat_perf = load("res://" + local_dir + "/Interior_Seats_Perf_Black.material")

	if fascia_type == VehicleOptions.FasciaType.POPPYSEED_PERF:
		if seats_mat_perf: apply_material(self, seats_mat_perf, "InteriorSeats", true)
		if decor_mat_perf: apply_material(self, decor_mat_perf, "Decor", true)
		if seats_mat: apply_material(rear_seats, seats_mat, "InteriorSeats", true)
	else:
		if seats_mat: apply_material(self, seats_mat, "InteriorSeats", true)
		if decor_mat: apply_material(self, decor_mat, "Decor", true)
	
func set_rhd(is_rhd):
	.set_rhd(is_rhd)
	
	set_node_visible(lhd_steering_wheel, not is_rhd)
	set_node_visible(rhd_steering_wheel, is_rhd)
	set_node_visible(lhd_dashboard, not is_rhd)
	set_node_visible(rhd_dashboard, is_rhd)
	set_node_visible(lhd_screen, not is_rhd)
	set_node_visible(rhd_screen, is_rhd)
	set_node_visible(doorcard_lf, not is_rhd)
	set_node_visible(doorcard_lf_rhd, is_rhd)
	set_node_visible(doorcard_rf, not is_rhd)
	set_node_visible(doorcard_rf_rhd, is_rhd)
	set_node_visible(stalk, not is_rhd and has_stalk)
	set_node_visible(stalk_rhd, is_rhd and has_stalk)


func set_exterior_trim(trim: int):
	if trim == exterior_trim: return
	exterior_trim = trim
	print("set_exterior_trim: " + String(trim))

	var material: SpatialMaterial
	match (trim):
		ExteriorTrim.Original:
			material = load("res://" + local_dir + "/Exterior.material")
		ExteriorTrim.Black:
			material = load("res://" + local_dir + "/Exterior_Hydroxide.material")
	if material == null: return

	material = material.duplicate()
	apply_material(self, material, "Exterior")

func set_headlamp_type(type: int):
	headlamp_type = type


func set_fog_lights_on(on):
	fog_lights_on = on
	var is_global = headlamp_type == VehicleOptions.HeadlampType.Global
	
	set_node_visible(fog_lights, not is_global and on)
	
	set_node_visible(fog_lights_global, is_global and on)
	set_node_visible(fog_rear_lights_global, is_global and on)

func set_reverse_lights_on(on):
	reverse_lights_on = on
	var is_global = headlamp_type == VehicleOptions.HeadlampType.Global
	
	set_node_visible(reverse_lights, not is_global and on)
	
	set_node_visible(reverse_lights_global, is_global and on)

func set_turn_signal_r_state(state: int):
	turn_signal_r_state = state
	var on: bool = state == 1
	set_node_visible(turn_signal_r, on)
	set_node_visible(turn_signal_rear_r, on)
	
func set_turn_signal_l_state(state: int):
	turn_signal_l_state = state
	var on: bool = state == 1
	set_node_visible(turn_signal_l, on)
	set_node_visible(turn_signal_rear_l, on)
	
func set_drl_on(on):
	drl_on = on
	set_node_visible(drl, on)
	
func set_headlights_on(on):
	headlights_on = on
	set_node_visible(headlights, on)
	set_node_visible(headlights_trunk_original, on)
	set_drl_on(on)

func set_brake_lights_on(on: bool):
	brake_lights_on = on
	set_node_visible(brake_lights_center, on)
	set_node_visible(brake_lights_l, on)
	set_node_visible(brake_lights_r, on)

func update(data: VehicleData, animated: bool = false, speed: float = 1.0):
	.update(data, animated, speed)
	var trim = data.vehicle_config.exterior_trim
	if ( not data.vehicle_config.exterior_trim_override.empty()):
		trim = data.vehicle_config.exterior_trim_override
	set_exterior_trim_str(trim)
	set_headlamp_type(VehicleOptions.HeadlampType.Global if data.hasGlobalHeadlamp() else VehicleOptions.HeadlampType.Original)
	set_node_visible(fog_lights_cover, not data.hasFogLamps())
	set_has_stalk(data.vehicle_config.has_stalk)
	set_has_fascia_cam(data.vehicle_config.has_front_fascia_camera)

	
func get_skin_file_path(skin_name):
	if fascia_type == VehicleOptions.FasciaType.POPPYSEED_PERF:
		return "res://" + local_dir + "/Textures/Skins/Performance/" + skin_name + ".png"
	else:
		return "res://" + local_dir + "/Textures/Skins/Base/" + skin_name + ".png"

	return .get_skin_file_path(skin_name)
