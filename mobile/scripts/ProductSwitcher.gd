extends Spatial

signal on_show_product_node(product_node, product_data)

const ReactMsg = preload("res://mobile/scripts/ReactMsg.gd")

onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm")
onready var product_manager: ProductManager = get_node("/root/Mobile/ProductManager")
onready var pool_manager: PoolManager = get_node("/root/Mobile/PoolManager")
onready var slot: Spatial = get_node("Slot")

var product_node

func _on_ProductManager_on_show_product(product_data: ProductData):
	show_product(product_data)

func _on_ProductManager_on_update_product(product_data: ProductData):
	if product_node != null and product_data != null:
		product_node.update(product_data, true)

func show_product(product_data: ProductData):
	
	if product_node != null:
		if product_node.has_node("Road"):
			product_node.get_node("Road").queue_free()
		
		pool_manager.release_node_instance(product_node)
		slot.remove_child(product_node)

	
	
	if product_data == null: return
	var node_path: NodePath = product_manager.get_resource_path_for_product(product_data)
	if node_path == null: return
	var instance: Spatial = pool_manager.get_node_instance(node_path)
	if instance == null: return
	
	product_node = instance
	slot.scale = product_manager.get_product_scale(product_data)
	slot.add_child(instance)
	if instance is Vehicle:
		instance.set_is_mobile(true)
		instance.set_vehicle_data(product_data)
		instance.set_default_state()
		
		instance.set_car_skin("", true)
		instance.set_paint_color_with_override(product_data.vehicle_config.exterior_color, product_data.vehicle_config.paint_color_override)
		instance.set_car_skin(product_data.car_wrap_state.skin, true)

	if product_node != null:
		emit_signal("on_show_product_node", product_node, product_data)

	
	if instance is Vehicle or instance is EnergySite:
		instance.update(product_data)

