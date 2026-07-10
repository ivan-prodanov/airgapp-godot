tool 
extends Node

enum WINDOW_VIEWPORT{M3_V1 = 0, M3_V2 = 1, SX = 2, SX_FULLSCREEN = 3, M3_V2_WIDE = 4, SQUARE = 5}
enum VEHICLE{
	MODEL_3 = 0, 
	MODEL_S = 1, 
	MODEL_X = 2, 
	MODEL_Y = 3, 
	MODEL_S2 = 4, 
	MODEL_S3 = 5, 
	MODEL_X2 = 6, 
	MODEL_SEMI = 7, 
	MODEL_PLACEHOLDER_8 = 8, 
	MODEL_PLACEHOLDER_9 = 9, 
	MODEL_PLACEHOLDER_10 = 10, 
	SANTA_X = 252, 
	SANTA_S = 253, 
	SANTA_Y = 254, 
	SANTA = 255}
enum FASCIA_TYPE{
	BASE = 0, 
	POPPYSEED_BASE = 1, 
	POPPYSEED_PERF = 2, 
	BAYBERRY = 3}
enum PLATFORM{
	M3 = 0, 
	SX_ICE = 1, 
	SX_TEGRA = 2, 
	CORIANDER = 3, 
	CORIANDER_CONTROLS = 4, 
	CORIANDER_X_CONTROLS = 5, 
	SEMI = 6}
enum TIME_OF_DAY{DAY = 0, NIGHT = 1}
enum MODE{DRIVE = 0, PARK = 1}
enum EGO_MODEL_VERSION{V0 = 0, V1 = 1}
enum SCENE_SKIN{M3_DAY, M3_NIGHT, SX_DAY, SX_NIGHT}
enum CHARGER{NONE = 0, WALL_CHARGER = 1, SUPERCHARGER = 2}

export (WINDOW_VIEWPORT) var viewport_preview setget set_viewport_preview
export (PLATFORM) var platform setget set_platform
export (TIME_OF_DAY) var time_of_day setget set_time_of_day
export (TIME_OF_DAY) var solar_angle_time_of_day setget set_solar_angle_time_of_day
export (bool) var mars_mode setget set_mars_mode
export (MODE) var mode setget set_mode
export (VEHICLE) var ego setget set_ego
export (EGO_MODEL_VERSION) var ego_version setget set_ego_version
export (FASCIA_TYPE) var ego_fascia_type setget set_ego_fascia_type
export (CHARGER) var charger setget set_charger

enum GHOST_CONFIG{NONE = 0, BATTERY = 1, SUSPENSION = 2}
export (GHOST_CONFIG) var ghost_car setget set_ghost_car

export (bool) var enable_launch_mode_reverse_line_movement setget set_enable_launch_mode_reverse_line_movement

var current_skin;
var override_skin = null;
var ego_path_overload = "";

var launch_mode_scene;
var launch_mode_active;

func make_launch_scene():
	if ( not launch_mode_scene):
		var launch_scene;
		var current_ego_scene = get_node_or_null("ego/ROOT");
		if current_ego_scene and current_ego_scene.has_method("get_launch_mode_scene"):
			launch_scene = current_ego_scene.get_launch_mode_scene()
		else:
			launch_scene = preload("res://LaunchMode/LaunchMode.tscn")
		launch_mode_scene = launch_scene.instance();
		add_child(launch_mode_scene);

		if launch_mode_scene and launch_mode_scene.has_method("set_bg_color"):
			launch_mode_scene.set_bg_color(get_background_color())
			
		if launch_mode_scene and launch_mode_scene.has_method("set_enable_reverse_line_movement"):
			launch_mode_scene.set_enable_reverse_line_movement(enable_launch_mode_reverse_line_movement)

func remove_launch_scene():
	if (launch_mode_scene and not launch_mode_active):
		remove_child(launch_mode_scene);
		launch_mode_scene = null;

func launch_mode_prime():
	print("launch_mode_prime");
	make_launch_scene();
	launch_mode_scene.prime();
	launch_mode_active = true;
	
func launch_mode_go():
	print("launch_mode_go");
	make_launch_scene();
	launch_mode_scene.go();
	launch_mode_active = true;
	
func launch_mode_disable():
	if (launch_mode_scene):
		print("launch_mode_disable");
		launch_mode_scene.stop();
		launch_mode_active = false;
		yield(get_tree().create_timer(10.0), "timeout")
		remove_launch_scene();

func launch_mode_cheetah_stance_ready():
	if (launch_mode_scene):
		print("launch_mode_cheetah_stance_ready");
		launch_mode_scene.cheetah_stance_ready();

func set_enable_launch_mode_reverse_line_movement(enable: bool):
	enable_launch_mode_reverse_line_movement = enable

func set_viewport_preview(v):
	viewport_preview = v;
	match viewport_preview:
		WINDOW_VIEWPORT.M3_V1:
			ProjectSettings.set_setting("display/window/size/width", 620);
			ProjectSettings.set_setting("display/window/size/height", 570);
			ProjectSettings.save();
		WINDOW_VIEWPORT.M3_V2:
			ProjectSettings.set_setting("display/window/size/width", 790);
			ProjectSettings.set_setting("display/window/size/height", 875);
			ProjectSettings.save();
		WINDOW_VIEWPORT.M3_V2_WIDE:
			ProjectSettings.set_setting("display/window/size/width", 1270);
			ProjectSettings.set_setting("display/window/size/height", 875);
			ProjectSettings.save();
		WINDOW_VIEWPORT.SX:
			ProjectSettings.set_setting("display/window/size/width", 900);
			ProjectSettings.set_setting("display/window/size/height", 500);
			ProjectSettings.save();
		WINDOW_VIEWPORT.SX_FULLSCREEN:
			ProjectSettings.set_setting("display/window/size/width", 1920);
			ProjectSettings.set_setting("display/window/size/height", 720);
			ProjectSettings.save();
		WINDOW_VIEWPORT.SQUARE:
			ProjectSettings.set_setting("display/window/size/width", 400);
			ProjectSettings.set_setting("display/window/size/height", 400);
			ProjectSettings.save();
			
