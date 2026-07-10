tool 
class_name Palladium
extends Vehicle

enum SteeringWheelType{
	Standard, 
	Yoke
}

enum FasciaType{
	Original, 
	P3ModelSBase, 
	P3ModelSPlaid, 
	P3ModelX
}

export (SteeringWheelType) var steering_wheel_type setget set_steering_wheel_type
export (VehicleOptions.HeadlampType) var headlamp_type setget set_headlamp_type
export (VehicleOptions.RearLightType) var rearlight_type setget set_rearlight_type
export (FasciaType) var fascia_type_enum setget set_fascia_type_enum
export (VehicleOptions.SpecialBadgingType) var special_badging_type: int setget set_special_badging_type

export (bool) var hide_tesla_badge setget set_hide_tesla_badge
export (bool) var hide_tesla_wordmark setget set_hide_tesla_wordmark


export (NodePath) var screens_path: NodePath
export (NodePath) var screens_rhd_path: NodePath
export (NodePath) var steering_wheel_placement_path: NodePath
export (NodePath) var steering_wheel_placement_rhd_path: NodePath
export (NodePath) var steering_wheel_standard_path: NodePath
export (NodePath) var steering_wheel_standard_rhd_path: NodePath
export (NodePath) var steering_wheel_yoke_path: NodePath
export (NodePath) var steering_wheel_yoke_rhd_path: NodePath
export (NodePath) var dashboard_path: NodePath
export (NodePath) var dashboard_rhd_path: NodePath
export (NodePath) var dashboard_color_path: NodePath
export (NodePath) var dashboard_color_rhd_path: NodePath
export (NodePath) var dashboard_decor_path: NodePath
export (NodePath) var dashboard_decor_rhd_path: NodePath
export (NodePath) var dashboard_glass_path: NodePath
export (NodePath) var dashboard_glass_rhd_path: NodePath

export (NodePath) var right_turn_signal_front_original_path: NodePath
export (NodePath) var right_turn_signal_rear_original_path: NodePath
export (NodePath) var right_turn_signal_front_global_path: NodePath
export (NodePath) var right_turn_signal_rear_global_path: NodePath
export (NodePath) var left_turn_signal_front_original_path: NodePath
export (NodePath) var left_turn_signal_rear_original_path: NodePath
export (NodePath) var left_turn_signal_front_global_path: NodePath
export (NodePath) var left_turn_signal_rear_global_path: NodePath
export (NodePath) var drl_global_path: NodePath
export (NodePath) var headlight_front_original_path: NodePath
export (NodePath) var headlight_rear_original_path: NodePath
export (NodePath) var headlight_front_global_path: NodePath
export (NodePath) var headlight_rear_global_path: NodePath
export (NodePath) var lights_glass_front_original_path: NodePath
export (NodePath) var lights_glass_rear_original_path: NodePath
export (NodePath) var lights_glass_front_global_path: NodePath
export (NodePath) var lights_glass_rear_global_path: NodePath
export (NodePath) var brake_lights_global_path: NodePath
export (NodePath) var fog_lights_global_path: NodePath
export (NodePath) var lights_front_original_path: NodePath
export (NodePath) var lights_rear_original_path: NodePath
export (NodePath) var lights_front_global_path: NodePath
export (NodePath) var lights_rear_global_path: NodePath
export (NodePath) var headlight_trunk_path: NodePath
export (NodePath) var headlight_trunk_global_path: NodePath
export (NodePath) var lights_glass_trunk_original_path: NodePath
export (NodePath) var lights_glass_trunk_global_path: NodePath
export (NodePath) var brake_lights_trunk_global_path: NodePath
export (NodePath) var fog_lights_trunk_global_path: NodePath
export (NodePath) var lights_trunk_original_path: NodePath
export (NodePath) var lights_trunk_global_path: NodePath
export (NodePath) var reverse_lights_global_path: NodePath
export (NodePath) var trunk_original_path: NodePath
export (NodePath) var trunk_global_path: NodePath
export (NodePath) var charge_cap_left_original_path: NodePath
export (NodePath) var charge_cap_left_global_path: NodePath
export (NodePath) var charge_cap_right_original_path: NodePath
export (NodePath) var charge_cap_right_global_path: NodePath
export (NodePath) var chargeport_original_path: NodePath
export (NodePath) var chargeport_global_path: NodePath
export (NodePath) var chargeport_locator_global_path: NodePath
export (NodePath) var tesla_badge_global_path: NodePath
export (NodePath) var tesla_wordmark_global_path: NodePath
export (NodePath) var plaid_badge_path: NodePath
export (NodePath) var plaid_badge_signature_path: NodePath

