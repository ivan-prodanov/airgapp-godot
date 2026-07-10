tool 
extends Node


export (bool) var run_snapshot setget set_run_snapshot

enum TIME_OF_DAY{DAY_ONLY = 0, NIGHT_ONLY = 1, DAY_AND_NIGHT = 2}
export (TIME_OF_DAY) var time_of_day = TIME_OF_DAY.DAY_AND_NIGHT;

export (NodePath) var debug_camera_of_interest: NodePath;

export (String, DIR, GLOBAL) var debug_export_directory = "/tmp/";

var asset_gen_complete = false;
var asset_gen_success = false;
func set_run_snapshot(v):
	if v:
		run_snapshot = false;
		run(debug_export_directory, "MODEL_X", true);

var viewport_whitelist = {"MODEL_S": ["AboutControlsPanel", "HomeLinkTrainer", "ChargingGhost", "ChargeScreenGhost", "TopDown", "TrackMode", "CarInteriorView", "SuspensionView_MS", "SuspensionGhost"], 
									"MODEL_S2": ["AboutControlsPanel", "HomeLinkTrainer", "ChargingGhost", "ChargeScreenGhost", "TopDown", "TrackMode", "CarInteriorView", "SuspensionView_MS", "SuspensionGhost"], 
									"MODEL_X": ["AboutControlsPanel", "HomeLinkTrainer", "ChargingGhost", "ChargeScreenGhost", "TopDown", "TrackMode", "CarInteriorView", "SuspensionView_MX", "SuspensionGhost"], 
									"MODEL_3": ["AboutControlsPanel", "HomeLinkTrainer", "ChargingGhost", "ChargeScreenGhost", "TopDown", "TrackMode", "CarInteriorView", "LockScreen_M3"], 
									"MODEL_Y": ["AboutControlsPanel", "HomeLinkTrainer", "ChargingGhost", "ChargeScreenGhost", "TopDown", "TrackMode", "CarInteriorView", "LockScreen_M3"], 
									"MODEL_S3": ["AboutControlsPanel", "HomeLinkTrainer", "ChargingGhost", "ChargeScreenGhost", "TopDown", "TrackMode", "CarInteriorView", "SuspensionGhost", "LockScreen_Coriander"], 
									"MODEL_X2": ["AboutControlsPanel", "HomeLinkTrainer", "ChargingGhost", "ChargeScreenGhost", "TopDown", "TrackMode", "CarInteriorView", "SuspensionGhost", "LockScreen_Coriander"]}

enum TIME_OF_DAY_SKIN{DAY = 0, NIGHT = 1}


func whitelist_viewports(carmodel: String, viewport_names: Array):
	viewport_whitelist[carmodel] = viewport_names;
	var viewports_string = carmodel + " +=";
	for viewport in viewport_names:
		viewports_string = viewports_string + " " + viewport;
	print("Added the following to viewport whitelist: " + viewports_string);

func viewport_whitelisted(carmodel: String, viewport_name: String):
	if not viewport_whitelist.has(carmodel):
		return false;

	if not viewport_whitelist[carmodel].has(viewport_name):
		return false;

	return true;

func run_asset_gen(basepath: String, carmodel: String):
	print("run_asset_gen: " + basepath + "; car model: " + carmodel)
	asset_gen_complete = false;
	run(basepath, carmodel, false);


func asset_gen_completed():
	return asset_gen_complete;


func asset_gen_completed_v2(basepath: String, carmodel: String):
	var dir = Directory.new()
	if not dir.dir_exists(basepath):
		print(basepath, " does not exist")
		return false;
	var viewport = get_node("SnapshotRenderViewport");
	for node in viewport.get_children():
		if not node or not viewport_whitelisted(carmodel, node.name):
			continue;
		for time_of_day in ["day", "night"]:
			var file_path = basepath + "/" + time_of_day + "/" + node.name + ".png";
			if ( not dir.file_exists(file_path)):
				print(file_path, " does not exist")
				return false;
	return true

func errstr(err):
	if err:
		return "ERROR"
	else:
		return "SUCCESS"

