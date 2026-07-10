tool 
extends Spatial

enum ExteriorTrim{
	Original = 0, 
	Black = 1
}

const ExteriorTrimMap: Dictionary = {
	"Chrome": ExteriorTrim.Original, 
	"Black": ExteriorTrim.Black, 
}


enum DrivetrainType{
	None = 0, 
	RWD = 1, 
	AWD = 2, 
	AWDTriMotor = 3, 
}


enum MaterialMatchMode{
	NODE_ONLY = 0, 
	MESH_ONLY = 1, 
	NODE_THEN_MESH = 2
}


enum BadgingVersion{
	V0 = 0, 
	V1 = 1, 
	V2 = 2
}

enum TIME_OF_DAY{DAY = 0, NIGHT = 1}

class_name Vehicle

const ChargeCable = preload("res://mobile/geometry/Charging_Cable/ChargeCable.gd")
const VehicleOptions = preload("res://mobile/scripts/VehicleOptions.gd")
const VehicleData = preload("res://mobile/scripts/data/VehicleData.gd")
const Airflow = preload("res://mobile/scripts/Airflow.gd")
const DefrostFront = preload("res://mobile/scripts/DefrostFront.gd")
const DefrostRear = preload("res://mobile/scripts/DefrostRear.gd")
const powershare_home_node: NodePath = NodePath("res://Energy/Load/Residential/Modern/GarageForVehiclePowershare.tscn")

signal on_vehicle_update(vehicle, vehicle_data)





signal vehicle_lights_changed(vehicle)


var vehicle_id: String
var vehicle_data: VehicleData


var force_doors_closed: bool setget set_force_doors_closed
export (bool) var is_loading setget set_is_loading
export (bool) var is_driving setget set_is_driving


export (float, 0, 2) var vehicle_scale = 0


export (bool) var hood_open setget set_hood_open
export (bool) var trunk_open setget set_trunk_open
export (bool) var lf_door_open setget set_lf_door_open
export (bool) var lr_door_open setget set_lr_door_open
export (bool) var rf_door_open setget set_rf_door_open
export (bool) var rr_door_open setget set_rr_door_open
export (bool) var charge_port_open setget set_charge_port_open


export (bool) var show_fx_above setget set_show_fx_above
export (bool) var airflow_on setget set_airflow_on
export (bool) var defrost_front_on setget set_defrost_front_on
export (bool) var defrost_rear_on setget set_defrost_rear_on
export (bool) var fade_roof setget set_fade_roof


export (bool) var fog_lights_on setget set_fog_lights_on
export (bool) var reverse_lights_on setget set_reverse_lights_on
export (int) var turn_signal_r_state setget set_turn_signal_r_state
export (int) var turn_signal_l_state setget set_turn_signal_l_state
export (bool) var drl_on setget set_drl_on
export (bool) var headlights_on setget set_headlights_on
export (bool) var brake_lights_on setget set_brake_lights_on


export (bool) var has_perf_brakes setget set_brakes
export (bool) var has_spoiler setget set_has_spoiler
export (bool) var has_us_plate setget set_has_us_plate
export (bool) var has_eu_plate setget set_has_eu_plate
export (VehicleOptions.WheelType) var wheel_type setget set_wheel_type
export (VehicleOptions.InteriorConfig) var interior_config setget set_interior_config
export (VehicleOptions.FasciaType) var fascia_type setget set_fascia_type
export (bool) var RHD setget set_rhd
export (DrivetrainType) var drivetrain_type setget set_drivetrain_type
var interior_upper_trim_type: int setget set_interior_upper_trim_type
var badging_material_type: int setget set_badging_material_type


var interior_upper_trim_materials = {}

const badging_materials = {
	VehicleOptions.BadgingMaterialType.CHROME_SILVER: "res://Ego/Shared/Badging_Chrome.tres", 
	VehicleOptions.BadgingMaterialType.BLACK_MATTE: "res://Ego/Shared/Badging_Black.tres"
}


export (float, 0, 10) var skybox_intensity setget set_skybox_intensity
export (bool) var skybox_enable setget set_skybox_enable
export (CubeMap) var skybox setget set_skybox
export (bool) var use_mobile_shadows setget set_use_mobile_shadows
const tex_zero_alpha = preload("res://mobile/materials/zero_alpha.png")


export (bool) var hide_wheels setget hide_wheels


export (bool) var allow_sourcing_roof_fade_material_from_mesh setget set_allow_sourcing_roof_fade_material_from_mesh


export (bool) var is_mobile setget set_is_mobile


export (float) var charging_cable_alpha_decrease_offset_begin = 1.0
export (float) var charging_cable_alpha_decrease_offset_end = 1.0


export (bool) var colorizer_paint_remap_enabled setget set_colorizer_paint_remap_enabled


export (bool) var adjust_paint_rough_for_skins: bool = true
export (ShaderMaterial) var paint_overlay_material: ShaderMaterial

var paint_overlay_material2: ShaderMaterial
var current_skin: String
var active_transition_skin: String
export (String) var desired_skin: String setget set_car_skin
var skin_transition_in_progress: bool = false
var skin_transition_pct: float = 0.0
var skin_transition_tween: Tween = Tween.new()
const SKIN_CHANGE_DURATION: float = 1.5
var latest_skin_texture: Texture
export (float) var max_skin_alpha = 0.35

var window_tint: String
var DEFAULT_TINT_PERCENT: float = 0.6
export (float) var max_tint_color: float = 0.018
var glass_material_to_color_map: Dictionary



export (NodePath) var body_path: NodePath
export (NodePath) var ground_shadow_path: NodePath
export (NodePath) var spoiler_path: NodePath
export (NodePath) var plate_us_path: NodePath
export (NodePath) var plate_eu_path: NodePath
export (NodePath) var plate_viewport_path: NodePath
export (NodePath) var fog_lights_path: NodePath
export (NodePath) var reverse_lights_path: NodePath
export (NodePath) var turn_signal_r_path: NodePath
export (NodePath) var turn_signal_l_path: NodePath
export (NodePath) var drl_path: NodePath
export (NodePath) var headlights_path: NodePath
export (NodePath) var headlights_trunk_path: NodePath
export (NodePath) var brake_lights_l_path: NodePath
export (NodePath) var brake_lights_r_path: NodePath
export (NodePath) var brake_lights_center_path: NodePath
export (NodePath) var taillights_projection_path: NodePath
export (NodePath) var headlights_projection_path: NodePath
export (NodePath) var charge_port_path: NodePath
export (NodePath) var lf_door_path: NodePath
export (NodePath) var lr_door_path: NodePath
export (NodePath) var rf_door_path: NodePath
export (NodePath) var rr_door_path: NodePath
export (NodePath) var trunk_path: NodePath
export (NodePath) var hood_path: NodePath
export (NodePath) var lf_wheel_path: NodePath
export (NodePath) var lr_wheel_path: NodePath
export (NodePath) var rf_wheel_path: NodePath
export (NodePath) var rr_wheel_path: NodePath
export (NodePath) var front_marker_path: NodePath
export (NodePath) var rear_marker_path: NodePath

export (NodePath) var lf_brake_path: NodePath
export (NodePath) var lr_brake_path: NodePath
export (NodePath) var rf_brake_path: NodePath
export (NodePath) var rr_brake_path: NodePath

export (NodePath) var interior_rhd_path: NodePath
export (NodePath) var interior_lhd_path: NodePath
export (String) var local_dir
export (PackedScene) var brakes_standard_front_left: PackedScene
export (PackedScene) var brakes_standard_rear_left: PackedScene
export (PackedScene) var brakes_standard_front_right: PackedScene
export (PackedScene) var brakes_standard_rear_right: PackedScene
export (PackedScene) var brakes_perf_front_left: PackedScene
export (PackedScene) var brakes_perf_rear_left: PackedScene
export (PackedScene) var brakes_perf_front_right: PackedScene
export (PackedScene) var brakes_perf_rear_right: PackedScene
export (NodePath) var defrost_front_path: NodePath
export (NodePath) var defrost_rear_path: NodePath


