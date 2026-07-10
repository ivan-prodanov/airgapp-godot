tool 
class_name Model_S
extends Vehicle

enum Version{
	S1, 
	S2
}

export (Version) var version setget set_version

export (Vehicle.ExteriorTrim) var exterior_trim setget set_exterior_trim


export (NodePath) var bodyS2_path: NodePath
export (NodePath) var bumperS1_path: NodePath
export (NodePath) var bumperS2_path: NodePath
export (NodePath) var hoodS2_path: NodePath
export (NodePath) var lightsS1_path: NodePath
export (NodePath) var lightsS2_path: NodePath
export (NodePath) var lights_glassS1_path: NodePath
export (NodePath) var lights_glassS2_path: NodePath


onready var bodyS2: MeshInstance = get_node_or_null(bodyS2_path)
onready var bumperS1: MeshInstance = get_node_or_null(bumperS1_path)
onready var bumperS2: MeshInstance = get_node_or_null(bumperS2_path)
onready var hoodS2: MeshInstance = get_node_or_null(hoodS2_path)
onready var lightsS1: MeshInstance = get_node_or_null(lightsS1_path)
onready var lightsS2: MeshInstance = get_node_or_null(lightsS2_path)
onready var lights_glassS1: MeshInstance = get_node_or_null(lights_glassS1_path)
onready var lights_glassS2: MeshInstance = get_node_or_null(lights_glassS2_path)

onready var executive_interior_lhd: MeshInstance = get_node_or_null("Interior_Executive")
onready var executive_interior_rhd: MeshInstance = get_node_or_null("Interior_Executive_RHD")

var skybox_paint_original: ShaderMaterial
var paint_rough_original: SpatialMaterial

func get_roof_fade_resource_names():
	return ["PaintFade", 
			"ExteriorFade", 
			"InteriorFade", 
			"Glass_Fade", 
			"Glass_Tinted_Fade", 
			"Glass_Interior_Fade", 
			"GlassFadeSkybox", 
			"GlassTintedFadeSkybox", 
			"Glass_Interior_Tinted_Fade"]

func set_version(v: int):
	version = v
	set_node_visible(body, v == Version.S1)
	set_node_visible(bodyS2, v == Version.S2)
	set_node_visible(bumperS1, v == Version.S1)
	set_node_visible(bumperS2, v == Version.S2)
	set_node_visible(hood, v == Version.S1)
	set_node_visible(hoodS2, v == Version.S2)
	set_node_visible(lightsS1, v == Version.S1)
	set_node_visible(lightsS2, v == Version.S2)
	set_node_visible(lights_glassS1, v == Version.S1)
	set_node_visible(lights_glassS2, v == Version.S2)
	
	if v == Version.S1:
		drl_path = NodePath("DRL_Original")
		headlights_path = NodePath("Headlights_Original")
		turn_signal_l_path = NodePath("Left_Turn_Signal_Original")
		turn_signal_r_path = NodePath("Right_Turn_Signal_Original")
	else:
		drl_path = NodePath("DRL")
		headlights_path = NodePath("Headlights")
		turn_signal_l_path = NodePath("Left_Turn_Signal")
		turn_signal_r_path = NodePath("Right_Turn_Signal")

func apply_skybox_materials():
	.apply_skybox_materials()
	
	var paint_original_path = "res://" + local_dir + "/PaintSkybox_Original.material"
	var paint_rough_original_path = "res://" + local_dir + "/Paint_Rough_Original.material"
	
	var file = File.new()
	if file.file_exists(paint_original_path):
		skybox_paint_original = load(paint_original_path)
	
	if file.file_exists(paint_rough_original_path):
		paint_rough_original = load(paint_rough_original_path)

	if not in_editor():
		if skybox_paint_original != null:
			skybox_paint_original = skybox_paint_original.duplicate()
		if paint_rough_original != null:
			paint_rough_original = paint_rough_original.duplicate()

	if skybox_paint_original != null:
		apply_material(self, skybox_paint_original, "PaintSkybox_Original");
	if paint_rough_original != null:
		apply_material(self, paint_rough_original, "PaintRough_Original");

func get_skybox_materials():
	var mats = .get_skybox_materials()
	mats.append(skybox_paint_original)
	return mats

func set_exterior_trim(trim: int):
	if trim == exterior_trim: return
	exterior_trim = trim
	print("set_exterior_trim: " + String(trim))

	var material: SpatialMaterial
	if version == Version.S1:
		match (trim):
			ExteriorTrim.Original:
				material = load("res://" + local_dir + "/Exterior_Original.material")
			ExteriorTrim.Black:
				material = load("res://" + local_dir + "/Exterior_Original_Black_Trim_Colorizer.material")
	elif version == Version.S2:
		match (trim):
			ExteriorTrim.Original:
				material = load("res://" + local_dir + "/Exterior.material")
			ExteriorTrim.Black:
				material = load("res://" + local_dir + "/Exterior_Black_Trim_Colorizer.material")
	if material == null: return

	material = material.duplicate()
	apply_material(self, material, "Exterior")

func set_exterior_trim_str(trim: String):
	if trim.empty(): return
	var value = ExteriorTrimMap.get(trim, ExteriorTrim.Original)
	set_exterior_trim(value)

func update(data: VehicleData, animated: bool = false, speed: float = 1.0):
	.update(data, animated, speed)
	var v = Version.S2
	if data.vehicle_config.car_type == "models":
		v = Version.S1
	set_version(v)
	set_rear_seat_type(data.vehicle_config.rear_seat_type, data.vehicle_config.rhd)
	set_exterior_trim_str(data.vehicle_config.exterior_trim_override)

func set_paint_color_by_name(color_key: String):
	print("Model_S.gd set_paint_color_by_name ", color_key, " previous value ", paint_color_name)
	if paint_color_name == color_key: return
	var material: Dictionary = VehicleOptions.ExteriorColorValue.get(color_key, VehicleOptions.FALLBACK_EXTERIOR_COLOR)
	if not material:
		printerr("Invalid vehicle color")
		return ;
	set_paint_color_by_dict(material, true)

func set_paint_color_by_dict(material: Dictionary, includeAlpha: bool):
	print("Model_S.gd set_paint_color_by_dict includeAlpha ", includeAlpha)
	if not material:
		printerr("Invalid vehicle color")
		return ;
	.set_paint_color_by_dict(material, true)

	if skybox_paint_original:
		if includeAlpha:
			skybox_paint_original.set_shader_param("color", material.color)
		else:
			var color = skybox_paint_original.get_shader_param("color")
			color.r = material.color.r
			color.g = material.color.g
			color.b = material.color.b
			skybox_paint_original.set_shader_param("color", color)
		skybox_paint_original.set_shader_param("metallic", material.metallic)
		skybox_paint_original.set_shader_param("roughness", material.roughness)
	if paint_rough_original:
		if includeAlpha:
			paint_rough_original.albedo_color = material.color
		else:
			paint_rough_original.albedo_color.r = material.color.r
			paint_rough_original.albedo_color.g = material.color.g
			paint_rough_original.albedo_color.b = material.color.b
		paint_rough_original.metallic = material.metallic
		paint_rough_original.roughness = 1.0

func set_rear_seat_type(type: int, rhd: bool):
	interior_rhd.visible = rhd and type != VehicleData.RearSeatType.EXECUTIVE
	interior_lhd.visible = not rhd and type != VehicleData.RearSeatType.EXECUTIVE
	executive_interior_rhd.visible = rhd and type == VehicleData.RearSeatType.EXECUTIVE
	executive_interior_lhd.visible = not rhd and type == VehicleData.RearSeatType.EXECUTIVE
