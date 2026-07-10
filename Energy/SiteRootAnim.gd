extends Spatial
onready var testing: Testing = get_node_or_null("/root/Mobile/Testing")

export (NodePath)onready var tween = get_node_or_null(tween)
export (NodePath)onready var camera = get_node_or_null(camera)
export (NodePath)onready var camera_tween = get_node_or_null(camera_tween)
onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm") as MobileComm
const ReactMsg = preload("res://mobile/scripts/ReactMsg.gd")

onready var default_translation: Vector3
onready var default_rotation: Vector3
onready var default_fov: float

onready var wrapped_animation_duration = 3.0

signal fade_out_labels
signal fade_in_labels

var powerwall2 = "res://Energy/Battery/Powerwall2/Powerwall2.tscn"
var solar_powerwall = "res://Energy/Battery/SPW/SPW.tscn"
var penguin = "res://Energy/Battery/Penguin/Penguin.tscn"
var solar_roof = "res://Energy/Load/Residential/Classic/SolarRoof.tscn"
var solar_roof_compound = "res://Energy/Load/Residential/Compound/SolarRoof.tscn"
var solar_panels = "res://Energy/Load/Residential/Classic/SolarPanel.tscn"
var solar_panels_compound = "res://Energy/Load/Residential/Compound/SolarPanels.tscn"
var residential_classic_energy_site_path: String = "res://Energy/Load/Residential/Classic/ResidentialClassic.tscn"
var residential_compound_energy_site_path: String = "res://Energy/Load/Residential/Compound/ResidentialCompound.tscn"
var residential_powershare_energy_site_path: String = "res://Energy/Load/Residential/Modern/ResidentialPowershare.tscn"

onready var camera_offset_x
onready var camera_offset_z
onready var wrapped_camera_fov
onready var fade_delay = 1.55




onready var classic_offset_x_battery = 0.52
onready var classic_offset_z_battery = - 1.15
onready var classic_offset_x_solar = - 0.9
onready var classic_offset_z_solar = 4.0
onready var classic_wc_offset_x_battery = 0.18
onready var classic_wc_offset_z_battery = - 1.1
onready var classic_wc_offset_x_solar = - 1.25
onready var classic_wc_offset_z_solar = 4.0
onready var compound_offset_x_battery = - 1.23
onready var compound_offset_z_battery = 3.25
onready var compound_offset_x_solar = - 1.9
onready var compound_offset_z_solar = 7
onready var wrapped_camera_fov_solar = 15.0
onready var wrapped_camera_fov_battery = 1.5

onready var isSolarAnimation = false

func _ready():
	default_translation = self.translation
	default_rotation = self.rotation
	default_fov = camera.fov
	if mobile_comm != null:
		mobile_comm.register_listener(ReactMsg.ENTER_TESLA_WRAPPED, funcref(self, "prep_site_for_anim"))
		mobile_comm.register_listener(ReactMsg.EXIT_TESLA_WRAPPED, funcref(self, "reset"))

	