onready var body: MeshInstance = get_node(body_path)
onready var ground_shadow: MeshInstance = get_node_or_null(ground_shadow_path)
onready var spoiler: MeshInstance = get_node_or_null(spoiler_path)
onready var plate_us: MeshInstance = get_node_or_null(plate_us_path)
onready var plate_eu: MeshInstance = get_node_or_null(plate_eu_path)
onready var fog_lights: MeshInstance = get_node_or_null(fog_lights_path)
onready var reverse_lights: Spatial = get_node_or_null(reverse_lights_path)
onready var turn_signal_r: MeshInstance = get_node_or_null(turn_signal_r_path)
onready var turn_signal_l: MeshInstance = get_node_or_null(turn_signal_l_path)
onready var drl: MeshInstance = get_node_or_null(drl_path)
onready var headlights: Spatial = get_node_or_null(headlights_path)
onready var headlights_trunk: MeshInstance = get_node_or_null(headlights_trunk_path)
onready var brake_lights_l: Spatial = get_node_or_null(brake_lights_l_path)
onready var brake_lights_r: Spatial = get_node_or_null(brake_lights_r_path)
onready var brake_lights_center: Spatial = get_node_or_null(brake_lights_center_path)
onready var taillights_projection: Spatial = get_node_or_null(taillights_projection_path)
onready var headlights_projection: MeshInstance = get_node_or_null(headlights_projection_path)
onready var lf_door: MeshInstance = get_node_or_null(lf_door_path)
onready var lr_door: MeshInstance = get_node_or_null(lr_door_path)
onready var rf_door: MeshInstance = get_node_or_null(rf_door_path)
onready var rr_door: MeshInstance = get_node_or_null(rr_door_path)
onready var trunk: MeshInstance = get_node_or_null(trunk_path)
onready var hood: MeshInstance = get_node_or_null(hood_path)
onready var interior_rhd: MeshInstance = get_node_or_null(interior_rhd_path)
onready var interior_lhd: MeshInstance = get_node_or_null(interior_lhd_path)


onready var charge_port: Spatial = get_node_or_null(charge_port_path)
onready var lf_wheel: Spatial = get_node_or_null(lf_wheel_path)
onready var lr_wheel: Spatial = get_node_or_null(lr_wheel_path)
onready var rf_wheel: Spatial = get_node_or_null(rf_wheel_path)
onready var rr_wheel: Spatial = get_node_or_null(rr_wheel_path)


export (VehicleOptions.ExteriorColor) var paint_color setget set_paint_color


onready var airflow_left: Spatial = get_node_or_null("Spatials/Airflow_left")
onready var airflow_right: Spatial = get_node_or_null("Spatials/Airflow_right")
onready var defrost_front: Spatial = get_node_or_null(defrost_front_path)
onready var defrost_rear: Spatial = get_node_or_null(defrost_rear_path)


onready var hood_animation: AnimationPlayer = get_node_or_null("HoodAnimation")
onready var trunk_animation: AnimationPlayer = get_node_or_null("TrunkAnimation")
onready var lf_door_animation: AnimationPlayer = get_node_or_null("LFDoorAnimation")
onready var lr_door_animation: AnimationPlayer = get_node_or_null("LRDoorAnimation")
onready var rf_door_animation: AnimationPlayer = get_node_or_null("RFDoorAnimation")
onready var rr_door_animation: AnimationPlayer = get_node_or_null("RRDoorAnimation")
onready var lf_window_animation: AnimationPlayer = get_node_or_null("LFWindowAnimation")
onready var lr_window_animation: AnimationPlayer = get_node_or_null("LRWindowAnimation")
onready var rf_window_animation: AnimationPlayer = get_node_or_null("RFWindowAnimation")
onready var rr_window_animation: AnimationPlayer = get_node_or_null("RRWindowAnimation")
onready var chargeport_animation: AnimationPlayer = get_node_or_null("ChargeportAnimation")


onready var tween: Tween = get_node("Spatials/Tween")
var roof_fade_materials: Array
var original_material_alpha: Dictionary = Dictionary()


var powershare_home_node_name: String = "Garage"
signal fade_garage
signal update_powershare_wires


var skybox_paint_material: ShaderMaterial
var skybox_paint_material2: ShaderMaterial
var glass_skybox: ShaderMaterial
var glass_tint_skybox: ShaderMaterial
var glass_fade_skybox: ShaderMaterial
var glass_fade_tint_skybox: ShaderMaterial
var paint_fade_material: SpatialMaterial
var paint_rough_material: SpatialMaterial
var plate_texture_material: ShaderMaterial
var plate_material: SpatialMaterial


onready var ghost_material: ShaderMaterial = load("res://mobile/materials/loading.material")


var LOADING_ANIMATION_DURATION: float = 0.3


var wheel_model_path_override: String

var loaded_wheels = false;
var loaded_brakes = false;
var paint_color_name = null
var paint_color_override: String
var active_paint_material_config: Dictionary
var plate_background_color_override: String
var plate_font_color_override: String
var imported_scene_hierarchy_normalized: bool = false


onready var plate_viewport: Viewport = get_node_or_null(plate_viewport_path)


var marker_scenes: Array
var marker_locators: Array
onready var front_marker: Spatial = get_node_or_null(front_marker_path)
onready var rear_marker: Spatial = get_node_or_null(rear_marker_path)

var charger_scene = null

func load_skin(colors_path, env_path, name):
	print("Loading skin ", name)
	var colors = load(colors_path)
	var env = load(env_path)
	var new_skin = SkinProps.new()
	new_skin.suppress_skin_update = true
	if (is_inside_tree()):
		var parent_ego_node = get_parent()
		var vis_node = parent_ego_node.get_parent()
		if vis_node:
			vis_node.add_child(new_skin)
	new_skin.set_skin_env(env)
	new_skin.set_skin_colors(colors)
	new_skin.name = name
	new_skin.suppress_skin_update = false
	return new_skin

func get_vehicle_scale():
	return (vehicle_scale if vehicle_scale > 0.0 else 1.1);

func in_editor():
	return get_tree().edited_scene_root == self;

func set_is_mobile(_is_mobile: bool):
	is_mobile = _is_mobile
	if is_mobile: apply_screen_material(true)
	set_skybox_enable( not is_mobile)

func set_colorizer_paint_remap_enabled(enabled: bool):
	if enabled == colorizer_paint_remap_enabled: return
	colorizer_paint_remap_enabled = enabled
	set_paint_color_override(paint_color_override, true)

func _get_property_list() -> Array:
	return [
		Utils.editor_enum_property("interior_upper_trim_type", VehicleOptions.InteriorUpperTrimType), 
		Utils.editor_enum_property("badging_material_type", VehicleOptions.BadgingMaterialType)
	]

func _enter_tree():
	_normalize_extra_import_root()
	set_interior_upper_trim_type(interior_upper_trim_type, true)
	set_badging_material_type(badging_material_type, true)

func _normalize_extra_import_root():
	if imported_scene_hierarchy_normalized:
		return
	imported_scene_hierarchy_normalized = true

	var expected_names = _get_expected_import_child_names()
	if expected_names.empty():
		return

	var wrapper = _find_extra_import_root(expected_names)
	if wrapper == null:
		return

	print("[Vehicle] Normalizing extra imported GLB root '%s' under %s" % [wrapper.name, name])
	var children = wrapper.get_children()
	for child in children:
		var global_transform = Transform()
		var has_spatial_transform = child is Spatial
		if has_spatial_transform:
			global_transform = child.global_transform

		if has_node(child.name):
			var existing = get_node(child.name)
			_merge_imported_node(existing, child)
			wrapper.remove_child(child)
			child.queue_free()
		else:
			wrapper.remove_child(child)
			add_child(child)
			if has_spatial_transform:
				child.global_transform = global_transform

	remove_child(wrapper)
	wrapper.queue_free()

func _get_expected_import_child_names() -> Array:
	var names = []
	var paths = [
		body_path,
		ground_shadow_path,
		reverse_lights_path,
		turn_signal_r_path,
		turn_signal_l_path,
		drl_path,
		headlights_path,
		taillights_projection_path,
		headlights_projection_path,
		lf_door_path,
		lr_door_path,
		rf_door_path,
		rr_door_path,
		trunk_path,
		hood_path,
		lf_wheel_path,
		lr_wheel_path,
		rf_wheel_path,
		rr_wheel_path,
		lf_brake_path,
		lr_brake_path,
		rf_brake_path,
		rr_brake_path
	]

	for path in paths:
		var first_name = _first_local_node_name(path)
		if first_name != "" and not names.has(first_name):
			names.append(first_name)

	return names

func _first_local_node_name(path: NodePath) -> String:
	var raw_path = str(path)
	if raw_path == "":
		return ""

	var parts = raw_path.split("/", false)
	var skip_next_root = false
	for part in parts:
		if part == "." or part == "":
			continue
		if part == "..":
			skip_next_root = true
			continue
		if skip_next_root and part == name:
			skip_next_root = false
			continue
		return part

	return ""

func _find_extra_import_root(expected_names: Array) -> Node:
	if _has_valid_direct_import_root():
		return null

	var best_child = null
	var best_matches = 0
	for child in get_children():
		var matches = 0
		for expected_name in expected_names:
			if child.has_node(expected_name):
				matches += 1
		if matches > best_matches:
			best_child = child
			best_matches = matches

	if best_matches < 2:
		return null

	return best_child

