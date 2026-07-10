tool 
class_name Snapshot
extends Node

const GodotMsg = preload("res://mobile/scripts/GodotMsg.gd")
const ReactMsg = preload("res://mobile/scripts/ReactMsg.gd")

enum SnapshotPoseType{
	TOPDOWN, 
	TOPDOWN_FADE_ROOF, 
	THREEQUARTER, 
	WIDGET, 
	FRONT, 
	REAR, 
	LEFTPROFILE, 
	RIGHTPROFILE, 
	ENERGY_CROPPED, 
	ENERGY_UNCROPPED, 
	PARKED, 
}

export (SnapshotPoseType) var pose
export (float) var default_fov: float = 40

signal on_pose_settings_update(pose_settings, model_key)

onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm")
onready var product_manager: ProductManager = get_node("/root/Mobile/ProductManager")
onready var pool_manager: PoolManager = get_node("/root/Mobile/PoolManager")
onready var LOG: LOG = get_node("/root/Mobile/Log")

onready var viewport: Viewport = get_node("Viewport")
onready var slot: Spatial = get_node("Viewport/Slot")
onready var camera: Camera = get_node("Viewport/Slot/Camera")
onready var world_env: WorldEnvironment = get_node("Viewport/WorldEnvironment")
onready var env: Environment = world_env.environment

const DEFAULT_CAMERA_ROTATION: Vector3 = Vector3( - 90, 0, 0)
const DEFAULT_CAMERA_OFFSET: Vector3 = Vector3(0, 10, 0)
const DEFAULT_ENV_ROTATION: Vector3 = Vector3.ZERO
const DEFAULT_ENV_ENERGY: float = 6.0
const DEFAULT_ENV_AMBIENT: float = 2.5

var snapshots_directory: String = "snapshots"
var screen_size: Vector2

var energy_site_type_location_offset: Vector3 = Vector3(0, 0, 0)

const SnapshotPoseSettings = {
	SnapshotPoseType.TOPDOWN: {
		"cam_rotation": DEFAULT_CAMERA_ROTATION, 
		"cam_offset": DEFAULT_CAMERA_OFFSET, 
	}, 
	SnapshotPoseType.TOPDOWN_FADE_ROOF: {
		"cam_rotation": DEFAULT_CAMERA_ROTATION, 
		"cam_offset": DEFAULT_CAMERA_OFFSET, 
	}, 
	SnapshotPoseType.THREEQUARTER: {
		"cam_rotation": Vector3( - 9.554, - 132.06, 0), 
		"cam_offset": Vector3( - 5.592, 2, - 5.375), 
		"cam_fov": 20, 
		"viewport_height": 500, 
		"viewport_width": 900, 
		"env_rotation": Vector3(0, - 11, 83), 
		"env_energy": 6, 
		"env_ambient": 2.6
	}, 
	SnapshotPoseType.WIDGET: {}, 
	SnapshotPoseType.FRONT: {
		"cam_rotation": Vector3( - 2, 180, 0), 
		"cam_offset": Vector3(0, 1, - 8), 
		"cam_fov": 20, 
		"viewport_height": 900, 
		"viewport_width": 900, 
		"env_rotation": Vector3(0, 90, - 15), 
		"env_energy": 4.2, 
		"env_ambient": 5.5
	}, 
	SnapshotPoseType.REAR: {
		"cam_rotation": Vector3( - 2, 0, 0), 
		"cam_offset": Vector3(0, 1, 8), 
		"cam_fov": 20, 
		"viewport_height": 900, 
		"viewport_width": 900, 
		"env_rotation": Vector3(30, 125, 150), 
		"env_energy": 4.2, 
		"env_ambient": 5.5
	}, 
	SnapshotPoseType.LEFTPROFILE: {
		"cam_rotation": Vector3(0, - 90, 0), 
		"cam_offset": Vector3( - 10, 0.8, 0), 
		"cam_fov": 20, 
		"viewport_height": 900, 
		"viewport_width": 1400, 
		"env_rotation": Vector3( - 40, 40, 80), 
		"env_energy": 6, 
		"env_ambient": 2.6
	}, 
	SnapshotPoseType.RIGHTPROFILE: {
		"cam_rotation": Vector3(0, 90, 0), 
		"cam_offset": Vector3(10, 0.8, 0), 
		"cam_fov": 20, 
		"viewport_height": 900, 
		"viewport_width": 1400, 
		"env_rotation": Vector3(80, 80, 0), 
		"env_energy": 6, 
		"env_ambient": 2.6
	}, 
	SnapshotPoseType.ENERGY_UNCROPPED: {
		"cam_rotation": Vector3( - 15, 5, 0), 
		"cam_offset": Vector3( - 0.12, 4.01, 11.45), 
		"cam_fov": 15, 
		"viewport_height": 164, 
		"viewport_width": 290, 
		"env_rotation": Vector3(0, - 11, 83), 
		"env_energy": 6, 
		"env_ambient": 2.6
	}, 
	SnapshotPoseType.ENERGY_CROPPED: {
		"cam_rotation": Vector3( - 10.5, 5, 0), 
		"cam_offset": Vector3(1.05, 4.725, 15.93), 
		"cam_fov": 15, 
		"viewport_height": 436, 
		"viewport_width": 296, 
		"env_rotation": Vector3(0, - 11, 83), 
		"env_energy": 6, 
		"env_ambient": 2.6
	}, 
	SnapshotPoseType.PARKED: {
		"cam_rotation": Vector3( - 25, - 138, 0), 
		"cam_offset": Vector3( - 4.128336, 3.094274, - 4.734428), 
		"cam_fov": 30, 
		"viewport_height": 500, 
		"viewport_width": 900, 
		"env_rotation": Vector3(0, - 11, 83), 
		"env_energy": 6, 
		"env_ambient": 2.6
	}, 
}