export (PackedScene) var brakes_signature_front_left: PackedScene
export (PackedScene) var brakes_signature_rear_left: PackedScene
export (PackedScene) var brakes_signature_front_right: PackedScene
export (PackedScene) var brakes_signature_rear_right: PackedScene

onready var chargeport_global_animation: AnimationPlayer = get_node_or_null("ChargeportGlobalAnimation")


onready var screens: MeshInstance = get_node_or_null(screens_path)
onready var screens_rhd: MeshInstance = get_node_or_null(screens_rhd_path)
onready var steering_wheel_placement: Spatial = get_node_or_null(steering_wheel_placement_path)
onready var steering_wheel_placement_rhd: Spatial = get_node_or_null(steering_wheel_placement_rhd_path)
onready var steering_wheel_standard: MeshInstance = get_node_or_null(steering_wheel_standard_path)
onready var steering_wheel_standard_rhd: MeshInstance = get_node_or_null(steering_wheel_standard_rhd_path)
onready var steering_wheel_yoke: MeshInstance = get_node_or_null(steering_wheel_yoke_path)
onready var steering_wheel_yoke_rhd: MeshInstance = get_node_or_null(steering_wheel_yoke_rhd_path)
onready var dashboard: MeshInstance = get_node_or_null(dashboard_path)
onready var dashboard_rhd: MeshInstance = get_node_or_null(dashboard_rhd_path)
onready var dashboard_color: MeshInstance = get_node_or_null(dashboard_color_path)
onready var dashboard_color_rhd: MeshInstance = get_node_or_null(dashboard_color_rhd_path)
onready var dashboard_decor: MeshInstance = get_node_or_null(dashboard_decor_path)
onready var dashboard_decor_rhd: MeshInstance = get_node_or_null(dashboard_decor_rhd_path)
onready var dashboard_glass: MeshInstance = get_node_or_null(dashboard_glass_path)
onready var dashboard_glass_rhd: MeshInstance = get_node_or_null(dashboard_glass_rhd_path)
onready var tesla_badge_global = get_node_or_null(tesla_badge_global_path)
onready var tesla_wordmark_global = get_node_or_null(tesla_wordmark_global_path)
onready var plaid_badge = get_node_or_null(plaid_badge_path)
onready var plaid_badge_signature = get_node_or_null(plaid_badge_signature_path)