func update_perf_fascia():
	var is_perf_fascia = ego_fascia_type == FASCIA_TYPE.POPPYSEED_PERF
	var current_ego_scene = get_node_or_null("ego/ROOT");
	if current_ego_scene and current_ego_scene.has_method("set_is_performance"):
		current_ego_scene.set_is_performance(is_perf_fascia)
			
func set_charger(v):
	if charger == v: return ;
	charger = v;
	update_charger();
	
func update_charger():
	
	var current_ego_scene = get_node_or_null("ego/ROOT");
	if current_ego_scene and current_ego_scene.has_method("remove_any_chargers"):
		current_ego_scene.remove_any_chargers();
		current_ego_scene.remove_powershare_home();
		if charger == CHARGER.WALL_CHARGER:
			current_ego_scene.add_homecharger();
		if charger == CHARGER.SUPERCHARGER:
			current_ego_scene.add_supercharger();

func reparent_node(cur_parent, new_parent, node):
	cur_parent.remove_child(node);
	new_parent.add_child(node);

func load_additional_assetgen_cameras(new_assetgen_node: Node):
	var current_assetgen_node = get_node_or_null("AssetGen/SnapshotRenderViewport");
	if not current_assetgen_node:
		print("AssetGen doesn't exist");
		return ;
	
	for child_node in new_assetgen_node.get_children():
		if child_node is SkinProps:
			reparent_node(new_assetgen_node, self, child_node)
			print("Loaded assetgen skin " + child_node.name);
		elif child_node is Camera:
			var camera_spatial_node = current_assetgen_node.get_node_or_null(child_node.name)
			if not camera_spatial_node:
				var duplicate_me_node = current_assetgen_node.get_node_or_null("DuplicateMe")
				camera_spatial_node = duplicate_me_node.duplicate()
				camera_spatial_node.name = child_node.name
				current_assetgen_node.add_child(camera_spatial_node)
				
			for child in camera_spatial_node.get_children():
				camera_spatial_node.remove_child(child)
				
			child_node.name = "Camera"
			reparent_node(new_assetgen_node, camera_spatial_node, child_node)
			print("Loaded assetgen camera " + camera_spatial_node.name)


func load_additional_cameras(path: String):
	var current_camera_poses_node = get_node_or_null("CameraPoses");
	if not current_camera_poses_node:
		print("CameraPoses doesn't exist");
		return ;

	if not ResourceLoader.exists(path):
		print("Camera poses override path " + path + " doesn't exist");
		return ;

	print("Loading additional cameras from " + path);

	var additional_camera_poses_scene = load(path).instance();
	if not additional_camera_poses_scene:
		print("Cannot load additional camera poses");
		return ;

	for node in additional_camera_poses_scene.get_children():
		if node.name == "AssetGen":
			load_additional_assetgen_cameras(node)
		elif node is Camera:
			var existing_camera_node = current_camera_poses_node.get_node_or_null(node.get_name());
			if existing_camera_node:
				current_camera_poses_node.remove_child(existing_camera_node);
				existing_camera_node.queue_free();
			reparent_node(additional_camera_poses_scene, current_camera_poses_node, node);
			print("Loaded " + node.get_name());

	additional_camera_poses_scene.queue_free();

func set_ghost_car(v):
	if (ghost_car != v):
		ghost_car = v;
		update_ghost_car();

func update_ghost_time_of_day():
	var ego_root = get_node_or_null("ghost");
	if ( not ego_root): return ;
	for n in ego_root.get_children():
		if (n.has_method("set_time_of_day")):
			n.time_of_day = time_of_day;

func update_ego_time_of_day():
	var ego_root = get_node_or_null("ego/ROOT");
	if ( not ego_root): return ;
	if (ego_root.has_method("set_time_of_day")):
		ego_root.set_time_of_day(time_of_day);
			
	
func update_ghost_car():
	print("update_ghost_car")
	var ego_root = get_node_or_null("ghost");
	if ( not ego_root): return ;
	
	for n in ego_root.get_children():
		ego_root.remove_child(n);
		n.queue_free();
	
	if (ghost_car == GHOST_CONFIG.NONE): return ;
	
	var ego_scene_path = "res://Ego/Ghost_Car/Drivetrain_Model_S.tscn"
		
	match ego:
		VEHICLE.MODEL_S, VEHICLE.MODEL_S2, VEHICLE.MODEL_S3, VEHICLE.SANTA_S:
			ego_scene_path = "res://Ego/Ghost_Car/Drivetrain_Model_S.tscn"
		VEHICLE.MODEL_X, VEHICLE.MODEL_X2, VEHICLE.SANTA_X:
			ego_scene_path = "res://Ego/Ghost_Car/Drivetrain_Model_X.tscn"
		VEHICLE.MODEL_3, VEHICLE.SANTA:
			ego_scene_path = "res://Ego/Ghost_Car/Drivetrain_Model_3.tscn"
		VEHICLE.MODEL_Y, VEHICLE.SANTA_Y:
			ego_scene_path = "res://Ego/Ghost_Car/Drivetrain_Model_Y.tscn"
			
	print(ego_scene_path)
	var ghost_scene = load(ego_scene_path).instance();
	
	var vehicle_scale = ghost_scene.get_vehicle_scale();
	ghost_scene.scale = Vector3(vehicle_scale, vehicle_scale, vehicle_scale);
	ego_root.add_child(ghost_scene);
	
	var current_ego_scene = get_node_or_null("ego/ROOT");
	if current_ego_scene and ghost_scene:
		print("matchwheel")
		print(current_ego_scene.wheel_type);
		ghost_scene.wheel_type = current_ego_scene.wheel_type;
		ghost_scene.has_perf_brakes = current_ego_scene.has_perf_brakes;
	
	ghost_scene.ghost_view = ghost_car;
	ghost_scene.time_of_day = time_of_day;

