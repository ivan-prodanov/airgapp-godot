
tool 
extends Spatial

export (String, DIR, GLOBAL) var export_directory = "/tmp/";
export (bool) var generate_skin_map setget execute_generate_skin_map
export (Material) var uv_map_paint_material
export (Material) var mask_material

enum EgoGenType{
	NV35, 
	NV35P, 
	MY, 
	NV36, 
	NV36P, 
	E80, 
	E41, 
	CT
}

export (EgoGenType) var car_to_setup
export (bool) var setup_selected_car setget set_setup_selected_car

enum MaterialType{
	SURFACE = 0, 
	OVERRIDE = 1
}
	
var original_materials_cache = {}

func prepare_setup():
	var ego_slot = $EgoSlot
	var ego = ego_slot.get_child(0)
	if ego:
		ego_slot.remove_child(ego)

func create_ego():
	var scene_path = ""
	match (car_to_setup):
		EgoGenType.NV35, EgoGenType.NV35P:
			scene_path = "res://Ego/v2023/Poppyseed/Poppyseed.tscn"
		EgoGenType.MY:
			scene_path = "res://Ego/Y_High/ModelY_High.tscn"
		EgoGenType.NV36, EgoGenType.NV36P:
			scene_path = "res://Ego/Bayberry/Bayberry.tscn"
		EgoGenType.E80:
			scene_path = "res://Ego/BayberryE80/BayberryE80.tscn"
		EgoGenType.E41:
			scene_path = "res://Ego/BayberryE41/BayberryE41.tscn"
		EgoGenType.CT:
			scene_path = "res://Ego/Cybertruck/Cybertruck.tscn"

	var ego_scene = load(scene_path).instance();
	var ego_slot = $EgoSlot
	ego_slot.add_child(ego_scene)
	ego_scene.set_owner(get_tree().get_edited_scene_root())

func setup_ego():
	var ego_slot = $EgoSlot
	var ego = ego_slot.get_child(0)
	if car_to_setup == EgoGenType.CT:
		ego.set_wheel_type(VehicleOptions.GTWWheelTypeEnumMap.CT_PREMIUM_20)
	else:
		ego.set_wheel_type(VehicleOptions.GTWWheelTypeEnumMap.GLIDER_18)
	ego.set_node_visible(ego.headlights_projection, false)
	ego.set_paint_color(VehicleOptions.ExteriorColor.SolidBlack)
	for marker in ego.marker_locators:
		marker.hide()
		
	match (car_to_setup):
		EgoGenType.NV35:
			ego.set_fascia_type(VehicleOptions.FasciaType.POPPYSEED_BASE)
		EgoGenType.NV35P:
			ego.set_fascia_type(VehicleOptions.FasciaType.POPPYSEED_PERF)
		EgoGenType.MY:
			ego.set_fascia_type(VehicleOptions.FasciaType.BASE)
		EgoGenType.NV36, EgoGenType.E80:
			ego.set_fascia_type(VehicleOptions.FasciaType.BAYBERRY)
		EgoGenType.NV36P:
			ego.set_fascia_type(VehicleOptions.FasciaType.BAYBERRY_PERF)
			ego.set_is_performance(true)
		EgoGenType.E41:
			ego.set_fascia_type(VehicleOptions.FasciaType.BAYBERRY_E41)
		EgoGenType.CT:
			ego.set_fascia_type(VehicleOptions.FasciaType.BASE)

func setup_camera():
	var desired_camera_node: Camera = null
	match (car_to_setup):
		EgoGenType.NV35, EgoGenType.NV35P:
			desired_camera_node = $Generator / M3_Camera
		EgoGenType.MY, EgoGenType.NV36, EgoGenType.NV36P, EgoGenType.E41:
			desired_camera_node = $Generator / MY_Camera
		EgoGenType.E80:
			desired_camera_node = $Generator / E80_Camera
		EgoGenType.CT:
			desired_camera_node = $Generator / CT_Camera
			
	desired_camera_node.set_current(true)