const SnapshotPoses = {
	"TOPDOWN": SnapshotPoseType.TOPDOWN, 
	"TOPDOWN_FADE_ROOF": SnapshotPoseType.TOPDOWN_FADE_ROOF, 
	"THREEQUARTER": SnapshotPoseType.THREEQUARTER, 
	"WIDGET": SnapshotPoseType.WIDGET, 
	"FRONT": SnapshotPoseType.FRONT, 
	"REAR": SnapshotPoseType.REAR, 
	"RIGHTPROFILE": SnapshotPoseType.RIGHTPROFILE, 
	"LEFTPROFILE": SnapshotPoseType.LEFTPROFILE, 
	"PARKED": SnapshotPoseType.PARKED, 
	"ENERGY_CROPPED": SnapshotPoseType.ENERGY_CROPPED, 
	"ENERGY_UNCROPPED": SnapshotPoseType.ENERGY_UNCROPPED, 
}

func _ready():
	if not Engine.editor_hint:
		env = env.duplicate()
		world_env.environment = env
	screen_size = get_viewport().size
	
	
	var dir = Directory.new()
	dir.open("user://")
	if not dir.dir_exists(snapshots_directory):
		dir.make_dir(snapshots_directory)
	

func set_pose(new_pose, pose_settings, model_key):
	if camera == null: return
	
	pose = new_pose
	
	if pose_settings == null:
		LOG.l("Snapshot: Settings unavailable for pose type: " + pose)
		return false
		
	camera.rotation_degrees = pose_settings.get("cam_rotation", DEFAULT_CAMERA_ROTATION)
	camera.translation = pose_settings.get("cam_offset", DEFAULT_CAMERA_OFFSET)
	if model_key == "energy_site":
		camera.translation += energy_site_type_location_offset
	camera.fov = pose_settings.get("cam_fov", default_fov)
	emit_signal("on_pose_settings_update", pose_settings, model_key)
	
	var scale = pose_settings.get("scale", 1.0)
	var x = pose_settings.get("viewport_width", screen_size.x) * scale
	var y = pose_settings.get("viewport_height", screen_size.y) * scale
	var frame_size = Vector2(x, y)
	viewport.set_size(frame_size)
	
	return true

