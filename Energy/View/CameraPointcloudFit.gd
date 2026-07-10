extends Camera




var point_dictionary = {}


var camera_position_dirty = false


export (NodePath)onready var site_root = get_node(site_root)
export (NodePath)onready var site_root_tween = get_node(site_root_tween)
var site_root_default_location
var site_root_default_rotation
var max_fov = 10
var zoomed_fov = 8




var current_global_position = Vector3()


var image_overlay_node: MeshInstance

onready var tween = get_node("Tween")
onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm")
signal fade_in_labels
onready var debug_view = false

func clip_rect(a: Rect2, b: Rect2) -> Rect2:
	var position = Vector2(max(a.position[0], b.position[0]), max(a.position[1], b.position[1]))
	var size = Vector2(min(a.end[0], b.end[0]), min(a.end[1], b.end[1])) - position
	return Rect2(position, size)



func origin_containing_points(points: Array, fov: float, aspect: float):
	var fov_scale = tan(fov / 2)
	var frustum_scale = Vector2(1.0 / (fov_scale * aspect), 1.0 / fov_scale)
	
	
	var closest_distance = - INF
	
	for i in range(len(points)):
		
		var a = points[i]
		
		
		for j in range(i + 1, len(points)):
			var b = points[j]
			
			
			var distance = max(abs(a.x - b.x) * frustum_scale.x, abs(a.y - b.y) * frustum_scale.y)
			distance += a.z + b.z
			distance /= 2
			
			closest_distance = max(closest_distance, distance)
			
	
	var camera_position = Vector3(0, 0, closest_distance)
	
	var rect = null
	
	
	for i in range(len(points)):
		var point = points[i]
		
		
		var size = closest_distance - point.z
		size = Vector2(size / frustum_scale.x, size / frustum_scale.y)
		var tl = Vector2(point.x, point.y) - size / 2
		
		if i == 0:
			rect = Rect2(tl, size)
		else:
			rect = clip_rect(rect, Rect2(tl, size))

	camera_position.x = rect.position.x + rect.size.x / 2
	camera_position.y = rect.position.y + rect.size.y / 2
	
	return camera_position

func add_pointcloud(pointcloud: EnergyPointcloudParent):
	point_dictionary[pointcloud.pointcloud_name] = pointcloud
	
	set_dirty()
	
func remove_pointcloud(pointcloud: EnergyPointcloudParent):
	if point_dictionary.has(pointcloud.pointcloud_name) and point_dictionary[pointcloud.pointcloud_name] == pointcloud:
		point_dictionary.erase(pointcloud.pointcloud_name)
	set_dirty()
	
func _ready():
	fov = max_fov
	make_current()
	set_dirty()
	mobile_comm.register_listener(ReactMsg.MOVE_CAMERA, funcref(self, "on_move_camera"))
	get_tree().get_root().connect("size_changed", self, "on_window_resize")
	image_overlay_node = get_node("ImageOverlay")
	site_root_default_location = site_root.transform.origin
	site_root_default_rotation = site_root.rotation
	
func on_move_camera(data: Dictionary):
	var new_fov = data.get("cam_fov")
	if new_fov == null or new_fov == fov or new_fov > max_fov:
		print("Requested FOV is identical to existing or out of range, ignoring request")
		return
	
	if new_fov != null:
		tween.stop_all()
		tween.interpolate_property(self, "fov", fov, new_fov, 0.7, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
		tween.start()
	
	var new_site_root_location: Vector3
	var new_site_root_rotation: Vector3
	
	if new_fov == zoomed_fov:
		new_site_root_location = Vector3( - 0.05, 0.4, 0.4)
		new_site_root_rotation = Vector3(0.0, - 0.9, 0.0)
	else:
		new_site_root_location = site_root_default_location
		new_site_root_rotation = site_root_default_rotation
	
	var stored_site_root_location = site_root.transform.origin
	if new_site_root_location == stored_site_root_location:
		return
	
	var stored_site_root_rotation = site_root.rotation
	site_root_tween.stop_all()
	site_root_tween.interpolate_property(site_root, "translation", stored_site_root_location, new_site_root_location, 0.7, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
	site_root_tween.interpolate_property(site_root, "rotation", stored_site_root_rotation, new_site_root_rotation, 0.7, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
	site_root_tween.start()
	

func update_camera_position(debug_view = false):
	if debug_view:
		var basis = global_transform.basis
		var fixed_distance = Vector3( - 0.35, - 0.2, 22.0)
		return basis.xform(fixed_distance)
	
	var basis = global_transform.basis
	
	var points = []
	for pc in point_dictionary:
		if not point_dictionary[pc].enabled: continue
		for point in point_dictionary[pc].get_children():
			if point.get_class() != "Spatial": continue
			points.append(basis.xform_inv(point.global_transform.origin))
	
	if points.size() <= 1: return

	var aspect = 1
	var container = find_parent("MainViewContainer")
	if container != null:
		aspect = container.container_size.x / container.container_size.y

	var camera_local_origin = origin_containing_points(points, deg2rad(fov), aspect)
	
	return basis.xform(camera_local_origin)

func set_dirty():
	camera_position_dirty = true
	
func update(animated = false):
	camera_position_dirty = false
	
	var new_global_position = update_camera_position(debug_view)
	if current_global_position == new_global_position:
		return
		
	
	
	
	if new_global_position == null:
		return
		
	current_global_position = new_global_position
	
	emit_signal("fade_in_labels")
	if not animated or tween == null:
		global_transform.origin = new_global_position
		return
		
	tween.interpolate_method(self, "update_global_origin", 
		global_transform.origin, new_global_position, 1, 
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

	
func update_global_origin(new_origin: Vector3):
	global_transform.origin = new_origin
	
func _process(delta):
	if camera_position_dirty:
		update()

func on_window_resize():
	update()

func load_image_overlay(image_path: String):
	if not image_overlay_node:
		return

	var image = Image.new()
	if image.load(image_path) == OK:
		var texture = ImageTexture.new()
		texture.create_from_image(image)

		
		var image_width = image.get_width()
		var image_height = image.get_height()
		if image_height == 0: return
		var image_aspect = float(image_width) / float(image_height)

		
		if image_overlay_node.mesh is QuadMesh:
			var quad_mesh = image_overlay_node.mesh as QuadMesh
			
			var overlay_width = 2.0
			var overlay_height = overlay_width / image_aspect
			quad_mesh.size = Vector2(overlay_width, overlay_height)

		var material = image_overlay_node.get_surface_material(0)
		if material:
			material.albedo_texture = texture
			image_overlay_node.visible = true
			print("Loaded overlay image: ", image_path, " (", image_width, "x", image_height, ", aspect: ", image_aspect, ")")
	else:
		print("Failed to load image: ", image_path)

func show_overlay():
	if image_overlay_node:
		print("showing overlay image")
		image_overlay_node.visible = true
		debug_view = true
		update()

func hide_overlay():
	if image_overlay_node:
		print("hiding overlay image")
		image_overlay_node.visible = false
		debug_view = false
		update()
