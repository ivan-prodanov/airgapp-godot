extends Spatial

onready var pool_manager = find_parent("Mobile").get_node("PoolManager")
onready var product_manager = find_parent("Mobile").get_node("ProductManager")

var energy_site: EnergySite

var generic_vehicle_resource_path = "res://Energy/Vehicle/GenericVehicle/GenericVehicle.tscn"
export (NodePath)onready var vehicle_garage_manager = get_node(vehicle_garage_manager)


var current_vehicle: Spatial

var wheels: Array = []

export var charge_port_open = false setget setChargePortOpen
export var direction = 0 setget setDirection

signal vehicle_charge_port_node_change(spatial)


func setChargePortOpen(new_charge_port_open):
	if charge_port_open == new_charge_port_open: return
	
	charge_port_open = new_charge_port_open
	if current_vehicle != null:
		current_vehicle.set_charge_port_open(charge_port_open, true)


func setDirection(new_direction):
	if direction == new_direction: return
	
	direction = new_direction
	
	if current_vehicle == null: return

	current_vehicle.set_reverse_lights_on(direction < 0)
	current_vehicle.set_brake_lights_on(direction > 0)

func getVehicleResourcePath(data: EnergySiteData):
	if data.get_vehicle_type() == EnergySiteData.VehicleType.TESLA:
		return product_manager.get_resource_path_for_product(data.get_vehicle_data())
		
	return generic_vehicle_resource_path
	

func updateFromEnergySite(data: EnergySiteData):
	
	if not data.has_wall_connector_1():
		deleteVehicle()
		return
		
	if not data.has_vehicle_1():
		return
		
	var vehicle_data = data.get_vehicle_data()
	
	if vehicle_data == null: return
	
	
	if (current_vehicle != null and vehicle_data.get("id") != current_vehicle.vehicle_id) or current_vehicle == null:
		instantiateVehicle(data)
		
	updateVehicle(data)

func instantiateVehicle(data: EnergySiteData):
	
	if current_vehicle != null:
		deleteVehicle()
		
	if data == null: return
	
	var vehicle_type = data.get_vehicle_type()
	var vehicle_data = data.get_vehicle_data()
	
	
	var vehicle_path = getVehicleResourcePath(data)
		
		
	if vehicle_path == null: return
	
	current_vehicle = pool_manager.get_node_instance(vehicle_path)
	
	if current_vehicle == null: return
		
	add_child(current_vehicle)
	
	if vehicle_type == EnergySiteData.VehicleType.TESLA:
		current_vehicle.scale = product_manager.get_product_scale(vehicle_data)
		wheels = [current_vehicle.lf_wheel, current_vehicle.lr_wheel, current_vehicle.rf_wheel, current_vehicle.rr_wheel]
	else:
		wheels = []
		
	current_vehicle.set_car_skin("", true)
	current_vehicle.set_paint_color_with_override(vehicle_data.vehicle_config.exterior_color, vehicle_data.vehicle_config.paint_color_override)
	current_vehicle.set_car_skin(vehicle_data.car_wrap_state.skin, true)

	emit_signal("vehicle_charge_port_node_change", current_vehicle.charge_port)
	
func updateVehicle(data: EnergySiteData):
	if data == null or current_vehicle == null: return
	
	var vehicle_data = data.get_vehicle_data()
		
	current_vehicle.visible = true
	current_vehicle.update(vehicle_data)

func deleteVehicle():
	if current_vehicle == null: return
	
	wheels = []
	
	emit_signal("vehicle_charge_port_node_change", null)

	remove_child(current_vehicle)
	pool_manager.release_node_instance(current_vehicle)
	
	current_vehicle = null

func _process(delta):
	
	var angle = transform.origin.z / 2.28 * 360 / scale.x
	
	for wheel in wheels:
		if wheel == null: continue
		if wheel is Spatial:
			wheel.rotation_degrees.z = fmod(angle, 360.0)
