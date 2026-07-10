extends Resource
class_name ProductData

enum ProductType{
	INVALID = 0, 
	VEHICLE, 
	ENERGY, 
}


const ProductTypeValue = {
	"INVALID": ProductType.INVALID, 
	"VEHICLE": ProductType.VEHICLE, 
	"ENERGY_SITE": ProductType.ENERGY, 
}

var id: String
var type: int


func update(data: Dictionary):
	pass

static func id_from_data(_data: Dictionary):
	printerr("id_from_data must be overriten by subclass")

static func type_from_data(data: Dictionary) -> int:
	var typeValue = data.get("type", "INVALID")
	var productTypeValue = ProductTypeValue.get(typeValue, ProductType.INVALID)
	
	if (productTypeValue == ProductType.INVALID):
		printerr("invalid product type")
	
	return productTypeValue



static func getValue(data: Dictionary, key: String, default):
	var value = data.get(key)
	if value == null: return default
	
	if default is int:
		if value is int: return value
		if value is float: return int(value)
	elif default is float:
		if value is float: return value
		if value is int: return float(value)
	elif default is bool:
		if value is bool: return value
		if value is int or value is float or value is String: return bool(value)
	elif default is String:
		if value is String: return value
	elif default == null:
		return value
		
	printerr("Data Type Mismatch: Got", value, " Expected: ", default)

	return default
