tool 
extends "res://mobile/scripts/Vehicles/Model_Y.gd"

export (NodePath) var drl_left_path: NodePath
export (NodePath) var drl_right_path: NodePath
export (NodePath) var highbeam_left_path: NodePath
export (NodePath) var highbeam_right_path: NodePath
export (NodePath) var park_light_rear_path: NodePath
export (NodePath) var park_light_rear_projection_path: NodePath
export (NodePath) var turn_signal_rear_l_path: NodePath
export (NodePath) var turn_signal_rear_r_path: NodePath
export (NodePath) var doorcard_lf_path: NodePath
export (NodePath) var doorcard_lf_rhd_path: NodePath
export (NodePath) var doorcard_rf_path: NodePath
export (NodePath) var doorcard_rf_rhd_path: NodePath
export (NodePath) var tesla_badge_path: NodePath

export (bool) var parking_lights_on setget set_parking_lights_on
export (bool) var hide_tesla_badge setget set_hide_tesla_badge
export (Color) var brake_on_color = Color("FF0000")
export (Color) var brake_off_color = Color("D91F00")

onready var drl_left: MeshInstance = get_node_or_null(drl_left_path)
onready var drl_right: MeshInstance = get_node_or_null(drl_right_path)
onready var highbeam_left: MeshInstance = get_node_or_null(highbeam_left_path)
onready var highbeam_right: MeshInstance = get_node_or_null(highbeam_right_path)
onready var turn_signal_rear_l: MeshInstance = get_node_or_null(turn_signal_rear_l_path)
onready var turn_signal_rear_r: MeshInstance = get_node_or_null(turn_signal_rear_r_path)
onready var park_light_rear: MeshInstance = get_node_or_null(park_light_rear_path)
onready var park_light_rear_projection: MeshInstance = get_node_or_null(park_light_rear_projection_path)
onready var doorcard_lf: MeshInstance = get_node_or_null(doorcard_lf_path)
onready var doorcard_lf_rhd: MeshInstance = get_node_or_null(doorcard_lf_rhd_path)
onready var doorcard_rf: MeshInstance = get_node_or_null(doorcard_rf_path)
onready var doorcard_rf_rhd: MeshInstance = get_node_or_null(doorcard_rf_rhd_path)
onready var tesla_badge: MeshInstance = get_node_or_null(tesla_badge_path)

func get_glass_resource_names():
	return ["GlassSkybox", "GlassWindowsDark", "GlassSkyboxFade", "GlassTopFade"]

func get_roof_fade_resource_names():
	return ["GlassTopFade", 
			"GlassSkyboxFade", 
			"Cover_Fade", 
			"Trim_Fade", 
			"Interior_Fade"]

func update(data: VehicleData, animated: bool = false, speed: float = 1.0):
	.update(data, animated, speed)
	set_hide_tesla_badge( not data.vehicle_config.has_tesla_badge)

func set_hide_tesla_badge(hide: bool):
	hide_tesla_badge = hide
	set_node_visible(tesla_badge, not hide)
	
func get_mat_drl_glow_left():
	if not drl_left or not drl_left.mesh:
		return null
	
	return drl_left.mesh.surface_get_material(2)
	
func get_mat_drl_glow_right():
	if not drl_right or not drl_right.mesh:
		return null
	
	return drl_right.mesh.surface_get_material(2)
		
func get_mat_highbeam_glow_left():
	if not highbeam_left or not highbeam_left.mesh:
		return null
	
	return highbeam_left.mesh.surface_get_material(2)
	
func get_mat_highbeam_glow_right():
	if not highbeam_right or not highbeam_right.mesh:
		return null
	
	return highbeam_right.mesh.surface_get_material(2)
	
func set_interior_config(interior):
	interior_config = interior

func set_parking_lights_on(on: bool):
	parking_lights_on = on
	
	
	set_drl_on(drl_on)
	
	
	var is_global: bool = headlamp_type == VehicleOptions.HeadlampType.Global
	if not is_global:
		if turn_signal_l_state != - 1:
			set_node_visible(turn_signal_rear_l, headlights_on or parking_lights_on or brake_lights_on or turn_signal_l_state == 1)
		if turn_signal_r_state != - 1:
			set_node_visible(turn_signal_rear_r, headlights_on or parking_lights_on or brake_lights_on or turn_signal_r_state == 1)
	else:
		set_node_visible(turn_signal_rear_l, headlights_on or parking_lights_on or brake_lights_on)
		set_node_visible(turn_signal_rear_r, headlights_on or parking_lights_on or brake_lights_on)
		
	set_node_visible(park_light_rear_projection, headlights_on or parking_lights_on)

func set_drl_on(on: bool):
	drl_on = on
	set_node_visible(drl_left, (drl_on or headlights_on or parking_lights_on))
	set_node_visible(drl_right, (drl_on or headlights_on or parking_lights_on))