func _has_valid_direct_import_root() -> bool:
	var direct_body = get_node_or_null(body_path)
	if direct_body is MeshInstance:
		return direct_body.mesh != null

	return false

func _merge_imported_node(existing: Node, imported: Node):
	if existing is MeshInstance and imported is MeshInstance:
		if existing.mesh == null:
			existing.mesh = imported.mesh
		var existing_skin = existing.get("skin")
		var imported_skin = imported.get("skin")
		if existing_skin == null and imported_skin != null:
			existing.set("skin", imported_skin)

	if existing is Spatial and imported is Spatial:
		var imported_children = imported.get_children()
		for child in imported_children:
			var global_transform = Transform()
			var has_spatial_transform = child is Spatial
			if has_spatial_transform:
				global_transform = child.global_transform

			imported.remove_child(child)
			existing.add_child(child)
			if has_spatial_transform:
				child.global_transform = global_transform

func _ready():
	duplicate_materials(self, get_roof_fade_resource_names(), Dictionary())
	apply_skybox_materials()
	apply_plate_material()
	roof_fade_materials = get_roof_fade_materials(get_roof_fade_resource_names())
	set_default_state()


	
	if paint_overlay_material == null:
		paint_overlay_material = load("res://shaders/paint_skybox_overlay.tres")
	add_child(skin_transition_tween)
	skin_transition_tween.connect("tween_all_completed", self, "skin_transition_tween_completed")
	apply_skin_transition_pos_z(100.0)
	paint_overlay_material2 = paint_overlay_material.duplicate()

	var glass_materials = get_materials_from_resource_names(get_glass_resource_names())
	add_glass_materials_to_map(glass_materials)


func set_allow_sourcing_roof_fade_material_from_mesh(allow_source_from_mesh: bool):
	allow_sourcing_roof_fade_material_from_mesh = allow_source_from_mesh
	



func load_material(name: String):
	var material_path: String = name
	if not name.begins_with("res://"):
		material_path = "res://%s/%s" % [local_dir, name]

	
	if not material_path.ends_with(".material") and not material_path.ends_with(".tres"):
		if ResourceLoader.exists(material_path + ".material"):
			material_path += ".material"
		elif ResourceLoader.exists(material_path + ".tres"):
			material_path += ".tres"

	if not ResourceLoader.exists(material_path):
		push_warning("Material not found: %s" % material_path)
		return null

	return load(material_path)

func apply_skybox_materials():
	skybox_paint_material = load_material("PaintSkybox")
	skybox_paint_material2 = load_material("PaintSkybox2")
	glass_skybox = load_material("Glass_Skybox")
	glass_tint_skybox = load_material("Glass_Tinted_Skybox")
	paint_fade_material = load_material("Paint_Fade")
	paint_rough_material = load_material("Paint_Rough")
	glass_fade_skybox = load_material("Glass_Fade_Skybox")
	glass_fade_tint_skybox = load_material("Glass_Tinted_Fade_Skybox")
	
	
	
	if not in_editor():
		if skybox_paint_material != null:
			skybox_paint_material = skybox_paint_material.duplicate()
		if skybox_paint_material2 != null:
			skybox_paint_material2 = skybox_paint_material2.duplicate()
		if glass_skybox != null:
			glass_skybox = glass_skybox.duplicate()
		if glass_tint_skybox != null:
			glass_tint_skybox = glass_tint_skybox.duplicate()
		if paint_fade_material != null:
			paint_fade_material = paint_fade_material.duplicate()
		if paint_rough_material != null:
			paint_rough_material = paint_rough_material.duplicate()
		if glass_fade_skybox != null:
			glass_fade_skybox = glass_fade_skybox.duplicate()
		if glass_fade_tint_skybox != null:
			glass_fade_tint_skybox = glass_fade_tint_skybox.duplicate()

	
	if skybox_paint_material != null:
		apply_material(self, skybox_paint_material, "PaintSkybox");
		apply_material(self, skybox_paint_material, "Paint");
		
	if skybox_paint_material2 != null:
		apply_material(self, skybox_paint_material2, "PaintSkybox2");
		apply_material(self, skybox_paint_material2, "Paint2");
		
	if paint_fade_material != null:
		apply_material(self, paint_fade_material, "PaintFade");

	if paint_rough_material != null:
		apply_material(self, paint_rough_material, "PaintRough");

	if glass_skybox != null:
		apply_material(self, glass_skybox, "GlassSkybox");
		apply_material(self, glass_skybox, "Glass");
	
	if glass_tint_skybox != null:
		apply_material(self, glass_tint_skybox, "GlassTintedSkybox");
		apply_material(self, glass_tint_skybox, "Glass_Tinted");
	
	if glass_fade_skybox != null:
		apply_material(self, glass_fade_skybox, "GlassFadeSkybox");
		apply_material(self, glass_fade_skybox, "Glass_Fade");

	if glass_fade_tint_skybox != null:
		apply_material(self, glass_fade_tint_skybox, "GlassTintedFadeSkybox");
		apply_material(self, glass_fade_tint_skybox, "Glass_Tinted_Fade");

func apply_screen_material(dark: bool):
	var mat: SpatialMaterial
	if not dark:
		mat = load_material("Screen")
	elif dark:
		mat = load_material("Screen_Night")
	
	if mat == null: return
	if not in_editor():
		mat = mat.duplicate()
	apply_material(self, mat, "Screen");

func apply_plate_material():
	if plate_texture_material == null:
		plate_texture_material = load_material("Plate_Texture")
		if not in_editor() and plate_texture_material != null:
			plate_texture_material = plate_texture_material.duplicate()
			
	if plate_material == null:
		plate_material = load_material("Plates")
		if not in_editor() and plate_material != null:
			plate_material = plate_material.duplicate()
			
	if plate_texture_material != null:
		var plate_texture = plate_viewport.get_child(0)
		if plate_texture != null:
			plate_texture.material = plate_texture_material
	
	if plate_material != null:
		apply_material(self, plate_material, "Plates", true);
		




func apply_material(node, material, material_name, match_mode = MaterialMatchMode.NODE_ONLY):
	
	if match_mode is bool:
		match_mode = MaterialMatchMode.MESH_ONLY if match_mode else MaterialMatchMode.NODE_ONLY

	for i in node.get_child_count():
		apply_material(node.get_child(i), material, material_name, match_mode)

	if not node is MeshInstance:
		return

	var check_node = match_mode != MaterialMatchMode.MESH_ONLY
	var check_mesh = match_mode != MaterialMatchMode.NODE_ONLY
	if node.mesh == null:
		return
	var num_surfaces: int = node.mesh.get_surface_count()
	for index in num_surfaces:
		var mat: Material = null
		if check_node:
			mat = node.get_surface_material(index)
		if check_mesh and mat == null:
			mat = node.mesh.surface_get_material(index)
		if mat == null:
			continue
		if mat.get_name() == material_name or mat.resource_name == material_name:
			node.set_surface_material(index, material)

func set_vehicle_data(data: VehicleData):
	if data == null: return
	
	vehicle_data = data
	vehicle_id = data.id
	
