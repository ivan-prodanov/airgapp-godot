tool 
extends "res://mobile/scripts/Vehicles/Model_Y.gd"

export (NodePath) var park_light_rear_path: NodePath
export (NodePath) var park_light_rear_projection_path: NodePath
export (NodePath) var turn_signal_rear_l_path: NodePath
export (NodePath) var turn_signal_rear_r_path: NodePath
export (NodePath) var headlight_beam_path: NodePath
export (NodePath) var doorcard_lf_path: NodePath
export (NodePath) var doorcard_lf_rhd_path: NodePath
export (NodePath) var doorcard_rf_path: NodePath
export (NodePath) var doorcard_rf_rhd_path: NodePath
export (NodePath) var tesla_badge_path: NodePath
export (NodePath) var fascia_standard_path: NodePath
export (NodePath) var fascia_perf_path: NodePath
export (NodePath) var seats_standard_path: NodePath
export (NodePath) var seats_perf_path: NodePath
export (NodePath) var mirror_left_standard_path: NodePath
export (NodePath) var mirror_left_perf_path: NodePath
export (NodePath) var mirror_right_standard_path: NodePath
export (NodePath) var mirror_right_perf_path: NodePath

export (bool) var parking_lights_on setget set_parking_lights_on
export (bool) var hide_tesla_badge setget set_hide_tesla_badge
export (bool) var is_performance setget set_is_performance

onready var turn_signal_rear_l: MeshInstance = get_node_or_null(turn_signal_rear_l_path)
onready var turn_signal_rear_r: MeshInstance = get_node_or_null(turn_signal_rear_r_path)
onready var park_light_rear: MeshInstance = get_node_or_null(park_light_rear_path)
onready var park_light_rear_projection: MeshInstance = get_node_or_null(park_light_rear_projection_path)
onready var headlight_beam: Spatial = get_node_or_null(headlight_beam_path)
onready var doorcard_lf: MeshInstance = get_node_or_null(doorcard_lf_path)
onready var doorcard_lf_rhd: MeshInstance = get_node_or_null(doorcard_lf_rhd_path)
onready var doorcard_rf: MeshInstance = get_node_or_null(doorcard_rf_path)
onready var doorcard_rf_rhd: MeshInstance = get_node_or_null(doorcard_rf_rhd_path)
onready var tesla_badge: MeshInstance = get_node_or_null(tesla_badge_path)
onready var fascia_standard: MeshInstance = get_node_or_null(fascia_standard_path)
onready var fascia_perf: MeshInstance = get_node_or_null(fascia_perf_path)
onready var seats_standard: MeshInstance = get_node_or_null(seats_standard_path)
onready var seats_perf: MeshInstance = get_node_or_null(seats_perf_path)
onready var mirror_left_standard: MeshInstance = get_node_or_null(mirror_left_standard_path)
onready var mirror_left_perf: MeshInstance = get_node_or_null(mirror_left_perf_path)
onready var mirror_right_standard: MeshInstance = get_node_or_null(mirror_right_standard_path)
onready var mirror_right_perf: MeshInstance = get_node_or_null(mirror_right_perf_path)

var headlight_beam_on setget set_headlight_beam_on

func get_glass_resource_names():
	return ["GlassSkybox", "GlassWindowsDark", "GlassSkyboxFade", "GlassTopFade"]

func get_roof_fade_resource_names():
	return ["GlassTopFade", 
			"GlassSkyboxFade", 
			"Cover_Fade", 
			"Trim_Fade", 
			"Interior_Fade", 
			"Glass_Trunk_Interior_Fade", 
			"Metal_Fade", 
			"Paint_Rough_Fade"]

func update(data: VehicleData, animated: bool = false, speed: float = 1.0):
	.update(data, animated, speed)
	set_hide_tesla_badge( not data.vehicle_config.has_tesla_badge)
	set_is_performance(data.vehicle_config.fascia_type == "performanceBayberry")

func set_hide_tesla_badge(hide: bool):
	hide_tesla_badge = hide
	set_node_visible(tesla_badge, not hide)
	
