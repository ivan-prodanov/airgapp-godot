tool 
extends Vehicle

export (ExteriorTrim) var exterior_trim setget set_exterior_trim
export (VehicleOptions.HeadlampType) var headlamp_type setget set_headlamp_type


export (NodePath) var center_console1_path: NodePath
export (NodePath) var center_console2_path: NodePath

export (NodePath) var lf_door_card1_path: NodePath
export (NodePath) var rf_door_card1_path: NodePath
export (NodePath) var lf_door_card2_path: NodePath
export (NodePath) var rf_door_card2_path: NodePath
export (NodePath) var lf_door_decor_path: NodePath
export (NodePath) var rf_door_decor_path: NodePath

export (NodePath) var lhd_steering_wheel_path: NodePath
export (NodePath) var rhd_steering_wheel_path: NodePath
export (NodePath) var lhd_dashboard_path: NodePath
export (NodePath) var rhd_dashboard_path: NodePath
export (NodePath) var lhd_screen_path: NodePath
export (NodePath) var rhd_screen_path: NodePath

export (NodePath) var headlights_object_original_path: NodePath
export (NodePath) var headlights_object_global_path: NodePath
export (NodePath) var headlights_global_path: NodePath
export (NodePath) var headlights_trunk_original_path: NodePath
export (NodePath) var headlights_trunk_global_path: NodePath
export (NodePath) var lights_trunk_original_path: NodePath
export (NodePath) var lights_trunk_global_path: NodePath
export (NodePath) var brake_lights_global_path: NodePath
export (NodePath) var fog_lights_global_path: NodePath
export (NodePath) var fog_rear_lights_global_path: NodePath
export (NodePath) var reverse_lights_global_path: NodePath
export (NodePath) var turn_signal_r_global_path: NodePath
export (NodePath) var turn_signal_l_global_path: NodePath
export (NodePath) var drl_global_path: NodePath
export (NodePath) var charge_cap_original_path: NodePath
export (NodePath) var charge_cap_global_path: NodePath
export (NodePath) var charge_cap_right_original_path: NodePath
export (NodePath) var charge_cap_right_global_path: NodePath

export (NodePath) var fog_lights_cover_path: NodePath

onready var center_console1: MeshInstance = get_node_or_null(center_console1_path)
onready var center_console2: MeshInstance = get_node_or_null(center_console2_path)

onready var lf_door_card1: MeshInstance = get_node_or_null(lf_door_card1_path)
onready var rf_door_card1: MeshInstance = get_node_or_null(rf_door_card1_path)
onready var lf_door_card2: MeshInstance = get_node_or_null(lf_door_card2_path)
onready var rf_door_card2: MeshInstance = get_node_or_null(rf_door_card2_path)
onready var lf_door_decor: MeshInstance = get_node_or_null(lf_door_decor_path)
onready var rf_door_decor: MeshInstance = get_node_or_null(rf_door_decor_path)

onready var lhd_steering_wheel: Spatial = get_node_or_null(lhd_steering_wheel_path)
onready var rhd_steering_wheel: Spatial = get_node_or_null(rhd_steering_wheel_path)
onready var lhd_dashboard: Spatial = get_node_or_null(lhd_dashboard_path)
onready var rhd_dashboard: Spatial = get_node_or_null(rhd_dashboard_path)
onready var lhd_screen: Spatial = get_node_or_null(lhd_screen_path)
onready var rhd_screen: Spatial = get_node_or_null(rhd_screen_path)

onready var headlights_object_original: Spatial = get_node_or_null(headlights_object_original_path)
onready var headlights_object_global: Spatial = get_node_or_null(headlights_object_global_path)
onready var headlights_global: Spatial = get_node_or_null(headlights_global_path)
onready var headlights_trunk_original: Spatial = get_node_or_null(headlights_trunk_original_path)
onready var headlights_trunk_global: Spatial = get_node_or_null(headlights_trunk_global_path)
onready var lights_trunk_original: Spatial = get_node_or_null(lights_trunk_original_path)
onready var lights_trunk_global: Spatial = get_node_or_null(lights_trunk_global_path)
onready var brake_lights_global: Spatial = get_node_or_null(brake_lights_global_path)
onready var fog_lights_global: Spatial = get_node_or_null(fog_lights_global_path)
onready var fog_rear_lights_global: Spatial = get_node_or_null(fog_rear_lights_global_path)
onready var reverse_lights_global: Spatial = get_node_or_null(reverse_lights_global_path)
onready var turn_signal_r_global: Spatial = get_node_or_null(turn_signal_r_global_path)
onready var turn_signal_l_global: Spatial = get_node_or_null(turn_signal_l_global_path)
onready var drl_global: Spatial = get_node_or_null(drl_global_path)
onready var charge_cap_original: Spatial = get_node_or_null(charge_cap_original_path)
onready var charge_cap_global: Spatial = get_node_or_null(charge_cap_global_path)
onready var charge_cap_right_original: Spatial = get_node_or_null(charge_cap_right_original_path)
onready var charge_cap_right_global: Spatial = get_node_or_null(charge_cap_right_global_path)

onready var fog_lights_cover: Spatial = get_node_or_null(fog_lights_cover_path)



func get_roof_fade_resource_names():
	return ["ExteriorFade", 
			"InteriorFade", 
			"Glass_Fade", 
			"Glass_Tinted_Fade", 
			"Glass_Interior_Fade", 
			"GlassFadeSkybox", 
			"GlassTintedFadeSkybox", 
			"Glass_Interior_Tinted_Fade", 
			"PlasticBlackFade", 
			"Plastic_White_Fade", 
			"MirrorFade", 
			"Chrome_Fade"]

