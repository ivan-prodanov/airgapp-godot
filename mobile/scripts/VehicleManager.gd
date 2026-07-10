extends Node

const ReactMsg = preload("res://mobile/scripts/ReactMsg.gd")
const GodotMsg = preload("res://mobile/scripts/GodotMsg.gd")

onready var LOG: LOG = get_node("/root/Mobile/Log")
onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm")
onready var product_manager: ProductManager = get_node("/root/Mobile/ProductManager")
onready var tween: Tween = get_node("Tween")
onready var camera: Camera = get_node("/root/Mobile/MainViewContainer/Viewport/CameraManager/CameraPivot/Camera")
onready var container: ViewportContainer = get_node("/root/Mobile/MainViewContainer")

const road_node: NodePath = NodePath("res://mobile/nodes/road.tscn")
const terrain_node: NodePath = NodePath("res://Ego/Cybertruck/Terrain/Terrain.tscn")

const Terrain = preload("res://Ego/Cybertruck/Terrain/Terrain.gd")

var selected_vehicle: Vehicle
var selected_vehicle_id
var wheels: Array
var local_fade_original_alpha: Dictionary = {}
var local_window_animation_state_by_vehicle: Dictionary = {}

signal on_vehicle_update(vehicle, vehicle_data)

func _ready():
	mobile_comm.register_listener(ReactMsg.FLASH_HEADLIGHTS, funcref(self, "on_flash_headlights"))
	mobile_comm.register_listener(ReactMsg.FADE_ROOF, funcref(self, "on_fade_roof"))
	mobile_comm.register_listener(ReactMsg.FORCE_CLOSE_ALL_CLOSURES, funcref(self, "on_force_close_all_closures"))
	mobile_comm.register_listener(ReactMsg.SHOW_FX_ABOVE, funcref(self, "on_show_fx_above"))
	mobile_comm.register_listener(ReactMsg.GET_VEHICLE_MARKERS, funcref(self, "on_get_vehicle_markers"))
	mobile_comm.register_listener(ReactMsg.SET_VEHICLE_LIGHTS, funcref(self, "on_set_vehicle_lights"))


func on_flash_headlights(data: Dictionary):
	var vehicle: Vehicle = vehicle_for_data(data)
	if vehicle == null or vehicle.is_driving: return
	var flash_count: int = data.get("flash_count", 1)
	var flash_duration: float = data.get("flash_duration", 1.5)
	var flash_interval: float = data.get("flash_interval", 1)
	
	for i in range(flash_count):
		vehicle.set_headlights_on(true)
		yield(get_tree().create_timer(flash_duration), "timeout")
		vehicle.set_headlights_on(false)
		yield(get_tree().create_timer(flash_interval), "timeout")

func on_fade_roof(data: Dictionary):
	var vehicle: Vehicle = vehicle_for_data(data)
	if vehicle == null: return
	var fade: bool = data.get("fade", true)
	var animated: bool = data.get("animated", true)
	var duration: float = data.get("duration", 0.75)
	vehicle.set_fade_roof(fade, animated, duration)
	_apply_local_roof_transparency(vehicle, fade)
	if fade:
		call_deferred("_apply_local_roof_transparency", vehicle, true)

func _apply_local_roof_transparency(vehicle: Vehicle, transparent: bool):
	if vehicle == null:
		return

	_set_named_fade_nodes_visible(vehicle, not transparent)

	var roof_fade_materials = vehicle.get("roof_fade_materials")
	if roof_fade_materials is Array:
		for mat in roof_fade_materials:
			_set_local_fade_material_alpha(mat, transparent)

func _set_named_fade_nodes_visible(node: Node, visible: bool):
	if node.name == "Fade":
		if node.has_method("set_visible"):
			node.set_visible(visible)
	for child in node.get_children():
		_set_named_fade_nodes_visible(child, visible)

func _set_local_fade_material_alpha(mat, transparent: bool):
	if mat == null:
		return

	if not local_fade_original_alpha.has(mat):
		if mat is SpatialMaterial:
			local_fade_original_alpha[mat] = mat.albedo_color.a
		elif mat is ShaderMaterial:
			var original_color = mat.get_shader_param("color")
			if original_color is Color:
				local_fade_original_alpha[mat] = original_color.a

	var alpha = 0.0 if transparent else local_fade_original_alpha.get(mat, 1.0)
	if mat is SpatialMaterial:
		mat.flags_transparent = true
		mat.params_depth_draw_mode = SpatialMaterial.DEPTH_DRAW_ALPHA_OPAQUE_PREPASS
		mat.albedo_color.a = alpha
	elif mat is ShaderMaterial:
		var color = mat.get_shader_param("color")
		if color is Color:
			color.a = alpha
			mat.set_shader_param("color", color)

func on_force_close_all_closures(data: Dictionary):
	var vehicle: Vehicle = vehicle_for_data(data)
	if vehicle == null: return
	var force_close: bool = data.get("force_close", false)
	var animated = data.get("animated", true)
	var speed = data.get("speed", 2.0)
	vehicle.set_force_doors_closed(force_close, animated, speed)
	