func set_is_performance(is_perf):
	is_performance = is_perf

	set_node_visible(fascia_standard, not is_perf)
	set_node_visible(seats_standard, not is_perf)
	set_node_visible(mirror_left_standard, not is_perf)
	set_node_visible(mirror_right_standard, not is_perf)
	set_node_visible(fascia_perf, is_perf)
	set_node_visible(seats_perf, is_perf)
	set_node_visible(mirror_left_perf, is_perf)
	set_node_visible(mirror_right_perf, is_perf)
	
	set_has_spoiler(is_perf)

func set_interior_config(interior):
	.set_interior_config(interior)
	
	var seats_mat: SpatialMaterial
	var seats_mat_7s: SpatialMaterial
	match (interior):
		VehicleOptions.InteriorConfig.White, VehicleOptions.InteriorConfig.White2:
			seats_mat = load("res://" + local_dir + "/White_Seats.tres")
			seats_mat_7s = load("res://" + local_dir + "/White_Seats_7S.tres")
		VehicleOptions.InteriorConfig.Black, VehicleOptions.InteriorConfig.Black2:
			seats_mat = load("res://" + local_dir + "/Black_Seats.tres")
			seats_mat_7s = load("res://" + local_dir + "/Black_Seats_7S.tres")
			
	if seats_mat: apply_material(self, seats_mat, "Seats")
	if seats_mat_7s: apply_material(self, seats_mat_7s, "Seats7S")

func set_headlight_beam_on(on):
	headlight_beam_on = on
	set_node_visible(headlight_beam, on)

func set_parking_lights_on(on: bool):
	if parking_lights_on == on: return
	parking_lights_on = on

	set_headlight_beam_on(drl_on or headlights_on or parking_lights_on)
	set_node_visible(drl, drl_on or headlights_on or parking_lights_on)
	set_node_visible(park_light_rear, on or headlights_on)
	set_node_visible(park_light_rear_projection, on or headlights_on)

func set_drl_on(on: bool):
	if drl_on == on: return
	drl_on = on
	
	set_headlight_beam_on(drl_on or headlights_on or parking_lights_on)
	set_node_visible(drl, drl_on or headlights_on or parking_lights_on)

func set_headlights_on(on: bool):
	if headlights_on == on: return
	headlights_on = on
	
	set_headlight_beam_on(drl_on or headlights_on or parking_lights_on)
	set_node_visible(drl, drl_on or headlights_on or parking_lights_on)
	set_node_visible(headlights, headlights_on)
	set_node_visible(park_light_rear, parking_lights_on or headlights_on)
	set_node_visible(park_light_rear_projection, parking_lights_on or headlights_on)

func set_headlamp_type(type: int):
	headlamp_type = type

func set_fog_lights_on(on):
	fog_lights_on = on
	set_node_visible(fog_lights, on)

func set_reverse_lights_on(on):
	reverse_lights_on = on
	set_node_visible(reverse_lights, on)

func set_turn_signal_r_state(state: int):
	turn_signal_r_state = state
	set_node_visible(turn_signal_r, state == 1)
	set_node_visible(turn_signal_rear_r, state == 1)
	
func set_turn_signal_l_state(state: int):
	turn_signal_l_state = state
	set_node_visible(turn_signal_l, state == 1)
	set_node_visible(turn_signal_rear_l, state == 1)

func set_brake_lights_on(on: bool):
	brake_lights_on = on
	set_node_visible(brake_lights_center, on)
	set_node_visible(brake_lights_l, on)
	set_node_visible(brake_lights_r, on)

func set_rhd(is_rhd):
	.set_rhd(is_rhd)
	
	set_node_visible(doorcard_lf, not is_rhd)
	set_node_visible(doorcard_lf_rhd, is_rhd)
	set_node_visible(doorcard_rf, not is_rhd)
	set_node_visible(doorcard_rf_rhd, is_rhd)

func get_skin_file_path(skin_name):
	if fascia_type == VehicleOptions.FasciaType.BAYBERRY_PERF:
		return "res://" + local_dir + "/Textures/Skins/Performance/" + skin_name + ".png"
	else:
		return "res://" + local_dir + "/Textures/Skins/Base/" + skin_name + ".png"

	return .get_skin_file_path(skin_name)