func set_exterior_trim_str(trim: String):
	var value = ExteriorTrimMap.get(trim, ExteriorTrim.Original)
	set_exterior_trim(value)

func set_interior_config(interior):
	.set_interior_config(interior)
	var is_new_interior = interior == VehicleOptions.InteriorConfig.Black2 or interior == VehicleOptions.InteriorConfig.White2
	set_node_visible(center_console1, not is_new_interior)
	set_node_visible(center_console2, is_new_interior)
	set_node_visible(lf_door_card1, not is_new_interior)
	set_node_visible(rf_door_card1, not is_new_interior)
	set_node_visible(lf_door_card2, is_new_interior)
	set_node_visible(rf_door_card2, is_new_interior)
	set_node_visible(lf_door_decor, is_new_interior)
	set_node_visible(rf_door_decor, is_new_interior)
	
	var seats_mat: SpatialMaterial
	var decor_mat: SpatialMaterial
	match (interior):
		VehicleOptions.InteriorConfig.White, VehicleOptions.InteriorConfig.White2:
			seats_mat = load("res://" + local_dir + "/Interior_Seats_White.material")
			decor_mat = load("res://" + local_dir + "/Decor_White.material")
		VehicleOptions.InteriorConfig.Black, VehicleOptions.InteriorConfig.Black2:
			seats_mat = load("res://" + local_dir + "/Interior_Seats_Black.material")
			decor_mat = load("res://" + local_dir + "/Wood_Walnut.material")
	if seats_mat: apply_material(self, seats_mat, "InteriorSeats")
	if decor_mat: apply_material(self, decor_mat, "Decor")

func set_rhd(is_rhd):
	.set_rhd(is_rhd)
	
	set_node_visible(lhd_steering_wheel, not is_rhd)
	set_node_visible(rhd_steering_wheel, is_rhd)
	set_node_visible(lhd_dashboard, not is_rhd)
	set_node_visible(rhd_dashboard, is_rhd)
	set_node_visible(lhd_screen, not is_rhd)
	set_node_visible(rhd_screen, is_rhd)


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
	if type == headlamp_type: return
	headlamp_type = type
	
	var is_global = type == VehicleOptions.HeadlampType.Global
	set_node_visible(headlights_object_original, not is_global)
	set_node_visible(headlights_object_global, is_global)
	set_node_visible(lights_trunk_original, not is_global)
	set_node_visible(lights_trunk_global, is_global)
	set_node_visible(charge_cap_original, not is_global)
	set_node_visible(charge_cap_global, is_global)
	set_node_visible(charge_cap_right_original, not is_global)
	set_node_visible(charge_cap_right_global, is_global)
	
	set_headlights_on(headlights_on)
	set_fog_lights_on(fog_lights_on)
	set_reverse_lights_on(reverse_lights_on)
	set_turn_signal_l_state(turn_signal_l_state)
	set_turn_signal_r_state(turn_signal_r_state)
	set_drl_on(drl_on)
	set_brake_lights_on(brake_lights_on)



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
	var is_global = headlamp_type == VehicleOptions.HeadlampType.Global
	
	set_node_visible(turn_signal_r, not is_global and on)
	set_node_visible(brake_lights_r, not is_global and on)
	
	set_node_visible(turn_signal_r_global, is_global and on)
	
func set_turn_signal_l_state(state: int):
	turn_signal_l_state = state
	var on: bool = state == 1
	var is_global = headlamp_type == VehicleOptions.HeadlampType.Global
	
	set_node_visible(turn_signal_l, not is_global and on)
	set_node_visible(brake_lights_l, not is_global and on)
	
	set_node_visible(turn_signal_l_global, is_global and on)
	
func set_drl_on(on):
	drl_on = on
	var is_global = headlamp_type == VehicleOptions.HeadlampType.Global
	
	set_node_visible(drl, not is_global and on)
	
	set_node_visible(drl_global, is_global and on)
	
func set_headlights_on(on):
	headlights_on = on
	var is_global = headlamp_type == VehicleOptions.HeadlampType.Global
	
	set_node_visible(headlights, not is_global and on)
	set_node_visible(headlights_trunk_original, not is_global and on)
	
	set_node_visible(headlights_global, is_global and on)
	set_node_visible(headlights_trunk_global, is_global and on)
	set_node_visible(drl_global, is_global and on)

func set_brake_lights_on(on: bool):
	brake_lights_on = on
	var is_global = headlamp_type == VehicleOptions.HeadlampType.Global
	
	set_node_visible(brake_lights_center, not is_global and on)
	set_node_visible(brake_lights_l, not is_global and on)
	set_node_visible(brake_lights_r, not is_global and on)
	
	set_node_visible(brake_lights_global, is_global and on)

func update(data: VehicleData, animated: bool = false, speed: float = 1.0):
	.update(data, animated, speed)
	var trim = data.vehicle_config.exterior_trim
	if ( not data.vehicle_config.exterior_trim_override.empty()):
		trim = data.vehicle_config.exterior_trim_override
	set_exterior_trim_str(trim)
	set_headlamp_type(VehicleOptions.HeadlampType.Global if data.hasGlobalHeadlamp() else VehicleOptions.HeadlampType.Original)
	set_node_visible(fog_lights_cover, not data.hasFogLamps())
	
