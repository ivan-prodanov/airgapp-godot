class_name ProductManager
extends Node

const GodotMsg = preload("res://mobile/scripts/GodotMsg.gd")
const ReactMsg = preload("res://mobile/scripts/ReactMsg.gd")
const VehicleData = preload("res://mobile/scripts/data/VehicleData.gd")
const EnergySiteData = preload("res://mobile/scripts/data/EnergySiteData.gd")
const ProductType = ProductData.ProductType

onready var mobile_comm: MobileComm = get_node("../MobileComm")
onready var LOG: LOG = get_node("../Log")

signal on_show_product(product_data)
signal on_update_product(product_data)

const vehicle_scale = {
	"model3": Vector3.ONE, 
	"models": Vector3.ONE * 0.945, 
	"models2": Vector3.ONE * 0.945, 
	"lychee": Vector3.ONE * 0.945, 
	"modelx": Vector3.ONE * 0.93, 
	"tamarind": Vector3.ONE * 0.93, 
	"modely": Vector3.ONE * 0.987, 
	"semitruck": Vector3.ONE * 0.627, 
	"cybertruck": Vector3.ONE * 0.875, 
	"cybercab": Vector3.ONE, 
	"unknown": Vector3.ONE * 0.987, 
}

const energy_site_node_path = NodePath("res://Energy/EnergySite.tscn")

var selected_product: ProductData

func _ready():
	mobile_comm.register_listener(ReactMsg.SHOW_PRODUCT, funcref(self, "on_show_product"))
	mobile_comm.register_listener(ReactMsg.UPDATE_PRODUCT, funcref(self, "on_update_product"))

func on_show_product(data: Dictionary):
	var product: ProductData = get_product(data)
	if product == null:
		print("not showing product because empty product")
		return
	if selected_product == null\
	or selected_product.id != product.id\
	or get_resource_path_for_product(selected_product) != get_resource_path_for_product(product):
		selected_product = product
		emit_signal("on_show_product", product)
	else:
		var selected_product_model_key = get_model_key_for_product(selected_product)
		var product_model_key = get_model_key_for_product(product)
		print("not showing new product, selected product model key: %s, product model key: %s" % [selected_product_model_key, product_model_key])

func on_update_product(data: Dictionary):
	var product: ProductData = get_product(data)
	if product == null: return
	if selected_product == null\
	or selected_product.id != product.id\
	or (ProductData.getValue(data, "vehicle_config", null) != null and get_resource_path_for_product(selected_product) != get_resource_path_for_product(product)):
		return
	selected_product.update(data)
	emit_signal("on_update_product", selected_product)

func get_product(data: Dictionary):
	var type = ProductData.type_from_data(data)
	if type == ProductType.VEHICLE:
		var id = VehicleData.id_from_data(data)
		if id == null: return null
		return VehicleData.new(data)
	elif type == ProductType.ENERGY:
		var id = EnergySiteData.id_from_data(data)
		if id == null: return null
		return EnergySiteData.new(data)

func get_resource_path_for_product(product_data: ProductData):
	var node_path: NodePath
	if product_data.type == ProductData.ProductType.VEHICLE:
		var model_key = get_model_key_for_product(product_data)
		var fascia_type = get_fascia_type_for_product(product_data)
		var chassis_type = get_chassis_type_for_product(product_data)
		node_path = get_vehicle_node_path(model_key, fascia_type, chassis_type, NodePath("res://Ego/Y_High/ModelY_High.tscn"))
	elif product_data.type == ProductData.ProductType.ENERGY:
		node_path = energy_site_node_path
	return node_path

func get_model_key_for_product(product_data: ProductData):
	var model_key
	if product_data.type == ProductData.ProductType.ENERGY:
		return model_key

	model_key = "modely"
	if product_data.vehicle_config != null:
		model_key = product_data.vehicle_config.car_type
	else:
		print("vehicle config is null, fallback to modely")
	return model_key

func get_fascia_type_for_product(product_data: ProductData):
	var vehicle_config = product_data.vehicle_config
	if vehicle_config == null:
		return "original"
	var fascia_type = vehicle_config.fascia_type
	if fascia_type == null:
		return "original"
	return fascia_type

func get_chassis_type_for_product(product_data: ProductData):
	var vehicle_config = product_data.vehicle_config
	if vehicle_config == null:
		return "model_y"
	var chassis_type = vehicle_config.chassis_type
	if chassis_type == null:
		return "model_y"
	return chassis_type

func get_product_scale(product_data: ProductData):
	if product_data is VehicleData == false: return Vector3.ONE
	return vehicle_scale.get(product_data.vehicle_config.car_type, Vector3.ONE)

func get_vehicle_node_path(model_key: String, fascia_type: String, chassis_type: String, default_node_path: NodePath):
	match model_key:
		"models", "models2":
			return NodePath("res://Ego/S/Model_S.tscn")
		"lychee":
			return NodePath("res://Ego/S_Palladium/S_Palladium.tscn")
		"model3":
			match fascia_type:
				"original":
					return NodePath("res://Ego/3_High/Model3_High.tscn")
				"basePoppyseed", "performancePoppyseed", "d50Poppyseed":
					return NodePath("res://Ego/v2023/Poppyseed/Poppyseed.tscn")
				_:
					return NodePath("res://Ego/3_High/Model3_High.tscn")
		"modelx":
			return NodePath("res://Ego/X/Model_X.tscn")
		"tamarind":
			return NodePath("res://Ego/X_Palladium/X_Palladium.tscn")
		"modely":
			match chassis_type:
				"model_y_long_wheel_base":
					return NodePath("res://Ego/BayberryE80/BayberryE80.tscn")
				_:
					match fascia_type:
						"e41Bayberry":
							return NodePath("res://Ego/BayberryE41/BayberryE41.tscn")
						"baseBayberry", "performanceBayberry":
							return NodePath("res://Ego/Bayberry/Bayberry.tscn")
						_:
							return NodePath("res://Ego/Y_High/ModelY_High.tscn")
		"semitruck":
			return NodePath("res://Ego/Semi/Semi.tscn")
		"cybertruck":
			return NodePath("res://Ego/Cybertruck/Cybertruck.tscn")
		"cybercab":
			return NodePath("res://Ego/Cybercab/Cybercab.tscn")
		_:
			return default_node_path
