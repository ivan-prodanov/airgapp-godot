tool 
extends Spatial

enum CameraPosition{
	PARKED, CHARGING, DRIVE, DRIVE_REVERSE, TOP_DOWN, CLIMATE
}

enum VehicleType{
	MODEL_S, MODEL_P2S, MODEL_X, MODEL_P2X, MODEL_3, MODEL_Y, SEMITRUCK, CYBERTRUCK
}

const VehicleAssetPath = {
	VehicleType.MODEL_S: "res://Ego/S/Model_S.tscn", 
	VehicleType.MODEL_P2S: "res://Ego/S_Palladium/S_Palladium.tscn", 
	VehicleType.MODEL_X: "res://Ego/X/Model_X.tscn", 
	VehicleType.MODEL_P2X: "res://Ego/X_Palladium/X_Palladium.tscn", 
	VehicleType.MODEL_3: "res://Ego/3_High/Model3_High.tscn", 
	VehicleType.MODEL_Y: "res://Ego/Y_High/ModelY_High.tscn", 
	VehicleType.SEMITRUCK: "res://Ego/Semi/Semi.tscn", 
	VehicleType.CYBERTRUCK: "res://Ego/Cybertruck/Cybertruck.tscn", 
}

const CameraSettings = {
	CameraPosition.PARKED: {"rot": Vector3(68.6, - 138, 0), "offset": Vector3( - 0.06, 6.7, 0)}, 
	CameraPosition.CHARGING: {"rot": Vector3(74, - 38, 0), "offset": Vector3(0, 6.55, 0)}, 
	CameraPosition.DRIVE: {"rot": Vector3(68.6, - 138, 0), "offset": Vector3( - 0.06, 8, 0)}, 
	CameraPosition.DRIVE_REVERSE: {"rot": Vector3(74, - 38, 0), "offset": Vector3(0, 8, 0)}, 
	CameraPosition.TOP_DOWN: {"rot": Vector3(0, 0, 0), "offset": Vector3(0, 10, 0)}, 
	CameraPosition.CLIMATE: {"rot": Vector3(0, 0, 0), "offset": Vector3(0, 6, 0.6)}, 
}

const EnvironmentSettings = {
	CameraPosition.PARKED: {"rot": Vector3(0, - 7, 83), "env_energy": 4, "amb_energy": 4}, 
	CameraPosition.CHARGING: {"rot": Vector3(0, - 7, 83), "env_energy": 4, "amb_energy": 4}, 
	CameraPosition.DRIVE: {"rot": Vector3(0, - 7, 83), "env_energy": 4, "amb_energy": 4}, 
	CameraPosition.DRIVE_REVERSE: {"rot": Vector3(0, - 7, 83), "env_energy": 4, "amb_energy": 4}, 
	CameraPosition.TOP_DOWN: {"rot": Vector3( - 10, - 10, 0), "env_energy": 6, "amb_energy": 2.5}, 
	CameraPosition.CLIMATE: {"rot": Vector3(0, - 7, 83), "env_energy": 4, "amb_energy": 4}, 
}

export (VehicleType) var vehicle_type setget set_vehicle_type
export (CameraPosition) var camera_position setget set_camera_position

onready var slot: Spatial = $Slot
onready var cam_pivot: Spatial = $CameraPivot
onready var cam: Camera = $CameraPivot / Camera
onready var env: Environment = $WorldEnvironment.environment
onready var tween: Tween = $Tween

var car: Vehicle

export (bool) var isLoading = false setget set_loading
onready var ghostMaterial: ShaderMaterial = load("res://mobile/materials/loading.material")

func _ready():
	set_vehicle_type(VehicleType.MODEL_S)
	set_camera_position(CameraPosition.PARKED)
	
func set_loading(loading):
	isLoading = loading;
	var floorMat = car.get_node("Floor").get_surface_material(0)
	tween.stop_all()
	if loading:
		tween.interpolate_property(env, "background_energy", env.background_energy, 0.0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_property(floorMat, "albedo_color", floorMat.albedo_color, Color(1.0, 1.0, 1.0, 0.0), 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_callback(self, 0.3, "set_loading_material", car, ghostMaterial, loading)
		tween.interpolate_property(ghostMaterial, "shader_param/darkness", ghostMaterial.get_shader_param("darkness"), 1.0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3)
	else:
		tween.interpolate_property(ghostMaterial, "shader_param/darkness", ghostMaterial.get_shader_param("darkness"), 0.0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_callback(self, 0.3, "set_loading_material", car, ghostMaterial, loading)
		tween.interpolate_property(env, "background_energy", env.background_energy, EnvironmentSettings.get(camera_position).env_energy, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3)
		tween.interpolate_property(floorMat, "albedo_color", floorMat.albedo_color, Color(1.0, 1.0, 1.0, 1.0), 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3)
	tween.start()
	
func set_loading_material(node, material, loading):
	if (node):
		for child in node.get_children():
			set_loading_material(child, material, loading);
			
		if node is MeshInstance:
			if (node.name != "Floor"):
				if (loading):
					node.material_override = material;
				else:
					node.material_override = null;

func set_vehicle_type(type):
	vehicle_type = type
	for child in slot.get_children():
		slot.remove_child(child)
		child.queue_free()
	car = load(VehicleAssetPath.get(type)).instance();
	slot.add_child(car)
	car.set_wheel_type_by_name("Pinwheel");
	
func set_camera_position(pos):
	camera_position = pos
	
	var cam_settings = CameraSettings.get(pos)
	cam_pivot.rotation_degrees = cam_settings.rot
	cam.translation = cam_settings.offset

	var env_settings = EnvironmentSettings.get(pos)
	env.background_sky_rotation_degrees = env_settings.rot
	env.background_energy = env_settings.env_energy
	env.ambient_light_energy = env_settings.amb_energy
