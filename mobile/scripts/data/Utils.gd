class_name Utils


static func editor_enum_property(property_name: String, enum_dict: Dictionary) -> Dictionary:
	return {
		"name": property_name, 
		"type": TYPE_INT, 
		"hint": PROPERTY_HINT_ENUM, 
		"hint_string": PoolStringArray(enum_dict.keys()).join(","), 
		"usage": PROPERTY_USAGE_EDITOR
	}

static func vec3_from_data(data, default):
	if data == null or data is Array == false or data.size() != 3: return default
	return Vector3(float(data[0]), float(data[1]), float(data[2]))
	
static func vec2_to_data(vector: Vector2):
	return [vector.x, vector.y]

static func component_from_energy_type(energy_type: String):
	match energy_type:
		"LOAD":
			return 1
		"SOLAR":
			return 2
		"BATTERY":
			return 3
		"GRID":
			return 4
		"GENERATOR":
			return 5
		"WALL_CONNECTOR_1":
			return 6
		"WALL_CONNECTOR_2":
			return 9
		"VEHICLE_1":
			return 7
		"VEHICLE_2":
			return 10
		"METER":
			return 8
		_:
			return 0