func set_ego_version(v):
	if ego_version == v:
		return ;
	ego_version = v;
	if Engine.editor_hint:
		update_ego();
		update_skin();
		
func set_ego_fascia_type(v):
	if ego_fascia_type == v:
		return ;
	ego_fascia_type = v;
	print("Ego fascia type: ", v);
	if Engine.editor_hint:
		update_ego();
		update_skin();
		
func set_ego(v):
	if ego == v:
		return ;
	ego = v;
	if Engine.editor_hint:
		update_ego();
		update_skin();


func set_ego_path_overload(path):
	ego_path_overload = path;
	print("Ego path overload: " + path);


func load_ego(viz_ego_id, version = EGO_MODEL_VERSION.V0):
	print("load_ego:" + VEHICLE.keys()[viz_ego_id]);
	ego = viz_ego_id;
	ego_version = version;
	var ego_node = update_ego();
	update_skin();
	return ego_node;

func update_ego():
	var ego_root = get_node_or_null("ego");
	var ego_scene_path = "res://Ego/Y/Model_Y_High.tscn"
	match ego:
		VEHICLE.MODEL_S, VEHICLE.MODEL_S2:
			match ego_version:
				EGO_MODEL_VERSION.V0:
					ego_scene_path = "res://Ego/S_tmp/models.tscn"
				EGO_MODEL_VERSION.V1:
					ego_scene_path = "res://Ego/S/Model_S.tscn"
		VEHICLE.MODEL_S3:
			ego_scene_path = "res://Ego/S_Palladium/S_Palladium.tscn"
		VEHICLE.MODEL_X2:
			ego_scene_path = "res://Ego/X_Palladium/X_Palladium.tscn"
		VEHICLE.MODEL_X:
			match ego_version:
				EGO_MODEL_VERSION.V0:
					ego_scene_path = "res://Ego/X_tmp/modelx.tscn"
				EGO_MODEL_VERSION.V1:
					ego_scene_path = "res://Ego/X/Model_X.tscn"
		VEHICLE.MODEL_3:
			if ego_fascia_type == FASCIA_TYPE.POPPYSEED_BASE or ego_fascia_type == FASCIA_TYPE.POPPYSEED_PERF:
				ego_scene_path = "res://Ego/v2023/Poppyseed/Poppyseed.tscn"
			else:
				ego_scene_path = "res://Ego/3/Model_3.tscn"
		VEHICLE.MODEL_Y:
			if ego_fascia_type == FASCIA_TYPE.BAYBERRY:
				ego_scene_path = "res://Ego/Bayberry/Bayberry.tscn"
			else:
				ego_scene_path = "res://Ego/Y/Model_Y_High.tscn"
		VEHICLE.SANTA:
			ego_scene_path = "res://Ego/Santa_Sleigh/Santa_Sleigh.tscn"
		VEHICLE.SANTA_Y:
			ego_scene_path = "res://Ego/Santa_Sleigh_Y/Santa_Sleigh_Y.tscn"
		VEHICLE.SANTA_S:
			ego_scene_path = "res://Ego/Santa_Sleigh_S/Santa_Sleigh_S.tscn"
		VEHICLE.SANTA_X:
			ego_scene_path = "res://Ego/Santa_Sleigh_X/Santa_Sleigh_X.tscn"
		VEHICLE.MODEL_SEMI:
			ego_scene_path = "res://Ego/Semi/Semi.tscn"
		VEHICLE.MODEL_PLACEHOLDER_8:
			ego_scene_path = "res://bad_path_8_use_ego_path_overload.tscn"
		VEHICLE.MODEL_PLACEHOLDER_9:
			ego_scene_path = "res://bad_path_9_use_ego_path_overload.tscn"
		VEHICLE.MODEL_PLACEHOLDER_10:
			ego_scene_path = "res://bad_path_10_use_ego_path_overload.tscn"

	if (ego_path_overload != ""):
		ego_scene_path = ego_path_overload;

	print("Loading ego model:" + ego_scene_path);
	var ego_scene = load(ego_scene_path).instance();

	if ( not ego_scene or not ego_root):
		printerr("Failed to load: " + ego_scene_path)
		return ;

	var current_ego_scene = get_node_or_null("ego/ROOT");
	if current_ego_scene:
		print("removing prior ego vehicle")
		ego_root.remove_child(current_ego_scene);
		current_ego_scene.queue_free();
		
	var vehicle_scale = ego_scene.get_vehicle_scale();
	ego_scene.scale = Vector3(vehicle_scale, vehicle_scale, vehicle_scale);
	ego_root.add_child(ego_scene);
	
	
	var ego_offset_z = - 1.488;
	ego_scene.transform.origin.z = ego_offset_z;

	var park_front = get_node("ego/park_front");
	var park_rear = get_node("ego/park_rear");
	var front_marker = ego_scene.get_node_or_null("FrontMarker");
	var rear_marker = ego_scene.get_node_or_null("RearMarker");
	var charge_marker = ego_scene.get_node_or_null("ChargeSocketMarker");
	var chargers = get_node_or_null("ego/chargers");
	var supercharger = get_node_or_null("ego/chargers/supercharger");

	var park_front_translation = park_front.get_translation();
	var park_rear_translation = park_rear.get_translation();

	if front_marker:
		park_front_translation.z = ego_offset_z + front_marker.translation.z;
		park_front.set_translation(park_front_translation);

	if rear_marker:
		park_rear_translation.z = ego_offset_z + rear_marker.translation.z;
		park_rear.set_translation(park_rear_translation);

	if charge_marker and chargers:
		print("doing charger")
		var charge_marker_translation = charge_marker.get_translation() * vehicle_scale;
		charge_marker_translation = Vector3(charge_marker_translation.z + 0.035, charge_marker_translation.y, - charge_marker_translation.x);
		chargers.set_translation(charge_marker_translation);
		if supercharger:
			supercharger.call_deferred("reset_base_position");

	if ego_version == EGO_MODEL_VERSION.V1:
		match ego:
			VEHICLE.MODEL_S:
				print("S1")
				ego_scene.version = Model_S.Version.S1;
			VEHICLE.MODEL_S2:
				print("S2")
				ego_scene.version = Model_S.Version.S2;
			
	update_perf_fascia()
	update_charger();
	print("added ego vehicle")
	return ego_scene;


