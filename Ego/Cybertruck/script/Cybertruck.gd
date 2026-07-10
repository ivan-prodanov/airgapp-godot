tool 
extends Vehicle

enum ACCESSORY_LIGHTBAR_TYPE{
	NONE = 0, 
	HELLA = 1
}

const Tonneau = preload("res://Ego/Cybertruck/script/Tonneau.gd")

export (Array, NodePath) var marker_locators_paths
export (Array, NodePath) var wheel_marker_locators_paths
export (Array, NodePath) var lock_lights_paths
export (Array, NodePath) var foundation_badges_paths
export (NodePath) var cerberus_decal_path: NodePath
export (NodePath) var headlight_beam_path: NodePath
export (NodePath) var headlights_rear_left_path: NodePath
export (NodePath) var headlights_rear_right_path: NodePath
export (NodePath) var bed_light_path: NodePath
export (NodePath) var bed_light_rwd_path: NodePath
export (NodePath) var truck_bed_path: NodePath
export (NodePath) var truck_bed_rwd_path: NodePath
export (NodePath) var tonneau_path: NodePath
export (NodePath) var screen_rear_path: NodePath
export (NodePath) var center_console_path: NodePath
export (NodePath) var center_console_rwd_path: NodePath
export (NodePath) var headlights_side_right_path: NodePath
export (NodePath) var headlights_side_left_path: NodePath

export (ACCESSORY_LIGHTBAR_TYPE) var accessory_lightbar_type setget set_accessory_lightbar_type
export (bool) var accessory_lightbar_middle_on setget set_accessory_lightbar_middle_on
export (bool) var lock_lights_on setget set_lock_lights_on
export (bool) var parking_lights_on setget set_parking_lights_on
export (bool) var bed_light_on setget set_bed_light_on
export (bool) var is_foundation setget set_is_foundation
export (bool) var has_powered_tonneau setget set_has_powered_tonneau

export (TIME_OF_DAY) var time_of_day setget set_time_of_day

export (bool) var use_mobile_material setget set_use_mobile_material
export (bool) var basecamp_mode setget set_basecamp_mode

export (Dictionary) var glass_skybox_material_to_config_path: Dictionary
export (Dictionary) var glass_sky_box_material_to_mobile_config_path: Dictionary
export (ShaderMaterial) var paint_mix_mat: ShaderMaterial

export (NodePath) var paint_mix_config_path: NodePath
export (NodePath) var paint_mix_mobile_config_path: NodePath

var lock_lights: Array
var foundation_badges: Array
var skin_day: SkinProps = null
var skin_night: SkinProps = null
var skin_daydark: SkinProps = null
var skin_mars: SkinProps = null

var secondary_material_alpha: Dictionary = Dictionary()

onready var cerberus_decal: Spatial = get_node_or_null(cerberus_decal_path)
onready var headlight_beam: Spatial = get_node_or_null(headlight_beam_path)
onready var headlights_rear_left: Spatial = get_node_or_null(headlights_rear_left_path)
onready var headlights_rear_right: Spatial = get_node_or_null(headlights_rear_right_path)
onready var bed_light: Spatial = get_node_or_null(bed_light_path)
onready var bed_light_rwd: Spatial = get_node_or_null(bed_light_rwd_path)
onready var truck_bed: Spatial = get_node_or_null(truck_bed_path)
onready var truck_bed_rwd: Spatial = get_node_or_null(truck_bed_rwd_path)
onready var tonneau: Tonneau = get_node_or_null(tonneau_path)
onready var screen_rear: Spatial = get_node_or_null(screen_rear_path)
onready var center_console: Spatial = get_node_or_null(center_console_path)
onready var center_console_rwd: Spatial = get_node_or_null(center_console_rwd_path)
onready var headlights_side_right: Spatial = get_node_or_null(headlights_side_right_path)
onready var headlights_side_left: Spatial = get_node_or_null(headlights_side_left_path)