func prep_site_for_anim(data: Dictionary):
	
	if data == null: return
	isSolarAnimation = data.get("pvi_only", false)
	
	match self.get_parent().get_energy_site_path():
		residential_compound_energy_site_path:
			if isSolarAnimation:
				camera_offset_x = compound_offset_x_solar
				camera_offset_z = compound_offset_z_solar
				wrapped_camera_fov = wrapped_camera_fov_solar - 5.2
			else:
				camera_offset_x = compound_offset_x_battery
				camera_offset_z = compound_offset_z_battery
				wrapped_camera_fov = wrapped_camera_fov_battery - 0.45
			
			if self.get_child(1).get_node_or_null("Meter") != null:
				self.get_child(1).get_node_or_null("Meter").visible = false
		residential_classic_energy_site_path:
			if self.get_child(1).get_node_or_null("PointcloudWallConnector").enabled:
				if isSolarAnimation:
					camera_offset_x = classic_wc_offset_x_solar
					camera_offset_z = classic_wc_offset_z_solar
					wrapped_camera_fov = wrapped_camera_fov_solar - 2.0
				else:
					camera_offset_x = classic_wc_offset_x_battery
					camera_offset_z = classic_wc_offset_z_battery
					wrapped_camera_fov = wrapped_camera_fov_battery - 0.25
			else:
				if isSolarAnimation:
					camera_offset_x = classic_offset_x_solar
					camera_offset_z = classic_offset_z_solar
					wrapped_camera_fov = wrapped_camera_fov_solar
				else:
					camera_offset_x = classic_offset_x_battery
					camera_offset_z = classic_offset_z_battery
					wrapped_camera_fov = wrapped_camera_fov_battery
		residential_powershare_energy_site_path:
			print("Wrapped animation not supported for GW3V sites.")
			return
		_:
			camera_offset_x = classic_offset_x_battery
			camera_offset_z = classic_offset_z_battery
	
	
	
	
	if self.get_child(1).get_node_or_null("WallConnector1Manager") != null:
		self.get_child(1).get_node_or_null("WallConnector1Manager").visible = false
	if self.get_child(1).get_node_or_null("WallConnector2Manager") != null:
		self.get_child(1).get_node_or_null("WallConnector2Manager").visible = false
	if self.get_child(1).get_node_or_null("Vehicle") != null:
		self.get_child(1).get_node_or_null("Vehicle").visible = false
	if self.get_child(1).get_node_or_null("Vehicle2") != null:
		self.get_child(1).get_node_or_null("Vehicle2").visible = false
	
	if isSolarAnimation and self.get_child(1).get_node_or_null("Battery") != null:
			self.get_child(1).get_node_or_null("Battery").visible = false

	
	tween.interpolate_property(self, "rotation:y", deg2rad( - 45), deg2rad( - 120), wrapped_animation_duration, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "translation:x", self.translation.x, self.translation.x + camera_offset_x, wrapped_animation_duration, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "translation:z", self.translation.z, self.translation.z + camera_offset_z, wrapped_animation_duration, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.start()
	camera_tween.interpolate_property(camera, "fov", camera.fov, wrapped_camera_fov, wrapped_animation_duration, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	camera_tween.start()
	
	fade_all_meshes(self.get_child(1), 1.0, 0, 0.15, false, fade_delay)
	
	emit_signal("fade_out_labels")
	
	
func fade_all_meshes(root_node: Node, fade_from: float, fade_to: float, fade_duration: float, on: bool, fade_delay: float) -> void :
	
	_fade_mesh_instances(root_node, fade_from, fade_to, fade_duration, on, fade_delay)

func _fade_mesh_instances(node: Node, fade_from: float, fade_to: float, fade_duration: float, on: bool, fade_delay: float) -> void :
	if node is MeshInstance:
		
		if node.name == "Shadow":
			if fade_to == 1:
				node.material_override.set_shader_param("alpha", 1)
			else:
				var tween = Tween.new()
				node.add_child(tween)
				tween.interpolate_property(node.material_override, "shader_param/alpha", fade_from, fade_to, fade_duration, Tween.TRANS_SINE, Tween.EASE_OUT, fade_delay)
				tween.start()
				tween.connect("tween_completed", tween, "_on_tween_completed")
		
		if fade_to == 1 and node.get_surface_material(0) != null:
			node.get_surface_material(0).set_shader_param("alpha", 1.0)
		else:
			var tween = Tween.new()
			node.add_child(tween)
			tween.interpolate_property(node.get_surface_material(0), "shader_param/alpha", fade_from, fade_to, fade_duration, Tween.TRANS_SINE, Tween.EASE_OUT, fade_delay)
			tween.start()
			tween.connect("tween_completed", tween, "_on_tween_completed")

	
	for child in node.get_children():
		if child is Node:
			if node.name == "Battery" and not isSolarAnimation:
				play_battery_animation(on)
				return
			elif node.name == "Solar" and isSolarAnimation:
				play_solar_animation(on)
				return
			_fade_mesh_instances(child, fade_from, fade_to, fade_duration, on, fade_delay)
				

func _on_tween_completed(tween) -> void :
	tween.queue_free()
	
func play_battery_animation(on: bool):
	if self.get_child(1).get_node_or_null("Battery") != null:
		var battery_parent_node = self.get_child(1).get_node_or_null("Battery")
		if battery_parent_node == null: return
		
		var battery_scene_node
		var battery_node
		
		var battery_type = battery_parent_node.get_resource_path()
		
		match battery_type:
			solar_powerwall:
				battery_node = battery_parent_node.get_node("SPW").get_node_or_null("SPW")
				battery_scene_node = battery_parent_node.get_node("SPW")
			penguin:
				battery_node = battery_parent_node.get_node("Penguin").get_node_or_null("Penguin")
				battery_scene_node = battery_parent_node.get_node("Penguin")
			powerwall2:
				battery_node = battery_parent_node.get_node("Powerwall2").get_node_or_null("Powerwall2")
				battery_scene_node = battery_parent_node.get_node("Powerwall2")
			_:
				print("BATTERY NODE NOT FOUND")
				return
				
		if battery_node == null: return
		var battery_node_material = battery_node.get_surface_material(0)
		var ego_glow = battery_scene_node.get_node("WrappedAnimation").get_node_or_null("EgoGlow")
		
		if not on:
			
			var ribbon = battery_scene_node.get_node("WrappedAnimation").get_node_or_null("GodotBatteryRibbon1")
			var ribbon_2 = battery_scene_node.get_node("WrappedAnimation").get_node_or_null("GodotBatteryRibbon2")
			
			if ribbon != null:
				var ribbon_material = ribbon.get_surface_material(0)
				var tween = Tween.new()
				ribbon.add_child(tween)
				tween.interpolate_property(ribbon_material, "shader_param/offset", - 0.75, 0.75, 2.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.1)
				tween.interpolate_property(ribbon_material, "shader_param/albedo", Color(0.0, 1.0, 0.6, 1.0), Color(0.45, 1.0, 0.71, 1.0), 2.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.1)
				tween.start()
				tween.connect("tween_completed", tween, "_on_tween_completed")
			if ribbon_2 != null:
				var ribbon_2_material = ribbon_2.get_surface_material(0)
				var tween = Tween.new()
				ribbon_2.add_child(tween)
				tween.interpolate_property(ribbon_2_material, "shader_param/offset", - 0.75, 0.75, 2.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.1)
				tween.interpolate_property(ribbon_2_material, "shader_param/albedo", Color(0.0, 1.0, 0.6, 1.0), Color(0.45, 1.0, 0.71, 1.0), 2.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.1)
				tween.start()
				tween.connect("tween_completed", tween, "_on_tween_completed")
			if ego_glow != null:
				var ego_glow_material = ego_glow.get_surface_material(0)
				var tween = Tween.new()
				ego_glow.add_child(tween)
				tween.interpolate_property(ego_glow_material, "shader_param/visibility", 0.0, 0.6, 0.6, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 1.45)
				tween.start()
				tween.connect("tween_completed", tween, "_on_tween_completed")
			
			
			var new_battery_material = battery_node_material.duplicate()
			battery_node.set_surface_material(0, new_battery_material)
			
			var tween = Tween.new()
			battery_node.add_child(tween)
			tween.interpolate_property(new_battery_material, "shader_param/LIGHT_DIRECTION", Vector3(1, 0, 0), Vector3( - 1, 0, 0), 1.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 1.0)
			tween.start()
			tween.connect("tween_completed", tween, "_on_tween_completed")

		else:
			battery_node.get_surface_material(0).set_shader_param("LIGHT_DIRECTION", Vector3(1, 0, 0))
			ego_glow.get_surface_material(0).set_shader_param("visibility", 0.0)
		
func play_solar_animation(on: bool):
	if self.get_child(1).get_node("Solar") != null:
		
		var solar_parent_node = self.get_child(1).get_node_or_null("Solar")
		if solar_parent_node == null: return
		var solar_scene_node
		var solar_type = solar_parent_node.get_resource_path()
		
		if solar_type == solar_panels or solar_type == solar_panels_compound:
			solar_scene_node = solar_parent_node.get_node_or_null("SolarPanel")
		elif solar_type == solar_roof or solar_roof_compound:
			solar_scene_node = solar_parent_node.get_node_or_null("SolarRoof")
		else:
			print("SOLAR NODE NOT FOUND")
			return
			
		if solar_scene_node == null: return
		
		
		var extra_solar_panel = solar_scene_node.get_node_or_null("SolarPanelsRight")
		var roof_seperator = solar_scene_node.get_node_or_null("RoofSeperator")
		var extra_solar_roof_panel = solar_scene_node.get_node_or_null("SolarRoof002")
		var extra_solar_roof_panel_2 = solar_scene_node.get_node_or_null("SolarRoof003")

			
		var ribbon = solar_scene_node.get_node("WrappedRibbonsSolar").get_node_or_null("GodotSolarWrappedCurve")
		var ribbon_2 = solar_scene_node.get_node("WrappedRibbonsSolar").get_node_or_null("GodotSolarWrappedCurve2")
			
		if not on:
			if extra_solar_panel != null:
				fade_specific_node(extra_solar_panel, 1.0, 0.0, wrapped_animation_duration - 1)
			if roof_seperator != null:
				fade_specific_node(roof_seperator, 1.0, 0.0, wrapped_animation_duration - 1)
			if extra_solar_roof_panel != null:
				fade_specific_node(extra_solar_roof_panel, 1.0, 0.0, wrapped_animation_duration - 1)
			if extra_solar_roof_panel_2 != null:
				fade_specific_node(extra_solar_roof_panel_2, 1.0, 0.0, wrapped_animation_duration - 1)
			if ribbon != null:
				var ribbon_material = ribbon.get_surface_material(0)
				var tween = Tween.new()
				ribbon.add_child(tween)
				tween.interpolate_property(ribbon_material, "shader_param/offset", 0.75, - 0.75, 2.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.3)
				tween.interpolate_property(ribbon_material, "shader_param/albedo", Color(1.0, 0.82, 0.0, 1.0), Color(1.0, 0.9, 0.47, 1.0), 2.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.3)
				tween.start()
				tween.connect("tween_completed", tween, "_on_tween_completed")
			if ribbon_2 != null:
				var ribbon_2_material = ribbon_2.get_surface_material(0)
				var tween = Tween.new()
				ribbon_2.add_child(tween)
				tween.interpolate_property(ribbon_2_material, "shader_param/offset", 0.75, - 0.75, 2.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.3)
				tween.interpolate_property(ribbon_2_material, "shader_param/albedo", Color(1.0, 0.82, 0.0, 1.0), Color(1.0, 0.9, 0.47, 1.0), 2.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.3)
				tween.start()
				tween.connect("tween_completed", tween, "_on_tween_completed")
		else:
			if extra_solar_panel != null:
				fade_specific_node(extra_solar_panel, 0.0, 1.0, 0.1)
			if roof_seperator != null:
				fade_specific_node(roof_seperator, 0.0, 1.0, 0.1)
			if extra_solar_roof_panel != null:
				fade_specific_node(extra_solar_roof_panel, 0.0, 1.0, 0.1)
			if extra_solar_roof_panel_2 != null:
				fade_specific_node(extra_solar_roof_panel_2, 0.0, 1.0, 0.1)
				
func fade_specific_node(node: Node, fade_from, fade_to, duration):
	var tween = Tween.new()
	node.add_child(tween)
	tween.interpolate_property(node.get_surface_material(0), "shader_param/alpha", fade_from, fade_to, duration, Tween.TRANS_SINE, Tween.EASE_OUT, 0)
	tween.start()
	tween.connect("tween_completed", tween, "_on_tween_completed")
	
func reset(data: Dictionary):
	if self.get_child(1).get_node_or_null("WallConnector1Manager") != null:
		self.get_child(1).get_node_or_null("WallConnector1Manager").visible = true
	if self.get_child(1).get_node_or_null("WallConnector2Manager") != null:
		self.get_child(1).get_node_or_null("WallConnector2Manager").visible = true
	if self.get_child(1).get_node_or_null("Vehicle") != null:
		self.get_child(1).get_node_or_null("Vehicle").visible = true
	if self.get_child(1).get_node_or_null("Vehicle2") != null:
		self.get_child(1).get_node_or_null("Vehicle2").visible = true
	if self.get_child(1).get_node_or_null("Meter") != null:
		self.get_child(1).get_node_or_null("Meter").visible = true
	if self.get_child(1).get_node_or_null("Battery") != null:
		self.get_child(1).get_node_or_null("Battery").visible = true
		
	self.translation = default_translation
	self.rotation = default_rotation
	camera.fov = default_fov
	emit_signal("fade_in_labels")
	
	
	fade_all_meshes(self.get_child(1), 0.0, 1.0, 0.01, true, 0)