func get_current_skin():
	return current_skin;

func node_needs_skinning(node):
	if (node.is_in_group("dynamic_object")):
		return true;
	if (node.name == "VehicleBody2"):
		return true;
	if (node.name.begins_with("Door_")):
		return true;
	if (node.name == "Interior2"):
		return true;
	return false;

func skin_node(node):
	if (node.is_in_group("TL")):
		node.bulb_alpha = current_skin.colors.traffic_light_bulb_energy;
		
	if (node.is_in_group("matcap")):
		skin_matcap(current_skin, node);
	
	if (node_needs_skinning(node)):
		skin_dynamic_object(current_skin, node);

	for child_node in node.get_children():
		if node_needs_skinning(child_node):
			skin_dynamic_object(current_skin, child_node);
		if (child_node.is_in_group("matcap")):
			skin_matcap(current_skin, child_node);

func skin():
	var current_ego_scene = get_node_or_null("ego/ROOT");
	if current_ego_scene and current_ego_scene.has_method("get_override_skin"):
		return current_ego_scene.get_override_skin(time_of_day, solar_angle_time_of_day, mars_mode)
	
	if (platform == PLATFORM.M3):
		if (time_of_day == TIME_OF_DAY.DAY):
			return get_node("skin_m3_day")
		elif (time_of_day == TIME_OF_DAY.NIGHT):
			if (solar_angle_time_of_day == TIME_OF_DAY.DAY):
				return get_node("skin_m3_daydark")
			else:
				return get_node("skin_m3_night")
	elif (platform == PLATFORM.CORIANDER):
		if (time_of_day == TIME_OF_DAY.DAY):
			return get_node("skin_cori_day")
		else:
			return get_node("skin_cori_night")
	elif (platform == PLATFORM.CORIANDER_CONTROLS):
		if (time_of_day == TIME_OF_DAY.DAY):
			return get_node("skin_cori_controls_day")
		else:
			return get_node("skin_cori_controls_night")
	elif (platform == PLATFORM.CORIANDER_X_CONTROLS):
		if (time_of_day == TIME_OF_DAY.DAY):
			return get_node("skin_corix_controls_day")
		else:
			return get_node("skin_corix_controls_night")
	elif (platform == PLATFORM.SEMI):
		if (time_of_day == TIME_OF_DAY.DAY):
			return get_node("semi_day")
		else:
			return get_node("semi_night")
	else:
		if (time_of_day == TIME_OF_DAY.DAY):
			match ego_version:
				EGO_MODEL_VERSION.V0:
					return get_node("skin_sx_day_legacy")
				EGO_MODEL_VERSION.V1:
					return get_node("skin_sx_day")
		else:
			match ego_version:
				EGO_MODEL_VERSION.V0:
					return get_node("skin_sx_night_legacy")
				EGO_MODEL_VERSION.V1:
					return get_node("skin_sx_night")
	
func dyn_object_shader(node):
	if (platform == PLATFORM.SX_TEGRA):
		return load("res://dymanic_objects/surround_car_tegra.shader");
	elif node.is_in_group("keep_shader"):
		return load("res://dymanic_objects/surround_car_ice.shader");
	else:
		return load("res://shaders/matcap_greyscale_ao.shader");


func skin_matcap(skin, node):
	var mat = node.get_surface_material(0);
	mat.set_shader_param("u_highlight_offset", skin.colors.matcap_tint);
	mat.set_shader_param("u_highlight_mul", skin.colors.matcap_mul);
	mat.set_shader_param("u_bgcolor", get_background_color());

func skin_dynamic_object(skin, node):
	var mat = node.get_surface_material(0);
	mat.set_shader(dyn_object_shader(node));
	mat.set_shader_param("light_intensity", skin.colors.surround_obj_light_intensity);
	mat.set_shader_param("ambient_light_level", max(0.2, skin.colors.surround_obj_light_ambient));
	mat.set_shader_param("bgcolor", get_background_color());


onready var bev_edge_bottom = preload("res://shaders/bev_road_edge_bottom.material");
onready var bev_edge_top = preload("res://shaders/bev_road_edge_top.material");
onready var bev_edge_simple = preload("res://shaders/bev_road_edge_simple.material");
onready var bev_edge_simple2 = preload("res://shaders/bev_road_edge_simple2.material");
onready var bev_lines_mat = preload("res://shaders/bev_lines.material");
onready var bev_points_mat = preload("res://shaders/bev_points.material");
onready var bev_voxels_mat = preload("res://shaders/bev_voxel.material");

onready var fsd_light_skin = preload("res://skins/fsd_dev_light.tres");
onready var fsd_dark_skin = preload("res://skins/fsd_dev_dark.tres");

var use_fsd_dev_skin = true;