func on_show_fx_above(data: Dictionary):
	var vehicle: Vehicle = vehicle_for_data(data)
	if vehicle == null: return
	var show_above: bool = data.get("show", false)
	vehicle.show_fx_above = show_above

func on_get_vehicle_markers(data: Dictionary):
	var vehicle: Vehicle = vehicle_for_data(data)
	if vehicle == null:
		mobile_comm.send_message(GodotMsg.VEHICLE_MARKERS_RESPONSE, {})
		return

	var markers: Dictionary = {}
	get_markers(vehicle, markers)

	if markers.has("frunk"):
		yield(VisualServer, "frame_post_draw")
		var viewport: Viewport = container.get_node("Viewport")
		var image: Image = viewport.get_texture().get_data()
		image.flip_y()
		var frunk_pos = markers["frunk"]
		var viewport_pos = Vector2(frunk_pos[0], frunk_pos[1]) - container.rect_position
		markers["frunk_color"] = sample_color_around(image, viewport_pos, 20)

	mobile_comm.send_message(GodotMsg.VEHICLE_MARKERS_RESPONSE, markers)
	
func get_markers(node: Spatial, markers: Dictionary):
	if node == null: return
	for spatial in node.get_children():
		get_markers(spatial, markers)
		if spatial is Marker:
			if spatial.is_visible_in_tree():
				if spatial.marker_name != null:
					var screen_pos = camera.unproject_position(spatial.global_transform.origin)
					screen_pos += container.rect_position
					markers[spatial.marker_name] = Utils.vec2_to_data(screen_pos)
	
func sample_color_around(image: Image, center: Vector2, radius: int) -> Array:
	var total_r: = 0.0
	var total_g: = 0.0
	var total_b: = 0.0
	var count: = 0
	var x_min: = int(max(center.x - radius, 0))
	var x_max: = int(min(center.x + radius, image.get_width() - 1))
	var y_min: = int(max(center.y - radius, 0))
	var y_max: = int(min(center.y + radius, image.get_height() - 1))
	image.lock()
	for y in range(y_min, y_max + 1):
		for x in range(x_min, x_max + 1):
			var pixel = image.get_pixel(x, y)
			total_r += pixel.r
			total_g += pixel.g
			total_b += pixel.b
			count += 1
	image.unlock()
	if count == 0:
		return [0, 0, 0]
	var avg_color: = Color(total_r / count, total_g / count, total_b / count)
	return [avg_color.h * 360.0, avg_color.s, avg_color.v]

func _on_ProductSwitcher_on_show_product_node(product_node, product_data):
	var vehicle = product_node as Vehicle
	if vehicle == null:
		
		if selected_vehicle != null:
			
			show_terrain(false, selected_vehicle)
			show_road(false, selected_vehicle, 0.0)
			if selected_vehicle.is_connected("on_vehicle_update", self, "on_vehicle_update"):
				selected_vehicle.disconnect("on_vehicle_update", self, "on_vehicle_update")
		selected_vehicle = null
		selected_vehicle_id = null
		wheels = []
		return
	var vehicle_data = product_data as VehicleData
	
	if selected_vehicle_id == vehicle.vehicle_id:
		
		if vehicle.has_node("Terrain") != vehicle_data.showTerrain():
			show_terrain(vehicle_data.showTerrain(), vehicle)
		else: return

	if selected_vehicle != null:
		if selected_vehicle != vehicle:
			show_road(false, selected_vehicle, 0.3)
			show_terrain(false, selected_vehicle)
		if selected_vehicle.is_connected("on_vehicle_update", self, "on_vehicle_update"):
			selected_vehicle.disconnect("on_vehicle_update", self, "on_vehicle_update")
		
	selected_vehicle = vehicle
	selected_vehicle_id = vehicle.vehicle_id
	wheels = vehicle.get_wheel_rotation_objects()
	selected_vehicle.connect("on_vehicle_update", self, "on_vehicle_update")

func on_vehicle_update(vehicle: Vehicle, vehicle_data: VehicleData):
	if vehicle != selected_vehicle: return
	
	show_terrain(vehicle_data.showTerrain(), vehicle)
	if vehicle_data.vehicle_to_home_ready():
		show_road(false, vehicle, 0.3)
		show_terrain(false, vehicle)
		
	if vehicle_data.isDriving():
		show_road(true, vehicle, 0.3)
	
		var speed = vehicle_data.drive_state.speed
		if vehicle_data.inReverse():
			speed *= - 1

		var road: Road = selected_vehicle.get_node("Road") as Road
		road.set_speed(speed)
		vehicle.set_reverse_lights_on(vehicle_data.inReverse())
		vehicle.set_brake_lights_on(speed == 0)
	else:
		show_road(false, vehicle, 0.3)
		vehicle.set_reverse_lights_on(false)
		vehicle.set_brake_lights_on(false)

	_apply_window_states_from_data(vehicle, vehicle_data)
	emit_signal("on_vehicle_update", vehicle, vehicle_data)
		