func set_setup_selected_car(set):
	setup_selected_car = false
	prepare_setup()
	create_ego()
	setup_ego()
	setup_camera()

func cache_original_materials(ego):
	original_materials_cache[MaterialType.SURFACE] = {}
	original_materials_cache[MaterialType.OVERRIDE] = {}
	cache_original_materials_recursive(ego)

func cache_original_materials_recursive(node):
	for child in node.get_children():
		cache_original_materials_recursive(child)
		
	if node is MeshInstance:
		var num_materials = node.mesh.get_surface_count()
		for index in range(num_materials):
			var mat: Material = node.mesh.surface_get_material(index)
			if not original_materials_cache[MaterialType.SURFACE].has(node): original_materials_cache[MaterialType.SURFACE][node] = {}
			original_materials_cache[MaterialType.SURFACE][node][index] = mat
		
		num_materials = node.get_surface_material_count()
		for index in range(num_materials):
			var mat: Material = node.get_surface_material(index)
			if not original_materials_cache[MaterialType.OVERRIDE].has(node): original_materials_cache[MaterialType.OVERRIDE][node] = {}
			original_materials_cache[MaterialType.OVERRIDE][node][index] = mat

func mask_all_non_paint_materials(node):
	for child in node.get_children():
		mask_all_non_paint_materials(child);
		
	if node is MeshInstance:
		var num_materials = node.get_surface_material_count()
		for index in range(num_materials):
			var mat: Material = node.get_surface_material(index)
			if mat == null: mat = node.mesh.surface_get_material(index)
			if mat == null: continue
			if mat.get_name() == "Paint" or mat.resource_name == "Paint" or mat.get_name() == "PaintSkybox" or mat.resource_name == "PaintSkybox"\
			or mat.get_name() == "Paint2" or mat.resource_name == "Paint2" or mat.get_name() == "PaintSkybox2" or mat.resource_name == "PaintSkybox2":
				continue
			
			node.set_surface_material(index, mask_material)

func restore_all_materials(node):
	for child in node.get_children():
		restore_all_materials(child);
		
	if node is MeshInstance:
		var num_materials = node.mesh.get_surface_count()
		for index in range(num_materials):
			node.mesh.surface_set_material(index, original_materials_cache[MaterialType.SURFACE][node][index])

		num_materials = node.get_surface_material_count()
		for index in range(num_materials):
			node.set_surface_material(index, original_materials_cache[MaterialType.OVERRIDE][node][index])

func clear_editor_selection():
	if Engine.editor_hint:
		var editor_interface = EditorScript.new().get_editor_interface()
		editor_interface.get_selection().clear()

func capture(name):
	var target_viewport = $Generator
	var img = target_viewport.get_texture().get_data()
	var file_name = "%s/%s" % [export_directory, name]
	img.flip_y()
	img.save_png(file_name)
	print("Captured " + file_name)

func execute_generate_skin_map(execute):
	if not execute: return
	generate_skin_map = false
	
	var ego_slot = $EgoSlot
	var ego = ego_slot.get_child(0)
	cache_original_materials(ego)
	clear_editor_selection()
	
	var target_viewport = $Generator
	target_viewport.msaa = Viewport.MSAA_16X
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	capture("background.png")
	
	ego.apply_material(ego, uv_map_paint_material, "PaintSkybox");
	ego.apply_material(ego, uv_map_paint_material, "Paint");
	ego.apply_material(ego, uv_map_paint_material, "PaintSkybox2");
	ego.apply_material(ego, uv_map_paint_material, "Paint2");
	ego.apply_material(ego, uv_map_paint_material, "PaintMix");
	mask_all_non_paint_materials(ego)
	ego.ground_shadow.hide()

	var skin_map_size_mult = 1
	target_viewport.size *= skin_map_size_mult
	target_viewport.msaa = Viewport.MSAA_DISABLED
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	capture("skin_map.png")
	target_viewport.size /= skin_map_size_mult
	
	restore_all_materials(ego)
	ego.ground_shadow.show()