func skin_bevedge(mat):
	
	var bev_skin = current_skin.colors;

	if use_fsd_dev_skin:
		if get_background_color().gray() > 0.5:
			bev_skin = fsd_light_skin;
		else:
			bev_skin = fsd_dark_skin;

	if bev_skin and mat:
		mat.set_shader_param("background_color", get_background_color())
		mat.set_shader_param("curb_ao", bev_skin.bev_roadway_ao)
		mat.set_shader_param("road_color", bev_skin.bev_roadway)
		mat.set_shader_param("curb_color", bev_skin.bev_curb_top)
		mat.set_shader_param("curb_side", bev_skin.bev_curb_side)
		mat.set_shader_param("curb_outter", bev_skin.bev_curb_outter)
		mat.set_shader_param("yellow_line_paint", bev_skin.bev_yellow_line_paint);
		mat.set_shader_param("line_paint", bev_skin.bev_line_paint);
		
	var upscale_node = get_node_or_null("BEV_road/BEV_edge/simple");
	if bev_skin and upscale_node:
		var upscale_node_mat = upscale_node.get_surface_material(0);
		upscale_node_mat.set_shader_param("road_color", bev_skin.bev_roadway)
		upscale_node_mat.set_shader_param("edge_color", bev_skin.bev_curb_side)
		upscale_node_mat.set_shader_param("cloud_color", bev_skin.bev_cloud)
		upscale_node_mat.set_shader_param("background_color", get_background_color())

func set_override_skin(skin):
	print("set_override_skin ", skin.name)
	override_skin = skin

func force_update_env():
	var skin = override_skin if override_skin != null else current_skin

	var worldEnv = get_node("WorldEnvironment").get_environment();
	var envRot = skin.env.background_rotation_drive;
	var bgEnergy = skin.env.background_energy_drive;
	var ambiantEnergy = skin.env.background_ambient_drive;
	var enable_skybox = true;
	if (mode == MODE.PARK):
		print("park mode")
		enable_skybox = false;
		envRot = skin.env.background_rotation_park;
		bgEnergy = skin.env.background_energy_park;
		ambiantEnergy = skin.env.background_ambient_park;
		
	worldEnv.background_sky_rotation_degrees = envRot;
	worldEnv.background_energy = bgEnergy;
	worldEnv.ambient_light_energy = ambiantEnergy;

func update_env():
	if not Engine.editor_hint:
		return ;
	force_update_env();

onready var black_sign_content = [
	preload("res://models/Signs/China/shaders/Yield_text_China_mat.tres"), 
	preload("res://models/Signs/EU/shaders/allways_EU_mat.tres"), 
	preload("res://models/Signs/EU/shaders/Roundabout_EU_mat.tres"), 
	preload("res://models/Signs/EU/shaders/Crossroad_EU_mat.tres"), 
	preload("res://models/Signs/EU/shaders/Numbers_EU_mat.tres")
]

onready var stop_sign_text_mat = [
	preload("res://models/Signs/Taiwan/shaders/Stop_text_Taiwan_mat.tres"), 
	preload("res://models/Signs/China/shaders/Stop_text_China_mat.tres"), 
	preload("res://models/Signs/US/shaders/Stop_text_US_mat.tres"), 
	preload("res://models/Signs/Canada/shaders/Stop_text_Canada_mat.tres"), 
	preload("res://models/Signs/Japan/shaders/Stop_text_Japan_mat.tres"), 
	preload("res://models/Signs/Mexico/shaders/Stop_text_Mexico_mat.tres"), 
	preload("res://models/Signs/SKorea/shaders/Stop_text_SKorea_mat.tres"), 
	preload("res://models/Signs/Thailand/shaders/Stop_text_Thailand_mat.tres"), 
	preload("res://models/Signs/UAE/shaders/Stop_text_UAE_mat.tres")
]

var linesColorLUT = Image.new();
var linesColorLUTTexture = ImageTexture.new();

var edgeTypeColorLUT = Image.new();
var edgeTypeColorLUT2 = Image.new();
var edgeTypeColorLUTTexture = ImageTexture.new();
var edgeTypeColorLUTTexture2 = ImageTexture.new();
		
onready var us_stop_sign_text_mat = preload("res://models/Signs/US/shaders/Numbers_US_mat.tres");

var override_background_color = 0;

func set_override_background_color(color):
	if override_background_color != color:
		override_background_color = color;
		update_skin();
	
func get_background_color():
	if override_background_color:
		return Color(override_background_color)
	elif current_skin:
		return current_skin.env.background_color;
	else:
		return Color(0)