onready var right_turn_signal_front_original: MeshInstance = get_node_or_null(right_turn_signal_front_original_path)
onready var right_turn_signal_rear_original: MeshInstance = get_node_or_null(right_turn_signal_rear_original_path)
onready var right_turn_signal_front_global: MeshInstance = get_node_or_null(right_turn_signal_front_global_path)
onready var right_turn_signal_rear_global: MeshInstance = get_node_or_null(right_turn_signal_rear_global_path)
onready var left_turn_signal_front_original: MeshInstance = get_node_or_null(left_turn_signal_front_original_path)
onready var left_turn_signal_rear_original: MeshInstance = get_node_or_null(left_turn_signal_rear_original_path)
onready var left_turn_signal_front_global: MeshInstance = get_node_or_null(left_turn_signal_front_global_path)
onready var left_turn_signal_rear_global: MeshInstance = get_node_or_null(left_turn_signal_rear_global_path)
onready var drl_global: MeshInstance = get_node_or_null(drl_global_path)
onready var headlight_front_original: MeshInstance = get_node_or_null(headlight_front_original_path)
onready var headlight_rear_original: MeshInstance = get_node_or_null(headlight_rear_original_path)
onready var headlight_front_global: MeshInstance = get_node_or_null(headlight_front_global_path)
onready var headlight_rear_global: MeshInstance = get_node_or_null(headlight_rear_global_path)
onready var lights_glass_front_original: MeshInstance = get_node_or_null(lights_glass_front_original_path)
onready var lights_glass_rear_original: MeshInstance = get_node_or_null(lights_glass_rear_original_path)
onready var lights_glass_front_global: MeshInstance = get_node_or_null(lights_glass_front_global_path)
onready var lights_glass_rear_global: MeshInstance = get_node_or_null(lights_glass_rear_global_path)
onready var brake_lights_global: MeshInstance = get_node_or_null(brake_lights_global_path)
onready var fog_lights_global: MeshInstance = get_node_or_null(fog_lights_global_path)
onready var lights_front_original: MeshInstance = get_node_or_null(lights_front_original_path)
onready var lights_rear_original: MeshInstance = get_node_or_null(lights_rear_original_path)
onready var lights_front_global: MeshInstance = get_node_or_null(lights_front_global_path)
onready var lights_rear_global: MeshInstance = get_node_or_null(lights_rear_global_path)
onready var headlight_trunk_original: MeshInstance = get_node_or_null(headlight_trunk_path)
onready var headlight_trunk_global: MeshInstance = get_node_or_null(headlight_trunk_global_path)
onready var lights_glass_trunk_original: MeshInstance = get_node_or_null(lights_glass_trunk_original_path)
onready var lights_glass_trunk_global: MeshInstance = get_node_or_null(lights_glass_trunk_global_path)
onready var brake_lights_trunk_global: MeshInstance = get_node_or_null(brake_lights_trunk_global_path)
onready var fog_lights_trunk_global: MeshInstance = get_node_or_null(fog_lights_trunk_global_path)
onready var lights_trunk_original: MeshInstance = get_node_or_null(lights_trunk_original_path)
onready var lights_trunk_global: MeshInstance = get_node_or_null(lights_trunk_global_path)
onready var reverse_lights_global: MeshInstance = get_node_or_null(reverse_lights_global_path)
onready var trunk_original: MeshInstance = get_node_or_null(trunk_original_path)
onready var trunk_global: MeshInstance = get_node_or_null(trunk_global_path)
onready var charge_cap_left_original: Spatial = get_node_or_null(charge_cap_left_original_path)
onready var charge_cap_left_global: Spatial = get_node_or_null(charge_cap_left_global_path)
onready var charge_cap_right_original: Spatial = get_node_or_null(charge_cap_right_original_path)
onready var charge_cap_right_global: Spatial = get_node_or_null(charge_cap_right_global_path)
onready var chargeport_original: Spatial = get_node_or_null(chargeport_original_path)
onready var chargeport_global: Spatial = get_node_or_null(chargeport_global_path)
onready var chargeport_locator_global: Spatial = get_node_or_null(chargeport_locator_global_path)
	
func get_roof_fade_resource_names():
	return ["PaintFade", 
			"ExteriorFade", 
			"Glass_Fade", 
			"Glass_Tinted_Fade", 
			"GlassFadeSkybox", 
			"GlassTintedFadeSkybox", 
			"Glass_Interior_Fade", 
			"Glass_Interior_Tinted_Fade", 
			"LeatherFade", 
			"MirrorFade", 
			"PlasticBlackFade", 
			"SuedeFade"]

func update(data: VehicleData, animated: bool = false, speed: float = 1.0):
	set_p3_fascia_type(data.vehicle_config.fascia_type)
	set_headlamp_type_from_data(data)
	set_rearlight_type_from_data(data)
	set_special_badging_type(data.vehicle_config.special_badging_type)
	.update(data, animated, speed)
	set_steering_wheel_type(data.vehicle_config.steering_wheel_type)
	set_hide_tesla_badge( not data.vehicle_config.has_tesla_badge)
	set_hide_tesla_wordmark( not data.vehicle_config.has_tesla_word_mark)

