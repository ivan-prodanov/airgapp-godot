tool 
extends Vehicle
class_name Semi




export (NodePath) var front_axle_path: NodePath
export (NodePath) var rear_front_axle_path: NodePath
export (NodePath) var rear_rear_axle_path: NodePath


onready var front_axle: Spatial = get_node_or_null(front_axle_path)
onready var rear_front_axle: Spatial = get_node_or_null(rear_front_axle_path)
onready var rear_rear_axle: Spatial = get_node_or_null(rear_rear_axle_path)

export (PackedScene) var rear_wheel: PackedScene

export (NodePath) var markers_path: NodePath
onready var markers: MeshInstance = get_node_or_null(markers_path)
export (bool) var markers_on setget set_markers_on


func get_roof_fade_resource_names():
	return [
		"Exterior_LongRange_Aero_Fade", 
		"Paint_LongRange_Aero_Fade", 
		"Exterior_LongRange_Fade", 
		"Paint_LongRange_Fade", 
		"Cloth_Grey_Fade", 
		"Plastic_Black_Fade", 
	]


func hide_wheels(hide: bool):
	print("hide_wheels ", hide)
	hide_wheels = hide

	
	for axle in get_all_axles():
		hide_spatial(axle, hide)

func get_rear_axles():
	return [rear_front_axle, rear_rear_axle]
	
func get_all_axles():
	return [front_axle] + get_rear_axles()

func get_wheel_sockets(axles: Array):
	var sockets = []
	for axle in axles:
		if axle == null: continue
		sockets += axle.get_children()
	return sockets


func get_main_wheel_sockets():
	
	return []
	

func get_wheel_rotation_objects():
	return get_all_axles()


func set_wheel_type(type):
	if wheel_type == type and loaded_wheels: return
	wheel_type = type

	
	var front_wheels_loaded = false
	var rear_wheels_loaded = false
	
	
	var front_wheel_sockets = get_wheel_sockets([front_axle])
	var rear_wheel_sockets = get_wheel_sockets(get_rear_axles())
	
	
	for socket in front_wheel_sockets + rear_wheel_sockets:
		if socket == null: continue
		for child in socket.get_children():
			socket.remove_child(child);
			child.queue_free()
	
	
	var front_wheel_path = VehicleOptions.WheelTypeToPathMap.get(type)
	if front_wheel_path == null:
		front_wheel_path = VehicleOptions.WheelTypeToPathMap.get(VehicleOptions.WheelType.SemiDefault)
	var front_wheel = load(String(front_wheel_path))
	if front_wheel != null:
		for socket in front_wheel_sockets:
			if socket == null: continue
			socket.add_child(front_wheel.instance())
			front_wheels_loaded = true
	
	
	for socket in rear_wheel_sockets:
		if socket == null: continue
		socket.add_child(rear_wheel.instance())
		rear_wheels_loaded = true
	
	
	loaded_wheels = front_wheels_loaded and rear_wheels_loaded


func _ready():
	connect("vehicle_lights_changed", self, "compute_markers_should_be_on")

func set_markers_on(on, should_emit_signal = true):
	markers_on = on
	
	if should_emit_signal:
		emit_signal("vehicle_lights_changed", self)
	
func compute_markers_should_be_on(vehicle: Vehicle):
	

	
	set_markers_on(vehicle.drl_on or vehicle.headlights_on, false)