func set_headlights_on(on: bool):
	headlights_on = on
	
	
	set_drl_on(drl_on)
	set_node_visible(highbeam_left, headlights_on)
	set_node_visible(highbeam_right, headlights_on)
	
	
	
	
	
	var is_global: bool = headlamp_type == VehicleOptions.HeadlampType.Global
	if not is_global:
		if turn_signal_l_state != - 1:
			set_node_visible(turn_signal_rear_l, headlights_on or parking_lights_on or brake_lights_on or turn_signal_l_state == 1)
		if turn_signal_r_state != - 1:
			set_node_visible(turn_signal_rear_r, headlights_on or parking_lights_on or brake_lights_on or turn_signal_r_state == 1)
	else:
		set_node_visible(turn_signal_rear_l, headlights_on or parking_lights_on or brake_lights_on)
		set_node_visible(turn_signal_rear_r, headlights_on or parking_lights_on or brake_lights_on)

	set_node_visible(park_light_rear_projection, headlights_on or parking_lights_on)
	
func set_headlamp_type(type: int):
	if headlamp_type == type: return
		
	headlamp_type = type
	
	set_turn_signal_r_state(turn_signal_r_state)
	set_turn_signal_l_state(turn_signal_l_state)
	set_reverse_lights_on(reverse_lights_on)
	
	
	
	if turn_signal_r_global and turn_signal_l_global:
		var is_global: bool = headlamp_type == VehicleOptions.HeadlampType.Global
		var mat_r: SpatialMaterial = turn_signal_r_global.get_surface_material(0)
		var mat_l: SpatialMaterial = turn_signal_l_global.get_surface_material(0)
	
		if is_global:
			mat_r.albedo_color = Color.orange
			mat_l.albedo_color = Color.orange
		else:
			mat_r.albedo_color = Color.white
			mat_l.albedo_color = Color.white

func set_fog_lights_on(on):
	fog_lights_on = on
	set_node_visible(fog_lights, on)

func set_drl_glow_left(turn_left_on: bool):
	var mat = get_mat_drl_glow_left()
	if mat:
		if turn_left_on:
			mat.albedo_color.b = 0.0
		else:
			mat.albedo_color.b = 1.0

func set_drl_glow_right(turn_right_on: bool):
	var mat = get_mat_drl_glow_right()
	if mat:
		if turn_right_on:
			mat.albedo_color.b = 0.0
		else:
			mat.albedo_color.b = 1.0

func set_highbeam_glow_left(turn_left_on: bool):
	var mat = get_mat_highbeam_glow_left()
	if mat:
		if turn_left_on:
			mat.albedo_color.b = 0.0
		else:
			mat.albedo_color.b = 1.0

func set_highbeam_glow_right(turn_right_on: bool):
	var mat = get_mat_highbeam_glow_right()
	if mat:
		if turn_right_on:
			mat.albedo_color.b = 0.0
		else:
			mat.albedo_color.b = 1.0

func set_turn_signal_r_state(state: int):
	turn_signal_r_state = state
	var on: bool = state == 1
	
	set_drl_glow_right(on)
	set_highbeam_glow_right(on)
	set_node_visible(turn_signal_r, on)
	
	var is_global = headlamp_type == VehicleOptions.HeadlampType.Global
	
	
	if is_global:
		set_node_visible(turn_signal_r_global, on)
		set_node_visible(turn_signal_rear_r, headlights_on or parking_lights_on or brake_lights_on)
	else:
		set_node_visible(turn_signal_r_global, false)
		set_node_visible(turn_signal_rear_r, on)
		
func set_turn_signal_l_state(state: int):
	turn_signal_l_state = state
	var on: bool = state == 1
	
	set_drl_glow_left(on)
	set_highbeam_glow_left(on)
	set_node_visible(turn_signal_l, on)
	
	var is_global = headlamp_type == VehicleOptions.HeadlampType.Global
	
	
	if is_global:
		set_node_visible(turn_signal_l_global, on)
		set_node_visible(turn_signal_rear_l, headlights_on or parking_lights_on or brake_lights_on)
	else:
		set_node_visible(turn_signal_l_global, false)
		set_node_visible(turn_signal_rear_l, on)

func set_brake_lights_on(on: bool):
	brake_lights_on = on
	set_node_visible(brake_lights_center, brake_lights_on)
	
	if turn_signal_rear_r:
		var mat_turn_signal = turn_signal_rear_r.get_surface_material(0)
		if brake_lights_on:
			mat_turn_signal.albedo_color = brake_on_color
		else:
			mat_turn_signal.albedo_color = brake_off_color
	
	var is_global = headlamp_type == VehicleOptions.HeadlampType.Global
	if is_global:
		set_node_visible(turn_signal_rear_r, headlights_on or parking_lights_on or brake_lights_on)
		set_node_visible(turn_signal_rear_l, headlights_on or parking_lights_on or brake_lights_on)
	else:
		set_node_visible(turn_signal_rear_r, headlights_on or parking_lights_on or brake_lights_on or turn_signal_r_state == 1)
		set_node_visible(turn_signal_rear_l, headlights_on or parking_lights_on or brake_lights_on or turn_signal_l_state == 1)

func set_rhd(is_rhd):
	.set_rhd(is_rhd)
	
	set_node_visible(doorcard_lf, not is_rhd)
	set_node_visible(doorcard_lf_rhd, is_rhd)
	set_node_visible(doorcard_rf, not is_rhd)
	set_node_visible(doorcard_rf_rhd, is_rhd)