func set_drivetrain_type(type):
	.set_drivetrain_type(type)
	
	var is_plaid = type == DrivetrainType.AWDTriMotor
	var is_signature = special_badging_type == VehicleOptions.SpecialBadgingType.SIGNATURE_SERIES
	set_node_visible(plaid_badge, is_plaid and not is_signature)
	set_node_visible(plaid_badge_signature, is_plaid and is_signature)

func set_p3_fascia_type(fascia_type: String):
	var fascia = _string_to_fascia_type(fascia_type)
	set_fascia_type_enum(fascia)
	
func set_fascia_type_enum(fascia):
	fascia_type_enum = fascia
	if fascia == FasciaType.P3ModelX: return
	var show_original = fascia != FasciaType.P3ModelSPlaid
	
	var p3_nodes = get_tree().get_nodes_in_group("p3_fascia")
	var original_nodes = get_tree().get_nodes_in_group("original_fascia")
	if p3_nodes.empty() or original_nodes.empty():
		return
		
	for node in p3_nodes:
		node.visible = not show_original
		
	for node in original_nodes:
		node.visible = show_original

	set_special_badging_type(special_badging_type)

func _string_to_fascia_type(fascia_type: String) -> int:
	match fascia_type.to_lower():
		"p3s":
			return FasciaType.P3ModelSBase
		"p3splaid":
			return FasciaType.P3ModelSPlaid
		"p3x":
			return FasciaType.P3ModelX
		_:
			return FasciaType.Original

func get_skin_file_path(skin_name):
	var skin_sub_folder = "P3SPlaid" if fascia_type_enum == FasciaType.P3ModelSPlaid else "Base"
	return "res://" + local_dir + "/Textures/Skins/" + skin_sub_folder + "/" + skin_name + ".png"

func set_steering_wheel_type(type: int):
	steering_wheel_type = type
	
	if steering_wheel_standard: steering_wheel_standard.visible = type == SteeringWheelType.Standard
	if steering_wheel_standard_rhd: steering_wheel_standard_rhd.visible = type == SteeringWheelType.Standard
	if steering_wheel_yoke: steering_wheel_yoke.visible = type == SteeringWheelType.Yoke
	if steering_wheel_yoke_rhd: steering_wheel_yoke_rhd.visible = type == SteeringWheelType.Yoke


func set_rhd(is_rhd):
	.set_rhd(is_rhd)

	if screens: screens.visible = not is_rhd
	if screens_rhd: screens_rhd.visible = is_rhd
	if steering_wheel_placement: steering_wheel_placement.visible = not is_rhd
	if steering_wheel_placement_rhd: steering_wheel_placement_rhd.visible = is_rhd
	if dashboard: dashboard.visible = not is_rhd
	if dashboard_rhd: dashboard_rhd.visible = is_rhd
	if dashboard_color: dashboard_color.visible = not is_rhd
	if dashboard_color_rhd: dashboard_color_rhd.visible = is_rhd
	if dashboard_decor: dashboard_decor.visible = not is_rhd
	if dashboard_decor_rhd: dashboard_decor_rhd.visible = is_rhd
	if dashboard_glass: dashboard_glass.visible = not is_rhd
	if dashboard_glass_rhd: dashboard_glass_rhd.visible = is_rhd