func run(basedir, carmodel, debugTakeSingleImage):

	yield(VisualServer, "frame_post_draw")

	print("Run Asset Gen:")
	
	if debugTakeSingleImage:
		var cur_time: Dictionary = OS.get_datetime();
		var cur_time_string: String = "%d_%02d_%02d_%02d:%02d:%02d" % [cur_time.year, cur_time.month, cur_time.day, cur_time.hour, cur_time.minute, cur_time.second];
		basedir += "/gen_" + cur_time_string;
	
	var dir = Directory.new()
	dir.open("/");
	dir.make_dir_recursive(basedir + "/day");
	dir.make_dir_recursive(basedir + "/night");
	print(basedir);
	var egoNode = get_parent().get_node("ego");
	
	var success_flag = true;
	
	var viewport = get_node("SnapshotRenderViewport");
	print(viewport);
	
	var job_log: String = "";
	
	for node in viewport.get_children():
		node.set_visible(false);
	
	var debug_cam_of_interest = get_node_or_null(debug_camera_of_interest);
	if debug_cam_of_interest and debug_cam_of_interest.name == "Camera":
		debug_cam_of_interest = debug_cam_of_interest.get_parent();
		
	var original_time_of_day = get_parent().time_of_day;
	var original_ghost_car = get_parent().ghost_car;
		
	for node in viewport.get_children():
		if not node:
			job_log += "Error: Null node\n"
			continue;
			
		if debugTakeSingleImage and debug_cam_of_interest and debug_cam_of_interest != node:
			job_log += "Skipping " + node.name + " (not camera of interest) \n"
			continue;
		
		if not viewport_whitelisted(carmodel, node.name):
			job_log += "Skipping " + node.name + "\n"
			continue;
	
		node.set_visible(true);
		
		if (node.has_method("setup")): node.setup();
		var cam = node.get_node("Camera");
		if not cam:
			job_log += "Skipping: " + node.name + " (reason: missing camera)\n"
			continue;
		if cam.hide_standard_ego or cam.ghost_car_config: egoNode.own_world = true;
		
		var current_ego_scene = egoNode.get_node_or_null("ROOT");
		if current_ego_scene and current_ego_scene.has_method("set_fade_roof"):
			current_ego_scene.set_fade_roof(cam.hide_roof, false);
				
		cam.make_current();
		viewport.transparent_bg = cam.transparent;
		viewport.set_size(Vector2(cam.width, cam.height));

		var time = OS.get_time();
		var current_time = String(time.hour) + ":" + String(time.minute) + ":" + String(time.second);
		job_log += current_time + " Starting: " + node.name + ", "\
		+ String(cam.width) + "x" + String(cam.height)\
		+ ", trans:" + String(cam.transparent) + "\n";
		
		get_parent().time_of_day = TIME_OF_DAY_SKIN.NIGHT;
		get_parent().ghost_car = cam.ghost_car_config;
		yield(VisualServer, "frame_post_draw")
		
		var times_of_day = ["day", "night", "serviceUI"]
		if cam.export_dark_day:
			times_of_day.append("darkDay")
			if not dir.dir_exists(basedir + "/darkDay"):
				dir.make_dir_recursive(basedir + "/darkDay")
		
		for time_of_day in times_of_day:
			var exclude_from_service_ui = cam.exclude_from_service_ui and not cam.service_ui_only
			if ( not ((exclude_from_service_ui and time_of_day == "serviceUI") or (cam.service_ui_only and time_of_day != "serviceUI"))):
				if (time_of_day == "day"):
					get_parent().time_of_day = TIME_OF_DAY_SKIN.DAY;
					get_parent().solar_angle_time_of_day = TIME_OF_DAY_SKIN.DAY;
					if terrain != null:
						terrain.set_day_mode(true)
						terrain.set_solar_angle_day_mode(true)
				elif (time_of_day == "darkDay"):
					get_parent().time_of_day = TIME_OF_DAY_SKIN.NIGHT;
					get_parent().solar_angle_time_of_day = TIME_OF_DAY_SKIN.DAY;
					if terrain != null:
						terrain.set_day_mode(false)
						terrain.set_solar_angle_day_mode(true)
				else:
					get_parent().time_of_day = TIME_OF_DAY_SKIN.NIGHT;
					get_parent().solar_angle_time_of_day = TIME_OF_DAY_SKIN.NIGHT;
					if terrain != null:
						terrain.set_day_mode(false)
						terrain.set_solar_angle_day_mode(false)
				
				if current_ego_scene.has_node("SuspensionAnimation") and cam.suspension_level_percent >= 0.0:
					var suspension: AnimationPlayer = current_ego_scene.get_node("SuspensionAnimation")
					suspension.seek(cam.suspension_level_percent * suspension.current_animation_length, true)
				
				current_ego_scene.set_charge_port_open(cam.open_charge_port)
				current_ego_scene.set_trunk_open(cam.open_trunk)
					
				var override_skin_name = ""
				if (time_of_day == "day" and cam.day_skin_override != ""):
					override_skin_name = cam.day_skin_override
				elif (time_of_day == "night" and cam.night_skin_override != ""):
					override_skin_name = cam.night_skin_override
						
				if override_skin_name != "":
					var override_skin = get_parent().get_node_or_null(override_skin_name)
					if override_skin:
						get_parent().set_override_skin(override_skin)
				
				var previous_paint_color_name = current_ego_scene.paint_color_name;
				var previous_paint_color_override = current_ego_scene.paint_color_override;
				var previous_skin = "";
				if (current_ego_scene.has_method("set_car_skin") and (cam.enforce_ego_color or time_of_day == "serviceUI")):
					previous_skin = current_ego_scene.current_skin
					current_ego_scene.set_car_skin("", true)
				if (cam.enforce_ego_color or time_of_day == "serviceUI"):
					if (current_ego_scene.get("use_regular_paint_colors") != null): current_ego_scene.use_regular_paint_colors = true;
					current_ego_scene.set_paint_color_with_override(cam.color_override, cam.color_override);
				if (time_of_day == "serviceUI" and cam.service_ui_scaling_factor > 1): viewport.set_size(Vector2(cam.width * asset_gen_view_scale * cam.service_ui_scaling_factor, cam.height * asset_gen_view_scale * cam.service_ui_scaling_factor));
				else: viewport.set_size(Vector2(cam.width * asset_gen_view_scale, cam.height * asset_gen_view_scale));
			
			if (time_of_day == "day"):
				get_parent().time_of_day = TIME_OF_DAY_SKIN.DAY;
			else:
				get_parent().time_of_day = TIME_OF_DAY_SKIN.NIGHT;
				
			var override_skin_name = ""
			if (time_of_day == "day" and cam.day_skin_override != ""):
				override_skin_name = cam.day_skin_override
			elif (time_of_day == "night" and cam.night_skin_override != ""):
				override_skin_name = cam.night_skin_override
					
			if override_skin_name != "":
				var override_skin = get_parent().get_node_or_null(override_skin_name)
				if override_skin:
					get_parent().set_override_skin(override_skin)
				
				if cam.enforce_ego_color or (time_of_day == "serviceUI"):
					if (current_ego_scene.get("use_regular_paint_colors")): current_ego_scene.use_regular_paint_colors = false;
					
					if (previous_paint_color_name): current_ego_scene.set_paint_color_by_name(previous_paint_color_name)
					else: current_ego_scene.set_paint_color_override(previous_paint_color_override)
					
					if (current_ego_scene.has_method("set_car_skin") and previous_skin):
						current_ego_scene.set_car_skin(previous_skin, true)

		if (node.has_method("teardown")): node.teardown();
		node.set_visible(false);
		if cam.hide_standard_ego or cam.ghost_car_config: egoNode.own_world = false;
	
	get_parent().time_of_day = original_time_of_day;
	get_parent().ghost_car = original_ghost_car;
	
	asset_gen_complete = true;
	asset_gen_success = success_flag;
	
	job_log += "Finished\n";
	

	var file = File.new();
	if success_flag:
		file.open(basedir + "/success_sentinel", File.WRITE)
	else:
		file.open(basedir + "/fail_log", File.WRITE)
	file.store_string(job_log)
	file.close()