func update_skin():
	if (is_inside_tree()):
		var prev_skin = current_skin
		current_skin = skin();
		print("Changing skin from " + (prev_skin.name if prev_skin else "none") + " to " + (current_skin.name if current_skin else "null"))
		var skin = current_skin;
		var dynamic_objects = get_tree().get_nodes_in_group("dynamic_object");
		for obj in dynamic_objects:
			skin_dynamic_object(skin, obj);

		var matcap_objects = get_tree().get_nodes_in_group("matcap");
		for obj in matcap_objects:
			skin_matcap(skin, obj);
			
		var traffic_lights = get_tree().get_nodes_in_group("TL");
		for obj in traffic_lights:
			obj.bulb_alpha = skin.colors.traffic_light_bulb_energy;
			
		var stoplines = get_tree().get_nodes_in_group("stop_line");
		for obj in stoplines:
			var mat = obj.get_surface_material(0);
			mat.set_shader_param("u_color", skin.colors.stop_line);
			
		var lanelines = get_tree().get_nodes_in_group("lane_line");
		for obj in lanelines:
			var mat = obj.get_surface_material(0);
			mat.set_shader_param("color", skin.colors.lane_line_disengaged);

		var worldEnv = get_node("WorldEnvironment").get_environment();
		worldEnv.background_color = get_background_color();
		if not prev_skin or skin.env.panorama != worldEnv.background_sky.panorama:
			worldEnv.background_sky.panorama = skin.env.panorama;
		if not prev_skin or skin.env.panorama_radiance_size != worldEnv.background_sky.radiance_size:
			worldEnv.background_sky.radiance_size = skin.env.panorama_radiance_size
		update_env();

		var road_marking_mat = load("res://shaders/road_markings_mat.tres");
		road_marking_mat.set_shader_param("u_color", current_skin.colors.lane_line_disengaged);
		
		var ego_model = get_node_or_null("ego/ROOT");
		if ego_model and ("skybox_enable" in ego_model):
			ego_model.skybox_enable = (mode == MODE.DRIVE)
			ego_model.skybox = skin.env.skybox;
			ego_model.skybox_intensity = skin.env.skybox_intensity;
		else:
			printerr("failed to find ego/model")

		if us_stop_sign_text_mat:
			us_stop_sign_text_mat.set_shader_param("Color", current_skin.colors.us_sign_content);

		if stop_sign_text_mat:
			for mat in stop_sign_text_mat:
				mat.set_shader_param("Color", current_skin.colors.sign_white_text);

		if black_sign_content:
			for mat in black_sign_content:
				mat.set_shader_param("Color", current_skin.colors.eu_sign_content);
				
		var cipv = get_node_or_null("staging/speedform_LOD1/Simplygon_Proxy_e94573d7-09c7-4945-b794-ccaf68137feb2")
		if cipv:
			cipv.get_surface_material(0).set_shader_param("highlight", current_skin.colors.surround_obj_control_tint)
		
		var fcw_warn = get_node_or_null("staging/speedform_LOD3/Simplygon_Proxy_e94573d7-09c7-4945-b794-ccaf68137feb2")
		if fcw_warn:
			fcw_warn.get_surface_material(0).set_shader_param("highlight", current_skin.colors.surround_obj_warning_tint)

		var parked = get_node_or_null("staging/speedform_LOD4/Simplygon_Proxy_e94573d7-09c7-4945-b794-ccaf68137feb2")
		if parked:
			parked.get_surface_material(0).set_shader_param("opacity", 0.25)

			
		parked = get_node_or_null("staging/speedform_LOD5/Simplygon_Proxy_e94573d7-09c7-4945-b794-ccaf68137feb2")
		if parked:
			parked.get_surface_material(0).set_shader_param("opacity", 0.25)

			
		var grayLine = get_node_or_null("staging/test_grayline1")
		var yellowLine = get_node_or_null("staging/test_grayline2")
		if grayLine: grayLine.get_surface_material(0).albedo_color = current_skin.colors.bev_line_paint;
		if yellowLine: yellowLine.get_surface_material(0).albedo_color = current_skin.colors.bev_yellow_line_paint;
		
		var bev_skin = current_skin.colors;
		if use_fsd_dev_skin:
			if get_background_color().gray() > 0.5:
				bev_skin = fsd_light_skin;
			else:
				bev_skin = fsd_dark_skin;
				
		if bev_skin:
			
			linesColorLUT.create(5, 1, false, Image.FORMAT_RGBA8);
			linesColorLUT.lock()
			linesColorLUT.set_pixel(0, 0, bev_skin.bev_line_paint);
			linesColorLUT.set_pixel(1, 0, bev_skin.bev_line_paint);
			linesColorLUT.set_pixel(2, 0, bev_skin.bev_yellow_line_paint);
			linesColorLUT.set_pixel(3, 0, bev_skin.autopilot_blue);
			linesColorLUT.set_pixel(4, 0, bev_skin.bev_point_divider);
			linesColorLUT.unlock()
	
			linesColorLUTTexture.create_from_image(linesColorLUT, 0);
			
			edgeTypeColorLUT2.create(255, 1, false, Image.FORMAT_RGBA8);
			edgeTypeColorLUT2.fill(Color(1, 0, 0, 0));
			edgeTypeColorLUT2.lock();
			edgeTypeColorLUT2.set_pixel(0, 0, bev_skin.bev_curb_side);
			edgeTypeColorLUT2.set_pixel(1, 0, bev_skin.bev_edge_island);
			edgeTypeColorLUT2.set_pixel(2, 0, bev_skin.bev_yellow_line_paint);
			edgeTypeColorLUT2.set_pixel(3, 0, bev_skin.bev_edge_divider);
			edgeTypeColorLUT2.unlock()
	
			edgeTypeColorLUT.create(255, 1, false, Image.FORMAT_RGBA8);
			edgeTypeColorLUT.fill(Color(0, 0, 0, 0));
			edgeTypeColorLUT.lock();
			edgeTypeColorLUT.set_pixel(0, 0, bev_skin.bev_line_paint);
			edgeTypeColorLUT.set_pixel(1, 0, bev_skin.bev_yellow_line_paint);
			edgeTypeColorLUT.set_pixel(2, 0, bev_skin.autopilot_blue);
			edgeTypeColorLUT.set_pixel(3, 0, bev_skin.lane_line_warning);
			edgeTypeColorLUT.unlock()

		edgeTypeColorLUTTexture.create_from_image(edgeTypeColorLUT, 0);
		edgeTypeColorLUTTexture2.create_from_image(edgeTypeColorLUT2, 0);
		
		if bev_edge_simple:
			bev_edge_simple.set_shader_param("edge_color_lut", edgeTypeColorLUTTexture);
			
		if bev_edge_simple2:
			bev_edge_simple2.set_shader_param("edge_color_lut", edgeTypeColorLUTTexture2);
		
		if bev_lines_mat:
			bev_lines_mat.set_shader_param("bev_line_color", linesColorLUTTexture);
			
		if bev_points_mat:
			bev_points_mat.set_shader_param("bev_color", linesColorLUTTexture);

		skin_bevedge(bev_edge_top);
		skin_bevedge(bev_edge_bottom);
		skin_bevedge(bev_edge_simple);
		
		if bev_voxels_mat and bev_skin:
			bev_voxels_mat.set_shader_param("u_top_color", bev_skin.voxel_top_layer);
			bev_voxels_mat.set_shader_param("u_bottom_color", bev_skin.voxel_bottom_layer);
			
		if launch_mode_scene and launch_mode_scene.has_method("set_bg_color"):
			launch_mode_scene.set_bg_color(get_background_color())
		