func convert_override_data_to_pose(data):
	if not data:
		return data
	if data.has("cam_rotation"):
		data["cam_rotation"] = Utils.vec3_from_data(data["cam_rotation"], Vector3.ZERO)
	if data.has("cam_offset"):
		data["cam_offset"] = Utils.vec3_from_data(data["cam_offset"], Vector3.ZERO)
	if data.has("env_rotation"):
		data["env_rotation"] = Utils.vec3_from_data(data["env_rotation"], Vector3.ZERO)
	return data

func take_snapshot(data: Dictionary):
	var vehicle_dict_data = data.get("vehicle")
	var poses = data.get("poses")
	var config_hash = data.get("config_hash")
	var override_pose_data = data.get("override_pose_data")
	
	if vehicle_dict_data == null:
		LOG.l("Snapshot: vehicle data is null")
		return yield()

	if poses == null or poses.size() == 0:
		LOG.l("Snapshot: poses are null or empty")
		return yield()

	if config_hash == null:
		LOG.l("Snapshot: config_hash is null")
		return yield()
	
	var vehicle_data: VehicleData = VehicleData.new(vehicle_dict_data)
	var node_path: NodePath = product_manager.get_resource_path_for_product(vehicle_data)
	var model_key = product_manager.get_model_key_for_product(vehicle_data)
	if node_path == null:
		LOG.l("Snapshot: could not find node path for vehicle: " + vehicle_data.id)
		return yield()

	var node: Spatial = load(String(node_path)).instance()
	var vehicle: Vehicle = node as Vehicle
	if node == null or vehicle == null:
		LOG.l("Snapshot: could not insatiate vehicle with id" + vehicle_data.id)
		return yield()
	
	slot.add_child(vehicle)
	vehicle.translation = Vector3.ZERO
	vehicle.scale = product_manager.get_product_scale(vehicle_data)
	vehicle.update(vehicle_data)
	vehicle.set_default_state()
	camera.visible = true

	for pose in poses:
		var override_data = convert_override_data_to_pose(override_pose_data.get(pose)) if override_pose_data else null
		var pose_type = SnapshotPoses.get(pose)
		
		if pose_type == null:
			LOG.l("Snapshot: Invalid pose type %s" % pose)
			continue
		
		var pose_settings = SnapshotPoseSettings.get(pose_type).duplicate()
		if override_data:
			for key in override_data:
				pose_settings[key] = override_data[key]
		
		if not set_pose(pose_type, pose_settings, model_key):
			continue
		if pose_type == SnapshotPoseType.TOPDOWN_FADE_ROOF:
			vehicle.set_fade_roof(true, false)
		else:
			vehicle.set_fade_roof(false, false)
		vehicle.on_snapshot(pose_settings)

		
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		
		var snapshot: Image = viewport.get_texture().get_data()
		snapshot.convert(Image.FORMAT_RGBA8)
		snapshot.flip_y()
		
		var path = snapshots_directory + "/" + config_hash + "_" + pose + ".png"
		
		if snapshot.save_png("user://" + path) == OK:
			var message_data = {
				"config_hash": config_hash, 
				"pose": pose, 
				"path": path, 
			}
			mobile_comm.send_message(GodotMsg.NEW_VEHICLE_SNAPSHOT, message_data)
			LOG.l("Snapshot: Saved: " + path)
		else:
			LOG.l("Snapshot: Failed to save snapshot for vehicle: " + vehicle_data.id)
	
	vehicle.scale = Vector3.ONE
	camera.visible = false
	slot.remove_child(node)
	node.queue_free()
	