func _apply_window_states_from_data(vehicle: Vehicle, vehicle_data: VehicleData):
	var states = vehicle_data.mobile_app_state.window_animation_state
	if states == null or states.empty():
		return

	for animation_name in states.keys():
		_apply_window_animation_state(vehicle, String(animation_name), bool(states[animation_name]))

func _apply_window_animation_state(vehicle: Vehicle, animation_name: String, open: bool):
	if vehicle == null:
		return
	var vehicle_key = str(vehicle.get_instance_id())
	if not local_window_animation_state_by_vehicle.has(vehicle_key):
		local_window_animation_state_by_vehicle[vehicle_key] = {}
	var last_states = local_window_animation_state_by_vehicle[vehicle_key]
	if last_states.has(animation_name):
		if bool(last_states[animation_name]) == open:
			return
	elif not open:
		last_states[animation_name] = false
		return

	var animation_player = vehicle.get_node_or_null(animation_name)
	if animation_player == null:
		return
	last_states[animation_name] = open
	_play_window_animation(animation_player, open, true, 1.0)

func _play_window_animation(animation_player: AnimationPlayer, open: bool, animated: bool, speed: float):
	var animation_list = animation_player.get_animation_list()
	if animation_list.empty():
		return
	var animation = animation_list[0]
	if open:
		animation_player.play(animation, -1, speed)
		if not animated:
			animation_player.seek(animation_player.current_animation_length, true)
	else:
		animation_player.play(animation, -1, -speed, true)
		if not animated:
			animation_player.seek(0, true)


func show_road(show: bool, vehicle: Vehicle, animation_duration: float):
	if vehicle == null:
		LOG.l("Can't show road. Vehicle is null")
		return

	var has_road = vehicle.has_node("Road")
	var road: Road
	if has_road:
		road = vehicle.get_node("Road")
		
	if show:
		if not has_road:
			LOG.l("Adding road to vehicle")
			road = load(String(road_node)).instance() as Road
			road.rotation_degrees.y = 180 - vehicle.rotation_degrees.y
			vehicle.add_child(road)
			road.name = "Road"
	else:
		if not has_road: return
	
	road.show(show, animation_duration)

func show_terrain(show: bool, vehicle: Vehicle):
	if vehicle == null:
		LOG.l("Can't show terrain. Vehicle is null")
	
	var has_terrain = vehicle.has_node("Terrain")
	var terrain: Terrain
	if has_terrain:
		terrain = vehicle.get_node("Terrain")

	if show:
		if not has_terrain:
			LOG.l("Adding terrain to vehicle")
			terrain = load(String(terrain_node)).instance() as Terrain
			if terrain == null:
				LOG.l("Terrain is nil")
				return
			vehicle.add_child(terrain)
			terrain.translation.x = - 1.488
			terrain.rotation_degrees.y = - 90
			terrain.scale.y = 1.5
			terrain.set_use_mobile_material(true)
			terrain.name = "Terrain"
		terrain.fade_terrain_material(false, tween)
	else:
		if not has_terrain:
			return
		terrain.fade_terrain_material(true, tween)
		vehicle.remove_child(terrain)

	
func vehicle_for_data(data: Dictionary):
	var vehicle: Vehicle = selected_vehicle as Vehicle
	var vehicle_id = data.get("vehicle_id")
	if vehicle_id == null or vehicle == null or vehicle_id != vehicle.vehicle_id: return null
	return vehicle

func _process(delta):
	if selected_vehicle == null or selected_vehicle.vehicle_data == null or wheels == null: return
	var vehicle: VehicleData = selected_vehicle.vehicle_data
	
	var speed = min(vehicle.drive_state.speed / 60.0, 1.0) * 1000.0
	if not vehicle.isDriving():
		speed = 0
	elif vehicle.inReverse():
		speed *= - 1
	
	for wheel in wheels:
		if wheel == null: return
		if wheel is Spatial:
			var direction = 1 if abs(wheel.rotation_degrees.y) != 0 else - 1
			wheel.rotation_degrees.z = fmod(wheel.rotation_degrees.z + direction * speed * delta, 360.0)


func on_set_vehicle_lights(data: Dictionary):
	# Persistent manual headlights / brake-lights toggle from RN (Explore demo panel). Mirrors the
	# dev harness manual override; there is no product-state path for these, hence a dedicated msg.
	var vehicle: Vehicle = vehicle_for_data(data)
	if vehicle == null:
		return
	if data.has("headlights") and vehicle.has_method("set_headlights_on"):
		vehicle.set_headlights_on(data.get("headlights"))
	if data.has("brake_lights") and vehicle.has_method("set_brake_lights_on"):
		vehicle.set_brake_lights_on(data.get("brake_lights"))