func set_mode(v):
	mode = v;
	update_skin();

func set_time_of_day(tod):
	print("set_time_of_day: ", tod);
	time_of_day = tod;
	update_ego_time_of_day();
	update_ghost_time_of_day();
	update_skin();

func set_solar_angle_time_of_day(tod):
	print("set_solar_angle_time_of_day: ", tod)
	solar_angle_time_of_day = tod;
	update_skin();

func set_mars_mode(mars):
	print("set_mars_mode: " + String(mars));
	mars_mode = mars;
	update_skin();

func set_platform(plat):
	print("set_platform:" + String(plat));
	platform = plat;
	update_skin();


func _ready():
	if Engine.editor_hint:
		update_ego();
	else:
		set_smart_shift_state(SMART_SHIFT_STATE.NONE);
		
	update_skin();
	fsd_light_skin.connect("changed", self, "update_skin")
	fsd_dark_skin.connect("changed", self, "update_skin")

func get_yield_sign_by_locale(viz_locale):
	match (viz_locale):
		"CN": return "res://models/Signs/China/Yield_01_China.tscn"
		"EU": return "res://models/Signs/EU/Yield_01_EU.tscn"
	return "res://models/Signs/US/Yield_01_US.tscn"

func get_stop_sign_by_locale(viz_locale):
	match (viz_locale):
		"CA": return "res://models/Signs/US/Stop_01_US.tscn"
		"CF": return "res://models/Signs/Canada/Stop_01_Canada.tscn"
		"CN": return "res://models/Signs/China/Stop_01_China.tscn"
		"MX": return "res://models/Signs/Mexico/Stop_01_Mexico.tscn"
	return "res://models/Signs/US/Stop_01_US.tscn"


func get_static_object_paths(viz_locale):
	print("get_static_object_path: " + viz_locale)
	if viz_locale == "UNKNOWN": viz_locale = "US"
	var us_can = (viz_locale == "US" or viz_locale == "CA" or viz_locale == "CF");
		
	var static_object = {
		"POLE": "res://static_objects/pole.tscn", 
		"STOP_SIGN": get_stop_sign_by_locale(viz_locale), 
		"YIELD": get_yield_sign_by_locale(viz_locale), 
		"TRAFFIC_LIGHT_UNKNOWN": "res://static_objects/traffic_light.tscn", 
		"CONE": "res://static_objects/cone.tscn", 
		"TRASH_BIN": "res://static_objects/trashbin.tscn", 
		"ROAD_MARKING_ARROW_LEFT": "res://road_markings/left_arrow.tscn", 
		"ROAD_MARKING_ARROW_RIGHT": "res://road_markings/right_arrow.tscn", 
		"ROAD_MARKING_ARROW_LEFT_RIGHT": "res://road_markings/left_right_arrow.tscn", 
		"ROAD_MARKING_ARROW_FORWARD": "res://road_markings/forward_arrow.tscn", 
		"ROAD_MARKING_ARROW_FORWARD_LEFT": "res://road_markings/left_forward.tscn", 
		"ROAD_MARKING_ARROW_FORWARD_RIGHT": "res://road_markings/right_forward_arrow.tscn", 
		"ROAD_MARKING_ARROW_FORWARD_LEFT_RIGHT": "res://road_markings/left_right_forward_arrow.tscn", 
		"ROAD_MARKING_ARROW_LEFT_UTURN": "", 
		"ROAD_MARKING_ARROW_RIGHT_UTURN": "", 
		"ROAD_MARKING_ARROW_LEFT_RIGHT_UTURN": "", 
		"ROAD_MARKING_ARROW_FORWARD_UTURN": "res://road_markings/uturn_forward_arrow.tscn", 
		"ROAD_MARKING_ARROW_FORWARD_LEFT_UTURN": "", 
		"ROAD_MARKING_ARROW_FORWARD_RIGHT_UTURN": "", 
		"ROAD_MARKING_ARROW_FORWARD_LEFT_RIGHT_UTURN": "", 
		"ROAD_MARKING_ARROW_UTURN ": "res://road_markings/uturn_arrow.tscn", 
		"ROAD_MARKING_HOV": "res://road_markings/hov_lane.tscn", 
		"ROAD_MARKING_RAILROAD": "res://road_markings/railroad.tscn", 
		"ROAD_MARKING_BIKE": "res://road_markings/bike_lane.tscn", 
		"ROAD_MARKING_MERGE_LEFT": "res://road_markings/merge_left.tscn", 
		"ROAD_MARKING_MERGE_RIGHT": "res://road_markings/merge_right.tscn", 
		"ROAD_MARKING_STOP": "res://road_markings/stop.tscn", 
		"ROAD_MARKING_HANDICAP": "res://road_markings/handicap_stall.tscn", 
		"SPEED_BUMP": "res://static_objects/speed_bump.tscn", 
	}
	
	if us_can:
		static_object["SPEED_SIGN"] = "res://models/Signs/US/Speed_Limit_Max_01_US.tscn";
		static_object["SPEED_SIGN_SCHOOL"] = "res://models/Signs/US/Speed_Limit_School_Zone_01_US.tscn";
		static_object["SPEED_SIGN_TURN"] = "res://models/Signs/US/Speed_Limit_Adv_Curve_01_US.tscn";
		static_object["SPEED_SIGN_BUMP"] = "res://models/Signs/US/Speed_Limit_Adv_01_US.tscn";
		static_object["SPEED_SIGN_EXIT"] = "res://models/Signs/US/Speed_Limit_Adv_Exit_01_US.tscn";
		static_object["SPEED_SIGN_OVERHEAD"] = "res://models/Signs/US/Speed_Limit_Over_01_US.tscn";
		static_object["SPEED_SIGN_DIGITAL"] = "res://models/Signs/US/Speed_Limit_Over_01_US.tscn";
		static_object["SPEED_SIGN_UPCOMING"] = "res://models/Signs/US/Speed_Limit_Ahead_01_US.tscn";
		static_object["SPEED_SIGN_CONDITIONAL"] = "res://models/Signs/US/Speed_Limit_Adv_01_US.tscn";
		static_object["SPEED_LIMIT_SIGN_ADVISORY"] = "res://models/Signs/US/Speed_Limit_Adv_01_US.tscn";

	else:
		static_object["SPEED_SIGN"] = "res://models/Signs/EU/Speed_Limit_Max_EU.tscn";
		static_object["SPEED_SIGN_SCHOOL"] = "res://models/Signs/EU/Speed_Limit_Max_EU.tscn";
		static_object["SPEED_SIGN_TURN"] = "res://models/Signs/EU/Speed_Limit_Max_EU.tscn";
		static_object["SPEED_SIGN_BUMP"] = "res://models/Signs/EU/Speed_Limit_Max_EU.tscn";
		static_object["SPEED_SIGN_EXIT"] = "";
		static_object["SPEED_SIGN_OVERHEAD"] = "res://models/Signs/EU/Speed_Limit_Over_EU.tscn";
		static_object["SPEED_SIGN_DIGITAL"] = "res://models/Signs/EU/Speed_Limit_Over_EU.tscn";
		static_object["SPEED_SIGN_UPCOMING"] = "res://models/Signs/EU/Speed_Limit_Ahead_EU.tscn";
		static_object["SPEED_SIGN_CONDITIONAL"] = "res://models/Signs/EU/Speed_Limit_Max_EU.tscn";
		static_object["SPEED_LIMIT_SIGN_ADVISORY"] = "res://models/Signs/EU/Speed_Limit_Max_EU.tscn";
		static_object["SPEED_SIGN_ENDS"] = "res://models/Signs/EU/Speed_Limit_End_EU.tscn"
	
	return static_object;