func set_interior_config(interior):
	.set_interior_config(interior)
	
	if local_dir == null or local_dir == "": return

	var sport_seats_mat: SpatialMaterial = null
	
	match (interior):
		VehicleOptions.InteriorConfig.White, VehicleOptions.InteriorConfig.White2, VehicleOptions.InteriorConfig.WhiteCarbonFiber:
			sport_seats_mat = load_material("Sport_Seats_Interior_White")
		VehicleOptions.InteriorConfig.Black, VehicleOptions.InteriorConfig.Black2, VehicleOptions.InteriorConfig.BlackCarbonFiber:
			sport_seats_mat = load_material("Sport_Seats_Interior_Black")
		VehicleOptions.InteriorConfig.Cream, VehicleOptions.InteriorConfig.CreamCarbonFiber:
			sport_seats_mat = load_material("Sport_Seats_Interior_Cream")
	
	if sport_seats_mat:
		apply_material(self, sport_seats_mat, "Sport_Seats_Interior");
	
	var interior_mat: SpatialMaterial = null
	
	match (interior):
		VehicleOptions.InteriorConfig.WhiteCarbonFiber, VehicleOptions.InteriorConfig.BlackCarbonFiber, VehicleOptions.InteriorConfig.CreamCarbonFiber:
			interior_mat = load("res://" + local_dir + "/Carbon_Fiber.material");
		VehicleOptions.InteriorConfig.White:
			interior_mat = load("res://" + local_dir + "/Wood_Walnut.material");
		VehicleOptions.InteriorConfig.Black:
			interior_mat = load("res://" + local_dir + "/Wood_Ebony.material");
		VehicleOptions.InteriorConfig.Cream:
			interior_mat = load("res://" + local_dir + "/Wood_Walnut.material")

	if interior_mat:
		apply_material(self, interior_mat, "Wood");


func set_brakes(performace: bool):
	var load_successful = false
	
	if special_badging_type == VehicleOptions.SpecialBadgingType.SIGNATURE_SERIES and performace:
		has_perf_brakes = performace
		var sockets = [get_node_or_null(lf_brake_path), get_node_or_null(lr_brake_path), 
								get_node_or_null(rf_brake_path), get_node_or_null(rr_brake_path)]
		var models = [brakes_signature_front_left, brakes_signature_rear_left, 
							brakes_signature_front_right, brakes_signature_rear_right]
		for i in range(sockets.size()):
			if sockets[i] == null or models[i] == null: continue
			for child in sockets[i].get_children():
				sockets[i].remove_child(child)
				child.queue_free()
			sockets[i].add_child(models[i].instance())
			loaded_brakes = true
			load_successful = true
	
	if not load_successful:
		.set_brakes(performace)
	
	set_interior_config(interior_config)

func set_headlamp_type_from_data(data: VehicleData):
	var type = VehicleOptions.HeadlampType.Global if data.hasGlobalHeadlamp() else VehicleOptions.HeadlampType.Original
	set_headlamp_type(type)


func set_headlamp_type(type: int):
	headlamp_type = type
	var has_global = has_global_headlamp()
	
	
	set_node_visible(lights_front_original, not has_global)
	set_node_visible(lights_glass_front_original, not has_global)

	
	set_node_visible(lights_front_global, has_global)
	set_node_visible(lights_glass_front_global, has_global)

func set_rearlight_type_from_data(data: VehicleData):
	var data_rearlight_type = data.vehicle_config.rearlight_type
	set_rearlight_type(data_rearlight_type)

	if data_rearlight_type == VehicleOptions.RearLightType.Global and not in_editor():
		charge_port.transform.origin = chargeport_locator_global.transform.origin

func set_rearlight_type(type: int):
	rearlight_type = type
	var has_global = has_global_rearlight()
	
	
	set_node_visible(lights_rear_original, not has_global)
	set_node_visible(lights_glass_rear_original, not has_global)
	set_node_visible(lights_trunk_original, not has_global)
	set_node_visible(lights_glass_trunk_original, not has_global)
	set_node_visible(trunk_original, not has_global)
	set_node_visible(charge_cap_left_original, not has_global)
	set_node_visible(charge_cap_right_original, not has_global)
	set_node_visible(chargeport_original, not has_global)

	
	set_node_visible(lights_rear_global, has_global)
	set_node_visible(lights_glass_rear_global, has_global)
	set_node_visible(lights_trunk_global, has_global)
	set_node_visible(lights_glass_trunk_global, has_global)
	set_node_visible(trunk_global, has_global)
	set_node_visible(charge_cap_left_global, has_global)
	set_node_visible(charge_cap_right_global, has_global)
	set_node_visible(chargeport_global, has_global)
	
	
	set_hide_tesla_badge(hide_tesla_badge)
	set_hide_tesla_wordmark(hide_tesla_wordmark)