onready var paint_mix_config: PaintMixConfig = get_node_or_null(paint_mix_config_path)
onready var paint_mix_mobile_config: PaintMixConfig = get_node_or_null(paint_mix_mobile_config_path)

var headlight_beam_on setget set_headlight_beam_on

var accessory_lightbar: Spatial = null
var accessory_lightbar_fade_materials: Array

const markerResource = preload("res://Ego/Cybertruck/Marker.tscn")
var basecamp_spatial: Spatial = null


var glass_material_secondary_alpha: Dictionary = Dictionary()

func on_window_tint_set(mat: Material, alpha: float):
	var remapped_alpha = lerp(glass_material_secondary_alpha[mat] * 255.0, 255.0, alpha)
	mat.set_shader_param("alpha_perpendicular", remapped_alpha)
	secondary_material_alpha[mat] = remapped_alpha

func on_glass_material_added(mat: Material):
	var base_glass_alpha = mat.get_shader_param("alpha_perpendicular") / 255.0
	var max_glass_alpha = 1.0
	glass_material_secondary_alpha[mat] = clamp((base_glass_alpha - max_glass_alpha * DEFAULT_TINT_PERCENT) / (1.0 - DEFAULT_TINT_PERCENT), 0.0, 1.0)


func get_glass_resource_names():
	return ["GlassSkybox", "Glass_Skybox_Fade", "GlassTintedFadeSkybox", "Glass_Tinted_Skybox_Fade"]

func get_roof_fade_resource_names():
	return ["Fabric_Black_Fade", 
			"Glass_Black_Fade", 
			"Glass_Black_Rough_Fade", 
			"Glass_Fade", 
			"Glass_Interior_Fade", 
			"Glass_Interior_Tinted_Fade", 
			"Glass_Rough_Fade", 
			"Glass_Skybox_Fade", 
			"Glass_Tinted_Fade", 
			"Glass_Tinted_Skybox_Fade", 
			"MIC_Black_Fade", 
			"MIC_Black_Rough_Fade", 
			"Mirror_Fade", 
			"Paint_Black_Fade", 
			"Plastic_Black_Exterior_Fade", 
			"PUR_Black_Fade", 
			"Rubber_Exterior_Fade", 
			"TPO_Black_Fade"]

func get_accessory_lightbar_fade_resource_names():
	return ["Body_Lightbar_Fade", 
			"Extras_Lightbar_Fade", 
			"Glass_Lightbar_Fade", 
			"Reflector_Lightbar_Fade", 
			"Lightbar_Illumination_Fade"]

func on_roof_fade_material_added(mat: Material):
	if mat is ShaderMaterial:
		secondary_material_alpha[mat] = mat.get_shader_param("alpha_perpendicular")