func update(data: VehicleData, animated: bool = false, speed: float = 1.0):
	if data == null: return
	set_vehicle_data(data)
	
	set_has_eu_plate(data.vehicle_config.eu_vehicle)
	set_paint_color_with_override(data.vehicle_config.exterior_color, data.vehicle_config.paint_color_override)
	set_colorizer_paint_remap_enabled(data.vehicle_state.colorizer_paint_remap_enabled)
	set_has_spoiler(data.vehicle_config.spoiler_type != "None")
	set_wheel_type_by_name_with_vehicle_default(data.vehicle_config.wheel_type, data.vehicle_config.car_type)
	set_interior_type(data.vehicle_config.interior_trim_type)
	set_rhd(data.vehicle_config.rhd)
	set_brakes(data.vehicle_config.red_brake_calipers)
	
	if RHD:
		set_lf_door_open(false if force_doors_closed else data.vehicle_state.pf, animated, speed)
		set_lr_door_open(false if force_doors_closed else data.vehicle_state.pr, animated, speed)
		set_rf_door_open(false if force_doors_closed else data.vehicle_state.df, animated, speed)
		set_rr_door_open(false if force_doors_closed else data.vehicle_state.dr, animated, speed)
	else:
		set_lf_door_open(false if force_doors_closed else data.vehicle_state.df, animated, speed)
		set_lr_door_open(false if force_doors_closed else data.vehicle_state.dr, animated, speed)
		set_rf_door_open(false if force_doors_closed else data.vehicle_state.pf, animated, speed)
		set_rr_door_open(false if force_doors_closed else data.vehicle_state.pr, animated, speed)
		
	set_hood_open(false if force_doors_closed else data.vehicle_state.ft, animated, speed)
	set_trunk_open(false if force_doors_closed else data.vehicle_state.rt, animated, speed)
	set_charge_port_open(data.charge_state.charge_port_door_open, animated, speed)
	set_is_loading(data.isLoading())
	set_is_driving(data)
	update_airflow_state(data)
	update_defrost_state(data)
	update_charge_state(data)
	match data.vehicle_config.fascia_type:
		"original":
			set_fascia_type(VehicleOptions.FasciaType.BASE)
		"basePoppyseed":
			set_fascia_type(VehicleOptions.FasciaType.POPPYSEED_BASE)
		"performancePoppyseed":
			set_fascia_type(VehicleOptions.FasciaType.POPPYSEED_PERF)
		"d50Poppyseed":
			set_fascia_type(VehicleOptions.FasciaType.POPPYSEED_D50)
		"baseBayberry":
			set_fascia_type(VehicleOptions.FasciaType.BAYBERRY)
		"performanceBayberry":
			set_fascia_type(VehicleOptions.FasciaType.BAYBERRY_PERF)
		"e41Bayberry":
			set_fascia_type(VehicleOptions.FasciaType.BAYBERRY_E41)
	
	set_car_skin(data.car_wrap_state.skin, true)
	set_window_tint(data.vehicle_config.window_tint_color)
	set_interior_upper_trim_type(data.vehicle_config.interior_upper_trim_materials)
	if data.vehicle_config.badging_material_type >= 0:
		set_badging_material_type(data.vehicle_config.badging_material_type)
	else:
		if data.vehicle_config.badge_version <= BadgingVersion.V1:
			set_badging_material_type(VehicleOptions.BadgingMaterialType.CHROME_SILVER)
		else:
			set_badging_material_type(VehicleOptions.BadgingMaterialType.BLACK_MATTE)
	emit_signal("on_vehicle_update", self, data)

func set_default_state(animated: bool = false):
	vehicle_data = null
	paint_color_name = null
	paint_color_override = String()
	set_force_doors_closed(false, animated)

	set_fog_lights_on(false)
	set_reverse_lights_on(false)
	set_turn_signal_l_state(0)
	set_turn_signal_r_state(0)
	set_drl_on(false)
	set_headlights_on(false)
	set_brake_lights_on(false)
	set_has_spoiler(false)
	set_charge_port_open(false)
	set_skybox_intensity(0)

	set_lf_door_open(false, animated)
	set_lr_door_open(false, animated)
	set_rf_door_open(false, animated)
	set_rr_door_open(false, animated)
	set_hood_open(false, animated)
	set_trunk_open(false, animated)
	set_charge_port_open(false, animated)
	set_airflow_on(false)
	set_defrost_front_on(false)
	set_defrost_rear_on(false)
	set_show_fx_above(false)
	set_fade_roof(false, animated)
	
	remove_any_chargers()
	remove_powershare_home()
	

func set_is_loading(loading):
	if is_loading == loading: return
	is_loading = loading
	play_loading_state_animation(loading)

func play_loading_state_animation(loading):
	var ground_shadow_mat = null
	if ground_shadow != null:
		ground_shadow_mat = ground_shadow.get_surface_material(0)

	if loading:
		if tween != null:
			tween.interpolate_callback(
				self, 
				LOADING_ANIMATION_DURATION, 
				"set_material_override", 
				self, 
				ghost_material, 
				ground_shadow.name if ground_shadow != null else "")
			tween.interpolate_property(
				ghost_material, 
				"shader_param/darkness", 
				ghost_material.get_shader_param("darkness"), 
				1, 
				LOADING_ANIMATION_DURATION, 
				Tween.TRANS_CUBIC, 
				Tween.EASE_OUT, 
				LOADING_ANIMATION_DURATION)

		if ground_shadow_mat != null and tween != null:
			tween.interpolate_property(
				ground_shadow_mat, 
				"albedo_color", 
				ground_shadow_mat.albedo_color, 
				Color(1.0, 1.0, 1.0, 0.0), 
				LOADING_ANIMATION_DURATION, 
				Tween.TRANS_CUBIC, 
				Tween.EASE_IN)
	else:
		if tween != null:
			tween.interpolate_callback(
				self, 
				LOADING_ANIMATION_DURATION, 
				"set_material_override", 
				self, 
				null, 
				ground_shadow.name if ground_shadow != null else "")
			tween.interpolate_property(
				ghost_material, 
				"shader_param/darkness", 
				ghost_material.get_shader_param("darkness"), 
				0.0, 
				LOADING_ANIMATION_DURATION, 
				Tween.TRANS_CUBIC, 
				Tween.EASE_IN)

		if ground_shadow_mat != null and tween != null:
			tween.interpolate_property(
				ground_shadow_mat, 
				"albedo_color", 
				ground_shadow_mat.albedo_color, 
				Color(1.0, 1.0, 1.0, 1.0), 
				LOADING_ANIMATION_DURATION, 
				Tween.TRANS_CUBIC, 
				Tween.EASE_OUT, 
				LOADING_ANIMATION_DURATION)

	if tween != null:
		tween.start()



func set_force_doors_closed(force, animated: bool = false, speed: float = 1.0):
	if force_doors_closed == force: return
	force_doors_closed = force
	update(vehicle_data, animated, speed)
	
func set_hood_open(open, animated = false, speed: float = 1.0):
	if hood_open == open: return
	hood_open = open
	toggle_open(hood_animation, open, animated, speed)

func set_trunk_open(open, animated = false, speed: float = 1.0):
	if trunk_open == open: return
	trunk_open = open
	toggle_open(trunk_animation, open, animated, speed)

func set_lf_door_open(open, animated = false, speed: float = 1.0):
	if lf_door_open == open: return
	lf_door_open = open
	toggle_open(lf_door_animation, open, animated, speed)

func set_lr_door_open(open, animated = false, speed: float = 1.0):
	if lr_door_open == open: return
	lr_door_open = open
	toggle_open(lr_door_animation, open, animated, speed)

func set_rf_door_open(open, animated = false, speed: float = 1.0):
	if rf_door_open == open: return
	rf_door_open = open
	toggle_open(rf_door_animation, open, animated, speed)

func set_rr_door_open(open, animated = false, speed: float = 1.0):
	if rr_door_open == open: return
	rr_door_open = open
	toggle_open(rr_door_animation, open, animated, speed)

func set_charge_port_open(open, animated = false, speed: float = 1.0):
	if charge_port_open == open: return
	charge_port_open = open
	toggle_open(chargeport_animation, open, animated, speed)
	

func set_show_fx_above(above):
	show_fx_above = above
	if airflow_left != null: airflow_left.show_above(above)
	if airflow_right != null: airflow_right.show_above(above)
	if defrost_front != null: defrost_front.show_above(above)
	if defrost_rear != null: defrost_rear.show_above(above)
	
func set_airflow_on(on):
	airflow_on = on
	set_node_visible(airflow_left, on)
	set_node_visible(airflow_right, on)

func set_defrost_front_on(on):
	defrost_front_on = on
	set_node_visible(defrost_front, on)
	
func set_defrost_rear_on(on):
	defrost_rear_on = on
	set_node_visible(defrost_rear, on)
	
func on_roof_fade_applied(mat: Material, fade: bool, animated: bool, duration: float):
	pass
	