func take_energy_snapshot(data: Dictionary):
	var energy_dict_data = data.get("energy_site")
	var poses = data.get("poses")
	var config_hash = data.get("config_hash")
	
	if energy_dict_data == null:
		LOG.l("Snapshot: energy data is null")
		return yield()
	if poses == null or poses.size() == 0:
		LOG.l("Snapshot: poses are null or empty")
		return yield()
	if config_hash == null:
		LOG.l("Snapshot: config_hash is null")
		return yield()

	var energy_site_data: EnergySiteData = EnergySiteData.new(energy_dict_data)
	energy_site_data.energy_site_config.hide_all_labels = true

	var node_path: NodePath = product_manager.get_resource_path_for_product(energy_site_data)
	if node_path == null:
		LOG.l("Snapshot: could not find node path for energy site: " + energy_site_data.id)
		return yield()
	
	var node: Spatial = load(String(node_path)).instance()
	var energy_site: EnergySite = node as EnergySite
	if node == null or energy_site == null:
		LOG.l("Snapshot: could not instantiate energy site with id" + energy_site_data.id)
		return yield()
	
	slot.add_child(energy_site)
	energy_site.update(energy_site_data)
	if energy_site_data.has_vehicle_1():
		
		var garage_manager = energy_site.get_child(1).get_child(0).get_node("Vehicle").get_child(0)
		if garage_manager == null: return
		var garage_vehicle = garage_manager.get_node_or_null("Vehicle")
		if garage_vehicle == null: return
		garage_vehicle.updateFromEnergySite(energy_site_data)
		energy_site.update(energy_site_data)
	if energy_site_data.has_vehicle_2() and (energy_site_data.get_site_variant() == EnergySiteData.EnergySiteType.RESIDENTIAL_COMPOUND):
		
		var garage_manager = energy_site.get_child(1).get_child(0).get_node("Vehicle2").get_child(0)
		if garage_manager == null: return
		var garage_vehicle = garage_manager.get_node_or_null("Vehicle2")
		if garage_vehicle == null: return
		garage_vehicle.updateFromEnergySite(energy_site_data)
		energy_site.update(energy_site_data)
	
	get_camera_offset(energy_site_data.get_site_variant())
	var energy_camera = energy_site.get_node_or_null("Camera")
	if energy_camera != null:
		var energy_background = energy_camera.get_node_or_null("Background")
		if energy_background != null: energy_background.visible = false
	camera.current = true
	camera.visible = true
	
	var poseNumber = 0
	for pose in poses:
		var pose_type = SnapshotPoses.get(pose)
		print("POSE IS ", poses[poseNumber])
		
		if pose_type == null:
			print("pose is null")
			LOG.l("Snapshot: Invalid pose type %s" % pose)
			continue
		
		var pose_settings = SnapshotPoseSettings.get(pose_type)
		
		if not set_pose(pose_type, pose_settings, "energy_site"):
			continue
		
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		
		var snapshot: Image = viewport.get_texture().get_data()
		snapshot.convert(Image.FORMAT_RGBA8)
		snapshot.flip_y()
		
		var path = snapshots_directory + "/" + config_hash + "_" + pose + ".png"
		
		if snapshot.save_png("user://" + path) == OK:
			var message_data = {
				"config_hash": config_hash, 
				"pose": pose, 
				"path": path, 
			}
			mobile_comm.send_message(GodotMsg.NEW_ENERGY_SNAPSHOT, message_data)
			LOG.l("Snapshot: Saved: " + path)
		else:
			LOG.l("Snapshot: Failed to save snapshot for energy site: " + energy_site_data.id)
			
	camera.visible = false
	camera.clear_current()
	if energy_camera != null:
		var energy_background = energy_camera.get_node_or_null("Background")
		if energy_background != null: energy_background.visible = true
	slot.remove_child(node)
	if node != null:
		node.queue_free()
		
func get_camera_offset(site_type):
	if site_type == EnergySiteData.EnergySiteType.RESIDENTIAL_COMPOUND:
		energy_site_type_location_offset = Vector3( - 0.68, 0.35, 3.8)
	elif site_type == EnergySiteData.EnergySiteType.RESIDENTIAL_POWERSHARE:
		energy_site_type_location_offset = Vector3( - 0.15, - 1.6, - 3.9)
	else:
		energy_site_type_location_offset = Vector3(0.0, 0.0, 0.0)