func on_roof_fade_applied(mat: Material, fade: bool, animated: bool, duration: float):
	if not secondary_material_alpha.has(mat): return
	
	var alpha = 0 if fade else secondary_material_alpha[mat]
	if mat is ShaderMaterial:
		if animated:
			tween.interpolate_property(mat, "shader_param/alpha_perpendicular", null, alpha, duration, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		else:
			tween.stop(mat, "shader_param/alpha_perpendicular")
			mat.set_shader_param("alpha_perpendicular", alpha)

func load_skins():
	var colors_path = "res://Ego/Cybertruck/Skin/ct_day_colors.tres"
	var env_path = "res://Ego/Cybertruck/Skin/ct_day_env.tres"
	var name = "CT_Skin_Day"
	skin_day = load_skin(colors_path, env_path, name)
	
	colors_path = "res://Ego/Cybertruck/Skin/ct_night_colors.tres"
	env_path = "res://Ego/Cybertruck/Skin/ct_night_env.tres"
	name = "CT_Skin_Night"
	skin_night = load_skin(colors_path, env_path, name)
	
	colors_path = "res://Ego/Cybertruck/Skin/ct_daydark_colors.tres"
	env_path = "res://Ego/Cybertruck/Skin/ct_daydark_env.tres"
	name = "CT_Skin_Daydark"
	skin_daydark = load_skin(colors_path, env_path, name)
	
	colors_path = "res://Ego/Cybertruck/Skin/ct_mars_colors.tres"
	env_path = "res://Ego/Cybertruck/Skin/ct_mars_env.tres"
	name = "CT_Skin_Mars"
	skin_mars = load_skin(colors_path, env_path, name)
	


func _ready():
	for node_path in marker_locators_paths:
		var marker_locator = get_node_or_null(node_path)
		if marker_locator != null:
			var new_marker_scene = markerResource.instance()
			marker_locator.add_child(new_marker_scene)
			marker_scenes.append(new_marker_scene)
			marker_locators.append(marker_locator)

	for lock_light_path in lock_lights_paths:
		var lock_light = get_node_or_null(lock_light_path)
		if lock_light:
			lock_lights.append(lock_light)

	for foundation_badge_path in foundation_badges_paths:
		var foundation_badge = get_node_or_null(foundation_badge_path)
		if foundation_badge:
			foundation_badges.append(foundation_badge)
	
	skybox_paint_material = paint_mix_mat


	apply_skin_transition_pos_z(100.0)

	
	
	
	
	
	


	load_skins()

func set_is_mobile(_is_mobile: bool):
	.set_is_mobile(_is_mobile)
	set_use_mobile_material(is_mobile)
	if tonneau:
		tonneau.set_is_mobile(_is_mobile)
	
func set_time_of_day(new_time_of_day):
	if time_of_day == new_time_of_day: return
	time_of_day = new_time_of_day
	for marker_scene in marker_scenes:
		if marker_scene.has_method("set_time_of_day"):
			marker_scene.set_time_of_day(time_of_day)

func get_override_skin(time_of_day, solar_angle_time_of_day, mars_mode):
	if mars_mode:
		return skin_mars
	elif (time_of_day == TIME_OF_DAY.DAY):
		return skin_day
	elif (solar_angle_time_of_day == TIME_OF_DAY.DAY):
		return skin_daydark
	else:
		return skin_night


func set_wheel_type_by_gtw_name(gtw_enum_name: String):
	print("CT set_wheel_type_by_gtw_name: " + gtw_enum_name)
	
	
	
	
	var stored_locators: Dictionary
	for wheel_marker_locator_path in wheel_marker_locators_paths:
		var wheel_marker_locator = get_node_or_null(wheel_marker_locator_path)
		if wheel_marker_locator == null: continue
		var wheel_marker_locator_parent = wheel_marker_locator.get_parent()
		if wheel_marker_locator_parent == null: continue
		stored_locators[wheel_marker_locator_parent] = wheel_marker_locator
		wheel_marker_locator_parent.remove_child(wheel_marker_locator)
	
	.set_wheel_type_by_gtw_name(gtw_enum_name)
		
	for wheel_marker_locator_parent in stored_locators:
		wheel_marker_locator_parent.add_child(stored_locators[wheel_marker_locator_parent])
		
func get_launch_mode_scene():
	var beast_mode_scene = preload("res://Ego/Cybertruck/BeastMode/BeastMode.tscn")
	return beast_mode_scene
		
func set_headlight_beam_on(on):
	headlight_beam_on = on
	set_node_visible(headlight_beam, on)
	
func set_drl_on(on):
	.set_drl_on(on)
	set_headlight_beam_on(drl_on or headlights_on or parking_lights_on)
	set_node_visible(drl, drl_on or headlights_on or parking_lights_on)

func set_headlights_on(on):
	.set_headlights_on(on)
	set_headlight_beam_on(drl_on or headlights_on or parking_lights_on)
	set_node_visible(drl, drl_on or headlights_on or parking_lights_on)
	set_node_visible(headlights_rear_left, on or parking_lights_on)
	set_node_visible(headlights_rear_right, on or parking_lights_on)
	set_node_visible(headlights_side_left, on and (turn_signal_l_state != 1) and (drivetrain_type != DrivetrainType.RWD))
	set_node_visible(headlights_side_right, on and (turn_signal_r_state != 1) and (drivetrain_type != DrivetrainType.RWD))
	update_headlights_trunk()
	
func set_turn_signal_l_state(state: int):
	.set_turn_signal_l_state(state)
	set_node_visible(headlights_side_left, headlights_on and (state != 1))
	
func set_turn_signal_r_state(state: int):
	.set_turn_signal_r_state(state)
	set_node_visible(headlights_side_right, headlights_on and (state != 1))
	
func set_is_foundation(foundation):
	if foundation == is_foundation: return
	is_foundation = foundation
	for foundation_badge in foundation_badges:
		set_node_visible(foundation_badge, is_foundation)
	
func set_has_powered_tonneau(_has_powered_tonneau):
	has_powered_tonneau = _has_powered_tonneau
	set_node_visible(tonneau, has_powered_tonneau)
	
func set_drivetrain_type(type):
	if drivetrain_type == type: return
	
	.set_drivetrain_type(type)
	
	if cerberus_decal:
		set_node_visible(cerberus_decal, type == DrivetrainType.AWDTriMotor)
		
	var is_rwd = (type == DrivetrainType.RWD)

	
	set_node_visible(screen_rear, not is_rwd)
	set_node_visible(center_console, not is_rwd)
	set_node_visible(center_console_rwd, is_rwd)
	
	
	set_node_visible(truck_bed, not is_rwd)
	set_node_visible(truck_bed_rwd, is_rwd)
	set_node_visible(bed_light, not is_rwd and bed_light_on)
	set_node_visible(bed_light_rwd, is_rwd and bed_light_on)
	
	
	set_headlights_on(headlights_on)
	
	set_has_powered_tonneau( not is_rwd)
	
func add_accessory_lightbar_fade_materials():
	accessory_lightbar_fade_materials = get_roof_fade_materials(get_accessory_lightbar_fade_resource_names())
	roof_fade_materials += accessory_lightbar_fade_materials
	
func remove_accessory_lightbar_fade_materials():
	for mat in accessory_lightbar_fade_materials:
		if mat in roof_fade_materials:
			roof_fade_materials.erase(mat)
			
	accessory_lightbar_fade_materials = []
	
func set_accessory_lightbar_type(type):
	if accessory_lightbar_type == type: return
	accessory_lightbar_type = type
	
	if accessory_lightbar:
		remove_accessory_lightbar_fade_materials()
		remove_child(accessory_lightbar);
		accessory_lightbar.queue_free();
		accessory_lightbar = null
	
	var lightbar_scene = null
	match type:
		ACCESSORY_LIGHTBAR_TYPE.NONE:
			pass
		ACCESSORY_LIGHTBAR_TYPE.HELLA:
			lightbar_scene = preload("res://Ego/Cybertruck/Lightbar.tscn")
			
	if lightbar_scene != null:
		accessory_lightbar = lightbar_scene.instance()
		add_child(accessory_lightbar)
		set_accessory_lightbar_middle_on(accessory_lightbar_middle_on)
		add_accessory_lightbar_fade_materials()

func set_accessory_lightbar_middle_on(on: bool):
	accessory_lightbar_middle_on = on
	
	if accessory_lightbar:
		var light_node = accessory_lightbar.get_node_or_null("Lightbar_Illumination2")
		if light_node:
			light_node.set_visible(on)

func set_lock_lights_on(on: bool):
	if lock_lights_on == on: return
	lock_lights_on = on
	
	for lock_light in lock_lights:
		set_node_visible(lock_light, on)
		
func update_headlights_trunk():
	var want_headlights_trunk_on = (parking_lights_on or headlights_on) and not brake_lights_on and (drivetrain_type != DrivetrainType.RWD)
	set_node_visible(headlights_trunk, want_headlights_trunk_on)
		
func set_parking_lights_on(on: bool):
	if parking_lights_on == on: return
	parking_lights_on = on

	set_headlight_beam_on(drl_on or headlights_on or parking_lights_on)
	set_node_visible(drl, drl_on or headlights_on or parking_lights_on)
	set_node_visible(headlights_rear_left, on or headlights_on)
	set_node_visible(headlights_rear_right, on or headlights_on)
	update_headlights_trunk()

func set_brake_lights_on(on):
	.set_brake_lights_on(on)
	update_headlights_trunk()

func set_bed_light_on(on: bool):
	if bed_light_on == on: return
	
	bed_light_on = on
	
	var is_rwd = (drivetrain_type == DrivetrainType.RWD)
	set_node_visible(bed_light, on and not is_rwd)
	set_node_visible(bed_light_rwd, on and is_rwd)

func update(data: VehicleData, animated: bool = false, speed: float = 1.0):
	.update(data, animated, speed)
		
	set_accessory_lightbar_type(data.vehicle_config.accessory_lightbar_type)
	set_accessory_lightbar_middle_on(data.vehicle_state.accessory_lightbar_middle_on)
	set_basecamp_mode(data.vehicle_state.basecamp_mode_on)
	set_drivetrain_type(data.vehicle_config.drivetrain_type)

	if has_powered_tonneau:
		tonneau.set_open_percentage(data.vehicle_state.tn, animated)

func on_snapshot(pose_settings):
	if not is_mobile:
		return
	set_wheel_turn_deg(pose_settings.get("wheel_turn_deg", 0))

func set_wheel_turn_deg(deg: int):
	if not lf_wheel or not rf_wheel:
		return
	var lf_wheel_child = lf_wheel.get_child(0)
	var rf_wheel_child = rf_wheel.get_child(0)

	if not lf_wheel_child or not rf_wheel_child:
		return
		
	if int(rf_wheel_child.rotation_degrees.y) == deg:
		return
	lf_wheel_child.rotation_degrees.y = deg
	rf_wheel_child.rotation_degrees.y = deg

func set_basecamp_mode(use_basecamp: bool):
	if use_basecamp == basecamp_mode: return
	basecamp_mode = use_basecamp
	
	if use_basecamp:
		var basecamp_scene = preload("res://Ego/Cybertruck/BaseCamp.tscn")
		basecamp_spatial = basecamp_scene.instance()
		add_child(basecamp_spatial)
	else:
		remove_child(basecamp_spatial);
		basecamp_spatial.queue_free();
		basecamp_spatial = null
		
func set_interior_config(interior):
	var decor_mat: SpatialMaterial
	match (interior):
		VehicleOptions.InteriorConfig.White:
			decor_mat = load("res://" + local_dir + "/Decor_White.material")
		VehicleOptions.InteriorConfig.TacticalGrey:
			decor_mat = load("res://" + local_dir + "/Decor_Tactical_Grey.material")
	if decor_mat: apply_material(self, decor_mat, "Decor", true)

func set_use_mobile_material(use_mobile: bool):
	print("[USE MOBILE MATERIAL] use_mobile ", use_mobile)
	use_mobile_material = use_mobile

	var curr_paint_mix_config = paint_mix_mobile_config if use_mobile else paint_mix_config
	var curr_glass_skybox_material_config_path = glass_sky_box_material_to_mobile_config_path if use_mobile else glass_skybox_material_to_config_path
	if curr_paint_mix_config == null:
		print("[USE MOBILE MATERIAL] curr_paint_mix_config is null", use_mobile)
	else:
		apply_paint_mix_config(curr_paint_mix_config)
	for material_path in curr_glass_skybox_material_config_path:
		var material = load(material_path)
		var config_path = curr_glass_skybox_material_config_path[material_path]
		var config = get_node_or_null(config_path)
		if material == null:
			print("[USE MOBILE MATERIAL] cannot load ", material_path)
			continue
		if config == null:
			print("[USE MOBILE MATERIAL] cannot load ", config_path)
			continue
		apply_glass_skybox_config(material, config)

func apply_paint_mix_config(config: PaintMixConfig):
	paint_mix_mat.set_shader_param("color_bright", config.color_bright)
	paint_mix_mat.set_shader_param("color_dark", config.color_dark)
	paint_mix_mat.set_shader_param("color_away_and_up", config.color_away_and_up)
	paint_mix_mat.set_shader_param("metallic_bright", config.metallic_bright)
	paint_mix_mat.set_shader_param("metallic_dark", config.metallic_dark)
	paint_mix_mat.set_shader_param("metallic_away_and_up", config.metallic_away_and_up)
	paint_mix_mat.set_shader_param("roughness_bright", config.roughness_bright)
	paint_mix_mat.set_shader_param("roughness_dark", config.roughness_dark)
	paint_mix_mat.set_shader_param("roughness_away_and_up", config.roughness_away_and_up)

func apply_glass_skybox_config(material: ShaderMaterial, config: GlassSkyboxConfig):
	material.set_shader_param("roughness_parallel", config.roughness_parallel)
	material.set_shader_param("roughness_perpendicular", config.roughness_perpendicular)
	material.set_shader_param("specular", config.specular)
	material.set_shader_param("alpha_perpendicular", config.alpha_perpendicular)

func set_default_state(animated: bool = false):
	.set_default_state(animated)
	
	if tonneau:
		tonneau.set_open_percentage(0, false)
	set_accessory_lightbar_middle_on(false)
	set_basecamp_mode(false)

func has_two_toned_color() -> bool:
	return true
	
func enable_license_plate_noise() -> bool:
	return false

func set_paint_color_by_name(color_key: String):
	print("set_paint_color_by_name for cybertruck ", color_key, " previous value ", paint_color_name)

	if paint_color_name == color_key: return

	paint_color_name = color_key
	paint_color_override = String()

	apply_paint_mix_config(paint_mix_config)

func calculate_color_dark(rgb_color_bright) -> Color:
	var difference = paint_mix_config.color_dark.v - paint_mix_config.color_bright.v
	var hsv_color = rgb_color_bright
	hsv_color.v += difference

	return hsv_color

func calculate_color_away_and_up(rgb_color_bright) -> Color:
	var hsv_color = rgb_color_bright
	hsv_color.v = paint_mix_config.color_away_and_up.v

	return hsv_color

func calculate_metallic_dark(metallic_bright) -> float:
	var difference = paint_mix_config.metallic_dark - paint_mix_config.metallic_bright
	return metallic_bright + difference

func calculate_metallic_away_and_up(metallic_bright) -> float:
	var difference = paint_mix_config.metallic_away_and_up - paint_mix_config.metallic_bright
	return metallic_bright + difference

func calculate_roughness_dark(roughness_bright) -> float:
	var difference = paint_mix_config.roughness_dark - paint_mix_config.roughness_bright
	return roughness_bright + difference

func calculate_roughness_away_and_up(roughness_bright) -> float:
	var difference = paint_mix_config.roughness_away_and_up - paint_mix_config.roughness_bright
	return roughness_bright + difference

func copy_common_paint_skybox_params(from_material: ShaderMaterial, to_material: ShaderMaterial):
	copy_shader_param(from_material, "metallic_bright", to_material, "metallic_bright")
	copy_shader_param(from_material, "metallic_dark", to_material, "metallic_dark")
	copy_shader_param(from_material, "metallic_away_and_up", to_material, "metallic_away_and_up")
	copy_shader_param(from_material, "roughness_bright", to_material, "roughness_bright")
	copy_shader_param(from_material, "roughness_dark", to_material, "roughness_dark")
	copy_shader_param(from_material, "roughness_away_and_up", to_material, "roughness_away_and_up")
	copy_shader_param(from_material, "color_bright", to_material, "color_bright")
	copy_shader_param(from_material, "color_dark", to_material, "color_dark")
	copy_shader_param(from_material, "color_away_and_up", to_material, "color_away_and_up")
	copy_shader_param(from_material, "blend_start", to_material, "blend_start")
	copy_shader_param(from_material, "blend_end", to_material, "blend_end")
	copy_shader_param(from_material, "ao", to_material, "ao")