func set_fade_roof(fade: bool = true, animated: bool = true, duration: float = 0.75):
	fade_roof = fade
	
	for mat in roof_fade_materials:
		var alpha = 0 if fade else original_material_alpha[mat]
		if mat is SpatialMaterial:
			if animated:
				tween.interpolate_property(mat, "albedo_color:a", null, alpha, duration, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
			else:
				tween.stop(mat, "albedo_color:a")
				mat.albedo_color.a = alpha
		elif mat is ShaderMaterial:
			if animated:
				tween.interpolate_property(mat, "shader_param/color:a", null, alpha, duration, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
			else:
				tween.stop(mat, "shader_param/color:a")
				var color = mat.get_shader_param("color")
				color.a = alpha
				mat.set_shader_param("color", color)
		on_roof_fade_applied(mat, fade, animated, duration)
	if tween != null:
		tween.start()



func set_fog_lights_on(on):
	fog_lights_on = on
	emit_signal("vehicle_lights_changed", self)
	set_node_visible(fog_lights, on)

func set_reverse_lights_on(on):
	reverse_lights_on = on
	emit_signal("vehicle_lights_changed", self)
	set_node_visible(reverse_lights, on)

func set_turn_signal_r_state(state: int):
	turn_signal_r_state = state
	emit_signal("vehicle_lights_changed", self)
	set_node_visible(turn_signal_r, state == 1)
	set_node_visible(brake_lights_r, state == 1)
	
func set_turn_signal_l_state(state: int):
	turn_signal_l_state = state
	emit_signal("vehicle_lights_changed", self)
	set_node_visible(turn_signal_l, state == 1)
	set_node_visible(brake_lights_l, state == 1)
	
func set_drl_on(on):
	drl_on = on
	emit_signal("vehicle_lights_changed", self)
	set_node_visible(drl, on)
	
func set_headlights_on(on):
	headlights_on = on
	emit_signal("vehicle_lights_changed", self)
	set_node_visible(headlights, on)
	set_node_visible(headlights_trunk, on)
	
	
	
func set_brake_lights_on(on):
	brake_lights_on = on
	emit_signal("vehicle_lights_changed", self)
	set_node_visible(brake_lights_l, on)
	set_node_visible(brake_lights_r, on)
	set_node_visible(brake_lights_center, on)
	
	



func set_rhd(is_rhd):
	RHD = is_rhd;
	if is_rhd:
		if interior_rhd: interior_rhd.show()
		if interior_lhd: interior_lhd.hide()
	else:
		if interior_rhd: interior_rhd.hide()
		if interior_lhd: interior_lhd.show()

func set_interior_config(interior):
	if local_dir == null or local_dir == "": return
	
	interior_config = interior;
	var mat: SpatialMaterial = null
	
	match (interior):
		VehicleOptions.InteriorConfig.White, VehicleOptions.InteriorConfig.White2, VehicleOptions.InteriorConfig.WhiteCarbonFiber:
			mat = load_material("Interior_White")
		VehicleOptions.InteriorConfig.Black, VehicleOptions.InteriorConfig.Black2, VehicleOptions.InteriorConfig.BlackCarbonFiber:
			mat = load_material("Interior_Black")
		VehicleOptions.InteriorConfig.Cream, VehicleOptions.InteriorConfig.CreamCarbonFiber:
			mat = load_material("Interior_Cream")
			
	if mat == null: return ;
	
	apply_material(self, mat, "Interior");

func set_fascia_type(type):
	fascia_type = type

func set_drivetrain_type(type):
	drivetrain_type = type

func set_has_spoiler(on):
	has_spoiler = on
	set_node_visible(spoiler, on)
	
func set_has_us_plate(on):
	has_us_plate = on
	has_eu_plate = not on
	set_node_visible(plate_us, on)
	set_node_visible(plate_eu, not on)
	
	
func set_has_eu_plate(on):
	has_eu_plate = on
	has_us_plate = not on
	set_node_visible(plate_eu, on)
	set_node_visible(plate_us, not on)
	

func set_skybox_intensity(v):
	skybox_intensity = v;
	update_skybox();

func set_skybox(v):
	skybox = v;
	update_skybox();

func set_skybox_enable(v):
	skybox_enable = v;
	update_skybox();

func update_skybox():
	if ( not is_inside_tree()):
		return
	for skybox_mat in get_skybox_materials():
		if not skybox_mat: continue;
		skybox_mat.set_shader_param("skybox", skybox);
		skybox_mat.set_shader_param("skybox_contrib", skybox_enable);
		skybox_mat.set_shader_param("skybox_intensity", skybox_intensity);
		skybox_mat.set_shader_param("in_editor", Engine.editor_hint);

func update_airflow_state(data: VehicleData):
	var on = data.isClimateOn() and not data.climate_state.is_front_defroster_on
	if on:
		var type = Airflow.WaveType.COLD
		var left = airflow_left as Airflow
		var right = airflow_right as Airflow
		if left != null: left.set_type(type)
		if right != null: right.set_type(type)
			
	set_airflow_on(on)
	
func update_defrost_state(data: VehicleData):
	var climate_on = data.isClimateOn()
	set_defrost_front_on(data.climate_state.is_front_defroster_on if climate_on else false)
	set_defrost_rear_on(data.climate_state.is_rear_defroster_on if climate_on else false)

func update_charge_state(data: VehicleData):
	if charge_port == null: return
	if data.isChargerConnected():
		var cable: ChargeCable
		if charge_port.get_child_count() == 0:
			cable = add_charge_cable(data.vehicle_config.charge_port_type)
		else:
			var node = charge_port.get_child(0)
			if node is ChargeCable:
				cable = node as ChargeCable
			else:
				charge_port.remove_child(node)
				node.queue_free()
				cable = add_charge_cable(data.vehicle_config.charge_port_type)
		if cable != null:
			cable.set_charging_state(data.charge_state)
			set_cable_shader_params(cable)
	else:
		remove_any_chargers()
		if data.vehicle_to_home_ready():
			add_powershare_home()
			update_powershare_wires(data.charge_state.charge_port_flow_state)
		else:
			remove_powershare_home()
			

func set_cable_shader_params(cable: ChargeCable):
	var materials = get_materials(cable, "Charger_Cable")
	if len(materials) < 1:
		print("No Charger_Cable material found!")
		return
	var charging_cable_mat = materials[0]

	charging_cable_mat.set_shader_param("alpha_decrease_offset_begin", charging_cable_alpha_decrease_offset_begin);
	charging_cable_mat.set_shader_param("alpha_decrease_offset_end", charging_cable_alpha_decrease_offset_end);
		
func add_supercharger():
	if charge_port == null: return
	var supercharger = load("res://mobile/geometry/Supercharger/Supercharger.tscn")
	if supercharger == null: return
	var node = supercharger.instance()
	charge_port.add_child(node)
	node.name = "Supercharger"

func add_homecharger():
	if charge_port == null: return
	var homecharger = load("res://mobile/geometry/Home_Charger/Home_Charger.tscn")
	if homecharger == null: return
	var node = homecharger.instance()
	charge_port.add_child(node)
	node.name = "Homecharger"
	
func add_charge_cable(charge_port_type: String):
	if charge_port == null: return
	var cable_path: NodePath = VehicleOptions.ChargePortTypeToCableMap.get(charge_port_type, VehicleOptions.ChargePortTypeToCableMap.get("US"))
	if cable_path == null: return
	var cable = load(String(cable_path))
	if cable == null: return
	var node = cable.instance()
	charge_port.add_child(node)
	node.name = "ChargeCable"
	return node
	
func add_powershare_home():
	if charge_port == null: return
	if charge_port.has_node(powershare_home_node_name): return
	var home_path = powershare_home_node
	if home_path == null: return
	var home = load(String(home_path))
	if home == null: return
	var node = home.instance()
	node.name = powershare_home_node_name
	charge_port.add_child(node)
	emit_signal("fade_garage")

func update_powershare_wires(powershare_charge_state):
	if charge_port == null: return
	if not charge_port.has_node(powershare_home_node_name): return
	emit_signal("update_powershare_wires", powershare_charge_state)
	
	
func remove_any_chargers():
	if charge_port == null: return
	for node in charge_port.get_children():
		if node.name == powershare_home_node_name:
			return
		charge_port.remove_child(node)
		node.queue_free()

func remove_powershare_home():
	if charge_port == null: return
	for node in charge_port.get_children():
		if node.name == powershare_home_node_name:
			charge_port.remove_child(node)
			node.queue_free()

func _register_roof_fade_material(mat: Material) -> void :
	if mat == null: return
	if roof_fade_materials.has(mat): return
	if not mat.resource_name in get_roof_fade_resource_names(): return

	roof_fade_materials.append(mat)
	if mat is SpatialMaterial:
		original_material_alpha[mat] = mat.albedo_color.a
	elif mat is ShaderMaterial:
		original_material_alpha[mat] = mat.get_shader_param("color").a
	on_roof_fade_material_added(mat)

func _apply_material_from_map(type_key: int, material_map: Dictionary, type_label: String) -> bool:
	if not is_inside_tree(): return false
	if not material_map.has(type_key):
		push_warning("No %s material for type %s on %s" % [type_label, type_key, get_name()])
		return false

	var entry = material_map[type_key]

	
	if entry is Array or entry is PoolStringArray:
		var success: = false
		for mat_name in entry:
			var mat: Material = load_material(mat_name)
			if mat == null:
				push_warning("Failed to load %s material %s on %s" % [type_label, mat_name, get_name()])
				continue
			apply_material(self, mat, mat.resource_name, MaterialMatchMode.NODE_THEN_MESH)
			_register_roof_fade_material(mat)
			success = true
		return success

	
	var mat: Material = load_material(entry)
	if mat == null:
		push_warning("Failed to load %s material %s on %s" % [type_label, entry, get_name()])
		return false
	apply_material(self, mat, mat.resource_name, MaterialMatchMode.NODE_THEN_MESH)
	return true

func set_interior_upper_trim_type(trim_type: int, force: bool = false) -> void :
	if interior_upper_trim_type == trim_type and not force: return
	interior_upper_trim_type = trim_type
	_apply_material_from_map(trim_type, interior_upper_trim_materials, "upper trim")

func set_badging_material_type(material_type: int, force: bool = false) -> void :
	if badging_material_type == material_type and not force: return
	badging_material_type = material_type
	_apply_material_from_map(material_type, badging_materials, "badging")

func set_use_mobile_shadows(use_mobile: bool):
	use_mobile_shadows = use_mobile
	
	if ground_shadow == null: return
	if ground_shadow.get_surface_material_count() == 0: return
	
	var material: Material = null
	if use_mobile:
		material = load_material("Ground_Plane_mobile")
	else:
		material = load_material("Ground_Plane")
	
	if material == null: return
	ground_shadow.set_surface_material(0, material)

func hide_spatial(node: Spatial, hide: bool):
	if node != null:
		if hide:
			node.hide()
		else:
			node.show()

func hide_wheels(hide: bool):
	print("hide_wheels ", hide)
	hide_wheels = hide
	for wheel in get_main_wheel_sockets():
		hide_spatial(wheel, hide)
	
func get_main_wheel_sockets():
	return [lf_wheel, lr_wheel, rf_wheel, rr_wheel]




func get_wheel_rotation_objects():
	return get_main_wheel_sockets()


func get_skybox_materials():
	return [skybox_paint_material, skybox_paint_material2, glass_skybox, glass_tint_skybox]

func toggle_open(animation_player: AnimationPlayer, open: bool, animated: bool = false, speed: float = 1.0):
	if animation_player == null:
		return
	
	var animation_list = animation_player.get_animation_list()
	if animation_list.empty():
		printerr("Animation list empty")
		return
		
	var animation = animation_list[0]
	if open:
		animation_player.play(animation, - 1, speed)
		if not animated:
			animation_player.seek(animation_player.current_animation_length, true)
	else:
		animation_player.play(animation, - 1, - speed, true)
		if not animated:
			animation_player.seek(0, true)

func set_node_visible(node: Spatial, show: bool):
	if node != null:
		node.set_visible(show)

func set_wheel_type_by_name(wheel_type_key: String):
	var wheel = VehicleOptions.MobileWheelTypeEnumMap.get(wheel_type_key, VehicleOptions.WheelType.StilettoSilver);
	set_wheel_type(wheel)

func set_wheel_type_by_name_with_vehicle_default(wheel_type_key: String, car_type: String):
	
	var wheel = VehicleOptions.MobileWheelTypeEnumMap.get(wheel_type_key);
	if wheel == null:
		
		wheel = VehicleOptions.DefaultWheelForVehicleType.get(car_type, VehicleOptions.WheelType.StilettoSilver)
	set_wheel_type(wheel)
		

func set_wheel_type_by_gtw_name(gtw_enum_name: String):
	print("set_wheel_type_by_gtw_name: " + gtw_enum_name)
	var wheel = VehicleOptions.GTWWheelTypeEnumMap[gtw_enum_name];
	set_wheel_type(wheel)


func set_wheel_type_path_override(path_override: String):
	print("set_wheel_type_path_override: " + path_override)
	wheel_model_path_override = path_override


func set_interior_by_viz_name(interior: String):
	print("set_interior_by_viz_name: " + interior)
	set_interior_config(VehicleOptions.VizInteriorMap[interior]);

func set_wheel_type(type):
	if wheel_type == type and loaded_wheels: return
	wheel_type = type

	var wheel_model_path
	if (wheel_model_path_override.empty()):
		
		wheel_model_path = VehicleOptions.WheelTypeToPathMap.get(type)
		if wheel_model_path == null:
			wheel_model_path = VehicleOptions.WheelTypeToPathMap.get(VehicleOptions.WheelType.StilettoSilver)
	else:
		
		wheel_model_path = NodePath(wheel_model_path_override)
		
	load_and_add_wheel_model_from_path(wheel_model_path)

func load_and_add_wheel_model_from_path(wheel_model_path: String):
	var wheel_model = load(String(wheel_model_path))
	if wheel_model == null: return

	var wheel_sockets = get_main_wheel_sockets()
	for socket in wheel_sockets:
		if socket == null: continue
		
		for child in socket.get_children():
			socket.remove_child(child);
			child.queue_free()
	
		
		socket.add_child(wheel_model.instance())
		loaded_wheels = true;


func set_brakes(performace: bool):
	if performace == has_perf_brakes and loaded_brakes: return
	has_perf_brakes = performace;
	
	var front_left_brake_model = brakes_perf_front_left if performace else brakes_standard_front_left;
	var rear_left_brake_model = brakes_perf_rear_left if performace else brakes_standard_rear_left;
	var front_right_brake_model = brakes_perf_front_right if performace else brakes_standard_front_right;
	var rear_right_brake_model = brakes_perf_rear_right if performace else brakes_standard_rear_right;

	var lf: Spatial = get_node_or_null(lf_brake_path)
	var lr: Spatial = get_node_or_null(lr_brake_path)
	var rf: Spatial = get_node_or_null(rf_brake_path)
	var rr: Spatial = get_node_or_null(rr_brake_path)

	var brake_sockets = [[lf, front_left_brake_model], [lr, rear_left_brake_model], 
							[rf, front_right_brake_model], [rr, rear_right_brake_model]]

	for brake_conf in brake_sockets:
		if brake_conf[0] == null or brake_conf[1] == null: continue
		
		for child in brake_conf[0].get_children():
			brake_conf[0].remove_child(child);
			child.queue_free()

		
		brake_conf[0].add_child(brake_conf[1].instance())
		loaded_brakes = true;

func set_paint_color(color):
	if (paint_color == color): return
	paint_color = color;
	set_paint_color_by_name(VehicleOptions.ExteriorColor.keys()[color])

func set_paint_color_with_override(paintName: String, override: String):
	if override.split(",").size() == 5:
		set_paint_color_override(override)
	else:
		set_paint_color_by_name(paintName)


func set_paint_color_by_name(color_key: String):
	print("set_paint_color_by_name ", color_key, " previous value ", paint_color_name)

	if paint_color_name == color_key: return

	paint_color_name = color_key
	paint_color_override = String()

	var material: Dictionary = VehicleOptions.ExteriorColorValue.get(color_key, VehicleOptions.FALLBACK_EXTERIOR_COLOR)
	set_paint_color_by_dict(material, true)


func set_paint_color_override(override: String, force_apply: bool = false):
	print("set_paint_color_override ", override, " previous value ", paint_color_override, " has_two_toned_color ", has_two_toned_color(), " force_apply ", force_apply)

	if paint_color_override == override and not force_apply: return
	var color_array = override.split_floats(",")
	if color_array.size() != 5: return

	paint_color_override = override
	paint_color_name = String()

	var material_color = Color(color_array[0] / 255, color_array[1] / 255, color_array[2] / 255, 1.0)
	if colorizer_paint_remap_enabled:
		material_color = remap_color(material_color)
	var material: Dictionary = {"color": material_color, "metallic": color_array[3], "roughness": color_array[4]};
	set_paint_color_by_dict(material, false)

func has_two_toned_color() -> bool:
	return false

func enable_license_plate_noise() -> bool:
	return false
	
func remap_color(user_set_color) -> Color:
	var remapped_color = user_set_color
	remapped_color.v *= 0.325

	return remapped_color

func get_color_alpha_from_material_shader(material) -> float:
	if has_two_toned_color():
		var color = material.get_shader_param("color_bright")
		return color.a
	else:
		var color = material.get_shader_param("color")
		return color.a

func calculate_color_dark(rgb_color_bright) -> Color:
	return rgb_color_bright

func calculate_color_away_and_up(rgb_color_bright) -> Color:
	return rgb_color_bright

func calculate_metallic_dark(metallic_bright) -> float:
	return metallic_bright

func calculate_metallic_away_and_up(metallic_bright) -> float:
	return metallic_bright

func calculate_roughness_dark(roughness_bright) -> float:
	return roughness_bright

func calculate_roughness_away_and_up(roughness_bright) -> float:
	return roughness_bright

func set_color_param_in_skybox_material(skybox_paint_material, color):
	if has_two_toned_color():
		skybox_paint_material.set_shader_param("color_bright", color)
		skybox_paint_material.set_shader_param("color_dark", calculate_color_dark(color))
		skybox_paint_material.set_shader_param("color_away_and_up", calculate_color_away_and_up(color))
	else:
		skybox_paint_material.set_shader_param("color", color)

func set_metallic_param_in_skybox_material(skybox_paint_material, metallic):
	if has_two_toned_color():
		skybox_paint_material.set_shader_param("metallic_bright", metallic)
		skybox_paint_material.set_shader_param("metallic_dark", calculate_metallic_dark(metallic))
		skybox_paint_material.set_shader_param("metallic_away_and_up", calculate_metallic_away_and_up(metallic))
	else:
		skybox_paint_material.set_shader_param("metallic", metallic)

func set_roughness_param_in_skybox_material(skybox_paint_material, roughness):
	if has_two_toned_color():
		skybox_paint_material.set_shader_param("roughness_bright", roughness)
		skybox_paint_material.set_shader_param("roughness_dark", calculate_roughness_dark(roughness))
		skybox_paint_material.set_shader_param("roughness_away_and_up", calculate_roughness_away_and_up(roughness))
	else:
		skybox_paint_material.set_shader_param("roughness", roughness)

func apply_color_to_skybox_material(skybox_paint_material, material, includeAlpha):
	if skybox_paint_material:
		if includeAlpha:
			set_color_param_in_skybox_material(skybox_paint_material, material.color)
		else:
			var color = Color(material.color.r, material.color.g, material.color.b, 1)
			color.a = get_color_alpha_from_material_shader(skybox_paint_material)
			set_color_param_in_skybox_material(skybox_paint_material, color)
		set_metallic_param_in_skybox_material(skybox_paint_material, material.metallic)
		set_roughness_param_in_skybox_material(skybox_paint_material, material.roughness)

func set_paint_material_color(material: SpatialMaterial, color: Color, includeAlpha: bool):
	if material:
		if includeAlpha:
			material.albedo_color = color
		else:
			material.albedo_color.r = color.r
			material.albedo_color.g = color.g
			material.albedo_color.b = color.b

func set_paint_color_by_dict(material: Dictionary, includeAlpha: bool):
	print("set_paint_color_by_dict includeAlpha ", includeAlpha)
	if not material:
		printerr("Invalid vehicle color")
		return ;

	active_paint_material_config = material
	print("new paint color: ", material.color, " metallic: ", material.metallic, " roughness: ", material.roughness)
	apply_color_to_skybox_material(skybox_paint_material, material, includeAlpha)
	apply_color_to_skybox_material(skybox_paint_material2, material, includeAlpha)

	if paint_fade_material:
		set_paint_material_color(paint_fade_material, material.color, includeAlpha)
		paint_fade_material.metallic = material.metallic
		paint_fade_material.roughness = material.roughness
	if paint_rough_material:
		set_paint_material_color(paint_rough_material, material.color, includeAlpha)
		paint_rough_material.metallic = material.metallic
		paint_rough_material.roughness = 1.0


	if current_skin != "" and not skin_transition_in_progress:
		darken_rough_paint_for_skin()


func set_interior_type(type: String):
	var interior = VehicleOptions.InteriorMap.get(type, VehicleOptions.InteriorConfig.Black)
	set_interior_config(interior);
	

func get_roof_fade_resource_names():
	return []
	
func on_roof_fade_material_added(mat: Material):
	pass

func duplicate_materials(node: Spatial, resource_name: Array, duplicated_materials: Dictionary):
	if node == null:
		return
	if node is MeshInstance:
		var num_materials = node.get_surface_material_count()
		for index in range(node.get_surface_material_count()):
			var mat: Material = node.get_surface_material(index)
			if mat == null: continue
			if mat.resource_name in resource_name:
				if not duplicated_materials.has(mat.resource_name):
					duplicated_materials[mat.resource_name] = mat.duplicate()
				node.set_surface_material(index, duplicated_materials[mat.resource_name])

	for child in node.get_children():
		duplicate_materials(child, resource_name, duplicated_materials)

	
func get_roof_fade_materials(fade_resource_names: Array):
	var materials = Array()
	for resource_name in fade_resource_names:
		var instance_materials = get_materials(self, resource_name)
		if allow_sourcing_roof_fade_material_from_mesh:
			instance_materials += get_materials(self, resource_name, true)
		for mat in instance_materials:
			if materials.has(mat): continue
			materials.append(mat)
			print("Mat: ", mat, " (", resource_name, ")")
			if mat is SpatialMaterial:
				original_material_alpha[mat] = mat.albedo_color.a
			elif mat is ShaderMaterial:
				original_material_alpha[mat] = mat.get_shader_param("color").a
			on_roof_fade_material_added(mat)

	
	return materials

func set_material_override(node, material, exclude_node_name = ""):
	print("set_material_override")
	for child in node.get_children():
		set_material_override(child, material, exclude_node_name)
	if node is MeshInstance:
		print("node name %s" % node.name)
		if node.name == exclude_node_name:
			return
		node.material_override = material

func get_materials(node, resource_name, source_material_from_mesh = false):
	var materials = Array()
	if node is MeshInstance and node.mesh != null:
		var num_materials = node.mesh.get_surface_count() if source_material_from_mesh else node.get_surface_material_count()
		for index in range(node.get_surface_material_count()):
			var mat: Material = node.mesh.surface_get_material(index) if source_material_from_mesh else node.get_surface_material(index)
			if mat == null: continue
			if mat.resource_name == resource_name:
				materials.append(mat)
				
	for child in node.get_children():
		for child_mat in get_materials(child, resource_name, source_material_from_mesh):
			materials.append(child_mat)
	
	return materials

func set_is_driving(data: VehicleData):
	set_headlights_on(data.isDriving())
	is_driving = data.isDriving()

func on_snapshot(pose_settings):
	pass

func sync_plate_from_viewport():
	if plate_viewport == null:
		return

	plate_viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	yield(VisualServer, "frame_post_draw")
	var plate_texture = ImageTexture.new()
	plate_texture.create_from_image(plate_viewport.get_texture().get_data(), Texture.FLAGS_DEFAULT)
	plate_material.albedo_texture = plate_texture
	print("License plate viewport updated")

	

func set_plate_background_color_override(override: String, force_apply: bool = false):
	print("set_plate_background_color_override ", override, " previous value ", plate_background_color_override, " force_apply ", force_apply)

	if plate_texture_material == null: return
	if plate_background_color_override == override and not force_apply: return

	
	var material_color = Color(0, 0, 0, 0)
	if not override.empty():
		var color_array = override.split_floats(",")
		if color_array.size() != 4: return
		material_color = Color(color_array[0] / 255, color_array[1] / 255, color_array[2] / 255, color_array[3] / 255)

	
	plate_background_color_override = override
	plate_texture_material.set_shader_param("color_background", material_color)
	sync_plate_from_viewport()
	
func copy_shader_param(from_material: ShaderMaterial, from_param_name: String, to_material: ShaderMaterial, to_param_name: String):
	if from_material and to_material:
		to_material.set_shader_param(to_param_name, from_material.get_shader_param(from_param_name))

func copy_common_paint_skybox_params(from_material: ShaderMaterial, to_material: ShaderMaterial):
	copy_shader_param(from_material, "skybox_rot", to_material, "skybox_rot")
	copy_shader_param(from_material, "metallic", to_material, "metallic")
	copy_shader_param(from_material, "roughness", to_material, "roughness")
	copy_shader_param(from_material, "color", to_material, "color")
	copy_shader_param(from_material, "skybox_contrib", to_material, "skybox_contrib")
	copy_shader_param(from_material, "skybox_intensity", to_material, "skybox_intensity")
	copy_shader_param(from_material, "skybox", to_material, "skybox")
	copy_shader_param(from_material, "skybox_scroll", to_material, "skybox_scroll")
	copy_shader_param(from_material, "ao", to_material, "ao")
	copy_shader_param(from_material, "ao_intensity", to_material, "ao_intensity")

func get_glass_resource_names():
	return ["GlassSkybox", "GlassFadeSkybox", "GlassTintedSkybox", "GlassTintedFadeSkybox"]

func get_materials_from_resource_names(resource_names: Array):
	var materials_dict = {}
	for resource_name in resource_names:
		var instance_materials = get_materials(self, resource_name)
		if allow_sourcing_roof_fade_material_from_mesh:
			instance_materials += get_materials(self, resource_name, true)
		for mat in instance_materials:
			if materials_dict.has(mat): continue
			materials_dict[mat] = null
	return materials_dict.keys()


func on_glass_material_added(mat: Material):
	pass

func add_glass_materials_to_map(materials: Array):
	for mat in materials:
		var current_color = mat.get_shader_param("color")
		if current_color == null:
			current_color = Color(0.0, 0.0, 0.0, 0.0)
		
		var min_color = current_color
		
		var base_glass_alpha = current_color.a
		var max_glass_alpha = 1.0
		min_color.a = clamp((base_glass_alpha - max_glass_alpha * DEFAULT_TINT_PERCENT) / (1.0 - DEFAULT_TINT_PERCENT), 0.0, 1.0)
		glass_material_to_color_map[mat] = min_color
		on_glass_material_added(mat)

func get_skin_file_path(skin_name):
	return "res://" + local_dir + "/Textures/Skins/" + skin_name + ".png"

func apply_transition_skin_to_current():
	copy_shader_param(paint_overlay_material, "transition_albedo_texture", skybox_paint_material, "custom_albedo_texture")
	copy_shader_param(paint_overlay_material2, "transition_albedo_texture", skybox_paint_material2, "custom_albedo_texture")
	current_skin = active_transition_skin

func load_and_apply_skin(skin, apply_to_overlay_material: bool):
	var skin_texture: Texture
	var skin_array = skin.split(",")
	if skin == "":
		skin_texture = tex_zero_alpha
	elif skin_array.size() == 2:
		var skin_file = skin_array[1]
		print("Debug: loading skin from USB, skin_file =", skin_file)
		skin_texture = ImageTexture.new()
		var err = skin_texture.load(skin_file)
		if err != OK:
			print("Debug: failed to load skin from USB, err =", err)
			skin_texture = null
		else:
			print("Debug: skin loaded from USB successfully")
	else:
		var skin_name = skin_array[0]
		var skin_file = get_skin_file_path(skin_name)
		print("Debug: loading skin from local directory, skin_file =", skin_file)
		skin_texture = load(skin_file)
		if skin_texture == null:
			print("Debug: failed to load skin from local directory, skin_file =", skin_file)

	if skin_texture != null:
		print("Debug: skin_texture loaded successfully, setting to ", skin, ". Overlay = ", apply_to_overlay_material)
		if apply_to_overlay_material:
			if paint_overlay_material:
				paint_overlay_material.set_shader_param("transition_albedo_texture", skin_texture)
			if paint_overlay_material2:
				paint_overlay_material2.set_shader_param("transition_albedo_texture", skin_texture)
		else:
			if skybox_paint_material:
				skybox_paint_material.set_shader_param("custom_albedo_texture", skin_texture)
			if skybox_paint_material2:
				skybox_paint_material2.set_shader_param("custom_albedo_texture", skin_texture)
		return true
	else:
		print("Debug: skin_texture is null, failed to load skin")
		
	return false

func darken_rough_paint_for_skin():
	if adjust_paint_rough_for_skins and active_paint_material_config.has("color"):
		var has_skin = (current_skin != "")
		var transitioning_from_no_skin_to_skin = not has_skin and (active_transition_skin != "")
		var transition_from_skin_to_no_skin = has_skin and (active_transition_skin == "")
		var paint_color: Color = active_paint_material_config.color
		if transitioning_from_no_skin_to_skin:
			paint_color = paint_color.linear_interpolate(Color.black, skin_transition_pct)
		elif transition_from_skin_to_no_skin:
			paint_color = paint_color.linear_interpolate(Color.black, 1.0 - skin_transition_pct)
		elif has_skin:
			paint_color = Color.black
		set_paint_material_color(paint_rough_material, paint_color, false)
		set_paint_material_color(paint_fade_material, paint_color, false)

func set_skin_transition_pct(pct: float):
	skin_transition_pct = pct
	var ego_front_z = front_marker.get_global_transform().origin.z - 0.5
	var ego_rear_z = rear_marker.get_global_transform().origin.z + 0.5
	var transition_pos_z = ego_front_z + (ego_rear_z - ego_front_z) * pct
	apply_skin_transition_pos_z(transition_pos_z)
	darken_rough_paint_for_skin()


func apply_skin_transition_pos_z(transition_pos_z: float):
	if paint_overlay_material:
		paint_overlay_material.set_shader_param("transition_z_pos", transition_pos_z)
	if paint_overlay_material2:
		paint_overlay_material2.set_shader_param("transition_z_pos", transition_pos_z)

func stop_skin_transition(transfer_skin: bool):
	if transfer_skin:
		apply_transition_skin_to_current()

	set_apply_paint_overlay_material(false)
	set_skin_transition_pct(0.0)
	skin_transition_in_progress = false

func skin_transition_tween_completed():
	print("Skin transition completed")
	stop_skin_transition(true)
	
	if desired_skin != active_transition_skin:
		print("Found new desired transition, processing ...")
		evaluate_new_skin_transition()

func set_apply_paint_overlay_material(apply: bool):
	if skybox_paint_material:
		skybox_paint_material.next_pass = paint_overlay_material if apply else null
		if apply and paint_overlay_material:
			copy_common_paint_skybox_params(skybox_paint_material, paint_overlay_material)
	
	if skybox_paint_material2:
		skybox_paint_material2.next_pass = paint_overlay_material2 if apply else null
		if paint_overlay_material2:
			copy_common_paint_skybox_params(skybox_paint_material2, paint_overlay_material2)

func evaluate_new_skin_transition():
	if skin_transition_in_progress:
		print("Another transition active. Waiting for it to complete")
		return
	
	if not load_and_apply_skin(desired_skin, true):
			print("Loading failed. Skipping")
			active_transition_skin = current_skin
			desired_skin = current_skin
			return
	
	active_transition_skin = desired_skin
	
	set_apply_paint_overlay_material(true)
	set_skin_transition_pct(0.0)
	skin_transition_in_progress = true
	
	skin_transition_tween.interpolate_method(
		self, 
		"set_skin_transition_pct", 
		0.0, 
		1.0, 
		SKIN_CHANGE_DURATION, 
		Tween.TRANS_QUAD, 
		Tween.EASE_IN_OUT)
		
	skin_transition_tween.start()

func set_car_skin(skin: String, instant: bool = false):
	print("set car skin called ", skin)

	if skin == desired_skin:
		return

	var skin_array = skin.split(",")
	var valid_skin = skin == "" or skin_array.size() == 1 or skin_array.size() == 2
	if not valid_skin:
		print("Debug: invalid skin array size, returning")
		return

	desired_skin = skin

	if instant:
		print("applying instant skin")
		if load_and_apply_skin(desired_skin, false):
			current_skin = desired_skin
			active_transition_skin = desired_skin
		else:
			print("Loading failed. Skipping")
			active_transition_skin = current_skin
			desired_skin = current_skin
		skin_transition_tween.remove_all()
		stop_skin_transition(false)
	else:
		print("starting new transition")
		evaluate_new_skin_transition()

func on_window_tint_set(mat: Material, alpha: float):
	pass

func set_window_tint(new_tint: String):
	print("set_window_tint ", new_tint, " previous tint ", window_tint)

	if new_tint == window_tint: return
	var tint_array = new_tint.split_floats(",")
	if tint_array.size() != 4: return

	window_tint = new_tint

	var percent_r = tint_array[0] / 255.0
	var percent_g = tint_array[1] / 255.0
	var percent_b = tint_array[2] / 255.0
	var percent_a = tint_array[3] / 255.0

	
	
	
	var average_color = Color(0, 0, 0, 0)
	var num_colors = 0

	for material in glass_material_to_color_map:
		var min_color = glass_material_to_color_map[material]

		var tint_color = Color(
			lerp(min_color.r, max_tint_color, percent_r), 
			lerp(min_color.g, max_tint_color, percent_g), 
			lerp(min_color.b, max_tint_color, percent_b), 
			lerp(min_color.a, 1.0, percent_a)
		)

		material.set_shader_param("color", tint_color)
		on_window_tint_set(material, percent_a)

		average_color += tint_color
		num_colors += 1

	if num_colors > 0:
		average_color /= num_colors
	var max_channel = max(percent_r, max(percent_g, percent_b))
	var min_channel = min(percent_r, min(percent_g, percent_b))
	var value = max_channel
	var saturation = 0.0
	if max_channel > 0.001:
		saturation = (max_channel - min_channel) / max_channel
	
	
	var color_mix_factor = sqrt(saturation * value)

	for material in glass_material_to_color_map:
		var tint_color = material.get_shader_param("color")
		var final_color = lerp(tint_color, average_color, color_mix_factor)
		material.set_shader_param("color", final_color)
		material.set_shader_param("color_mix_factor", color_mix_factor)
		if original_material_alpha.has(material):
			original_material_alpha[material] = final_color.a