enum SMART_SHIFT_STATE{NONE = 0, DOORS = 1, SEATBELT = 2, PRIMED_DRIVE = 3, PRIMED_REVERSE = 4, READY_DRIVE = 5, READY_REVERSE = 6}
export (SMART_SHIFT_STATE) var smart_shift_state setget set_smart_shift_state
var use_blue_smart_shift_glow = false;

func set_smart_shift_state(state):

	if ( not is_inside_tree()): return ;
	print("set_smart_shift_state:" + String(state))
	smart_shift_state = state;
	var current_ego_scene = get_node_or_null("ego/ROOT");
	var forwardsArrow = get_node_or_null("ego/SmartShiftArrowDrive");
	var reverseArrow = get_node_or_null("ego/SmartShiftArrowReverse");
	var forwardsArrowSprite = forwardsArrow.get_node_or_null("ArrowSprite");
	var reverseArrowSprite = reverseArrow.get_node_or_null("ArrowSprite");
	var seatbelt = null;
	if (current_ego_scene):
		seatbelt = current_ego_scene.get_node_or_null("SeatbeltWarning");
	
	var driveGlow = get_node_or_null("ego/SmartShiftGlowDrive");
	var reverseGlow = get_node_or_null("ego/SmartShiftGlowReverse");
	
	forwardsArrowSprite.set_show_fade(state == SMART_SHIFT_STATE.READY_DRIVE);
	reverseArrowSprite.set_show_fade(state == SMART_SHIFT_STATE.READY_REVERSE);

	var is_dark = get_background_color().g < 0.5;

	if (seatbelt): seatbelt.set_show_fade(state == SMART_SHIFT_STATE.SEATBELT);
	if (current_ego_scene): current_ego_scene.fade_roof = state == SMART_SHIFT_STATE.SEATBELT;
		
	driveGlow.set_dark_background(is_dark);
	reverseGlow.set_dark_background(is_dark);

	match state:
		SMART_SHIFT_STATE.NONE, SMART_SHIFT_STATE.DOORS, SMART_SHIFT_STATE.SEATBELT:
			driveGlow.state = driveGlow.GLOW_STATE.OFF;
			reverseGlow.state = reverseGlow.GLOW_STATE.OFF;
		SMART_SHIFT_STATE.PRIMED_DRIVE:
			driveGlow.state = driveGlow.GLOW_STATE.BLUE_PULSE;
			reverseGlow.state = reverseGlow.GLOW_STATE.OFF;
		SMART_SHIFT_STATE.PRIMED_REVERSE:
			driveGlow.state = driveGlow.GLOW_STATE.OFF;
			reverseGlow.state = reverseGlow.GLOW_STATE.BLUE_PULSE;
		SMART_SHIFT_STATE.READY_DRIVE:
			driveGlow.state = driveGlow.GLOW_STATE.BLUE_READY if use_blue_smart_shift_glow else driveGlow.GLOW_STATE.WHITE_READY;
			reverseGlow.state = reverseGlow.GLOW_STATE.OFF;
		SMART_SHIFT_STATE.READY_REVERSE:
			driveGlow.state = driveGlow.GLOW_STATE.OFF;
			reverseGlow.state = reverseGlow.GLOW_STATE.BLUE_READY if use_blue_smart_shift_glow else reverseGlow.GLOW_STATE.WHITE_READY;

func set_use_blue_smart_shift_glow(use_blue: bool):
	use_blue_smart_shift_glow = use_blue;