func set_special_badging_type(type: int):
	special_badging_type = type
	var is_signature = (type == VehicleOptions.SpecialBadgingType.SIGNATURE_SERIES)

	for node in get_tree().get_nodes_in_group("signature"):
		node.visible = is_signature
	for node in get_tree().get_nodes_in_group("not_signature"):
		node.visible = not is_signature

	loaded_brakes = false
	set_brakes(has_perf_brakes)
	set_drivetrain_type(drivetrain_type)

func set_hide_tesla_badge(hide: bool):
	hide_tesla_badge = hide

	var has_global_rearlight = has_global_rearlight()

	
	

	
	set_node_visible(tesla_badge_global, has_global_rearlight and not hide)

func set_hide_tesla_wordmark(hide: bool):
	hide_tesla_wordmark = hide

	var has_global_rearlight = has_global_rearlight()

	
	

	
	set_node_visible(tesla_wordmark_global, has_global_rearlight and not hide)


func set_fog_lights_on(on):
	fog_lights_on = on
	if has_global_headlamp():
		set_node_visible(fog_lights_global, on)
		set_node_visible(fog_lights_trunk_global, on)
	else:
		.set_fog_lights_on(on)

func set_reverse_lights_on(on):
	reverse_lights_on = on
	var node = reverse_lights_global if has_global_rearlight() else reverse_lights
	set_node_visible(node, on)

func set_turn_signal_r_state(state: int):
	turn_signal_r_state = state
	var on: bool = state == 1
	
	var has_global_headlamp = has_global_headlamp()
	var has_global_rearlight = has_global_rearlight()
	
	set_node_visible(right_turn_signal_front_global, on and has_global_headlamp)
	set_node_visible(right_turn_signal_rear_global, on and has_global_rearlight)
	
	set_node_visible(right_turn_signal_front_original, on and not has_global_headlamp)
	set_node_visible(right_turn_signal_rear_original, on and not has_global_rearlight)
	
func set_turn_signal_l_state(state: int):
	turn_signal_l_state = state
	var on: bool = state == 1
	
	var has_global_headlamp = has_global_headlamp()
	var has_global_rearlight = has_global_rearlight()
	
	set_node_visible(left_turn_signal_front_global, on and has_global_headlamp)
	set_node_visible(left_turn_signal_rear_global, on and has_global_rearlight)
	
	set_node_visible(left_turn_signal_front_original, on and not has_global_headlamp)
	set_node_visible(left_turn_signal_rear_original, on and not has_global_rearlight)
	
func set_drl_on(on):
	drl_on = on
	var node = drl_global if has_global_headlamp() else drl
	set_node_visible(node, on)
	
func set_headlights_on(on):
	headlights_on = on
	
	var has_global_headlamp = has_global_headlamp()
	var has_global_rearlight = has_global_rearlight()
	
	set_node_visible(headlight_front_global, on and has_global_headlamp)
	set_node_visible(headlight_rear_global, on and has_global_rearlight)
	set_node_visible(headlight_trunk_global, on and has_global_rearlight)
	set_node_visible(drl_global, on and has_global_headlamp)
	
	set_node_visible(headlight_front_original, on and not has_global_headlamp)
	set_node_visible(headlight_rear_original, on and not has_global_rearlight)
	set_node_visible(headlight_trunk_original, on and not has_global_rearlight)
	set_node_visible(drl, on and not has_global_headlamp)
	
func set_brake_lights_on(on):
	brake_lights_on = on
	
	if has_global_rearlight():
		set_node_visible(brake_lights_global, on)
		set_node_visible(brake_lights_trunk_global, on)
	else:
		.set_brake_lights_on(on)

func set_charge_port_open(open, animated = false, speed: float = 1.0):
	if charge_port_open == open: return
	charge_port_open = open
	if has_global_rearlight():
		toggle_open(chargeport_global_animation, open, animated, speed)
	else:
		toggle_open(chargeport_animation, open, animated, speed)
	
func has_global_headlamp():
	return headlamp_type == VehicleOptions.HeadlampType.Global

func has_global_rearlight():
	return rearlight_type == VehicleOptions.RearLightType.Global;
