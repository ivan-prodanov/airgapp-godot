extends ProductData

class_name EnergySiteData

enum Component{
	INVALID = 0, 
	LOAD = 1, 
	SOLAR = 2, 
	BATTERY = 3, 
	GRID = 4, 
	GENERATOR = 5, 
	WALL_CONNECTOR_1 = 6
	WALL_CONNECTOR_2 = 9, 
	VEHICLE_1 = 7, 
	VEHICLE_2 = 10, 
	METER = 8, 
}

enum EnergySiteType{
	RESIDENTIAL_CLASSIC = 0, 
	RESIDENTIAL_COMPOUND = 1, 
	INDUSTRIAL = 2, 
	RESIDENTIAL_POWERSHARE = 3, 
}

enum SolarType{
	SOLAR_ROOF = 0, 
	SOLAR_PANEL = 1, 
}

enum BatteryType{
	DC_POWERWALL = 0, 
	AC_POWERWALL = 1, 
	SOLAR_POWERWALL = 2, 
	POWERPACK = 3, 
	MEGAPACK = 4, 
	PENGUIN = 5, 
}

enum VehicleType{
	TESLA = 0, 
	GENERIC = 1, 
}

class PowerflowWire extends Resource:
	var is_flowing: bool

	var source
	var destination

	var wire_color: String

	func _init(data: Dictionary = {}):
		is_flowing = data.get("isFlowing", false)
		source = Utils.component_from_energy_type(data.get("source", "INVALID"))
		destination = Utils.component_from_energy_type(data.get("destination", "INVALID"))
		wire_color = data.get("wireColor", "")
		
class EnergySiteConfig extends Resource:
	var variant: String
	var components: Dictionary
	var paths: Array
	var wires: Array
	var hide_all_labels: bool
	var eng_settings: Dictionary
	var is_powershare_capable: bool
	var is_tesla_electric_site: bool
	
		
	func _init(data: Dictionary = {}):
		components = data.get("components", {})
		paths = data.get("paths", [])
		hide_all_labels = data.get("hideAllLabels", false)
		is_powershare_capable = data.get("isPowershareCapable", false)
		is_tesla_electric_site = data.get("isTeslaElectricSite", false)
		eng_settings = data.get("engSettings", {})

		var json_wires = data.get("wires", [])

		wires = []
		for json_wire in json_wires:
			wires.append(PowerflowWire.new(json_wire))

class EnergySiteSummary extends Resource:
	var battery_type: String
	var has_wall_connector_1
	var has_wall_connector_2
	var weather: Dictionary

		
	func _init(data: Dictionary = {}):
		battery_type = data.get("battery_type", "")
		has_wall_connector_1 = data.get("wall_connector_1_visible", "")
		has_wall_connector_2 = data.get("wall_connector_2_visible", "")
		weather = data.get("weather", {})
	
	func get_site_variant():
		if battery_type == "powerpack" or battery_type == "megapack":
			return EnergySiteType.INDUSTRIAL
		else:
			if has_wall_connector_1 and has_wall_connector_2:
				return EnergySiteType.RESIDENTIAL_COMPOUND
			else:
				return EnergySiteType.RESIDENTIAL_CLASSIC


var energy_site_config: EnergySiteConfig = EnergySiteConfig.new()
var energy_site_summary: EnergySiteSummary = EnergySiteSummary.new()

func _init(data: Dictionary):
	type = ProductType.ENERGY
	update(data)
	id = data.get("id", "") as String
	
func update(data: Dictionary):
	
	var config = data.get("config")
	if config != null:
		energy_site_config = EnergySiteConfig.new(config)
	else:
		print("[godot] config is null in energy site data update")
		
	var summary = data.get("summary")
	if summary != null:
		energy_site_summary = EnergySiteSummary.new(summary)

static func id_from_data(data: Dictionary):
	var id = data.get("id")
	if id == null:
		printerr("Invalid energy site data: ", data)
		return null
	
	return String(id)



func get_site_variant():
	if energy_site_summary == null: return null
	if energy_site_config == null: return energy_site_summary.get_site_variant()
	
	if energy_site_config.is_powershare_capable == true:
		return EnergySiteType.RESIDENTIAL_POWERSHARE
	else:
		return energy_site_summary.get_site_variant()


func get_component(name: String):
	if energy_site_config == null: return null
	
	return energy_site_config.components.get(name, null)

func get_battery_component():
	return get_component("BATTERY")

func get_solar_component():
	return get_component("SOLAR")

func get_generator_component():
	return get_component("GENERATOR")

func get_grid_component():
	return get_component("GRID")

func get_vehicle_component():
	return get_component("VEHICLE_1")
	
func get_vehicle_2_component():
	return get_component("VEHICLE_2")

func has_component(component: String):
	if get_component(component) == null: return false
	return get_component(component).get("visible", false)

func has_battery():
	return has_component("BATTERY")

func has_load():
	return has_component("LOAD")

func has_solar():
	return has_component("SOLAR")

func has_generator():
	return has_component("GENERATOR")

func has_grid():
	return has_component("GRID")

func has_wall_connector_1():
	return has_component("WALL_CONNECTOR_1")
	
func has_wall_connector_2():
	return has_component("WALL_CONNECTOR_2")
	
func has_vehicle_1():
	return has_component("VEHICLE_1")
	
func has_vehicle_2():
	return has_component("VEHICLE_2")
	
func is_tesla_electric():
	return (energy_site_config.is_tesla_electric_site)

func is_empty_site():
	if has_component("BATTERY") or has_component("LOAD") or has_component("SOLAR") or has_component("GENERATOR") or has_component("GRID") or has_component("WALL_CONNECTOR_1"):
		return false
	else:
		return true

func get_vehicle_type():
	var component = get_vehicle_component()

	if component == null: return
	
	match component.get("type", ""):
		"tesla":
			return VehicleType.TESLA
		_:
			return VehicleType.GENERIC
			
func get_vehicle_2_type():
	var component = get_vehicle_2_component()
	

	if component == null: return
	
	match component.get("type", ""):
		"tesla":
			return VehicleType.TESLA
		_:
			return VehicleType.GENERIC
			



func get_vehicle_data() -> VehicleData:
	var component = get_vehicle_component()
	
	if component == null: return null
	
	var vehicle_id = component.get("properties", {}).get("id")
	var vehicle_config = component.get("properties", {}).get("config", {})
	var vehicle_wrap = component.get("properties", {}).get("car_wrap_state", {})
	
	if vehicle_id == null: return null
	
	return VehicleData.new({
		"id": vehicle_id, 
		"vehicle_config": vehicle_config, 
		"car_wrap_state": vehicle_wrap
	})
	
func get_vehicle_2_data() -> VehicleData:
	var component = get_vehicle_2_component()
	
	if component == null: return null
	
	var vehicle_id = component.get("properties", {}).get("id")
	var vehicle_config = component.get("properties", {}).get("config", {})
	var vehicle_wrap = component.get("properties", {}).get("car_wrap_state", {})
	
	if vehicle_id == null: return null
	
	return VehicleData.new({
		"id": vehicle_id, 
		"vehicle_config": vehicle_config, 
		"car_wrap_state": vehicle_wrap
	})

func get_battery_type():
	var component = get_battery_component()

	if component == null: return
	
	match component.get("type", ""):
		"solar_powerwall":
			return BatteryType.SOLAR_POWERWALL
		"powerpack":
			return BatteryType.POWERPACK
		"megapack":
			return BatteryType.MEGAPACK
		"penguin":
			return BatteryType.PENGUIN
		_:
			return BatteryType.AC_POWERWALL

func get_battery_has_integrated_inverter():
	var battery_type = get_battery_type()

	if battery_type == null: return false
	
	match battery_type:
		BatteryType.SOLAR_POWERWALL:
			return true
		BatteryType.PENGUIN:
			return true
		_:
			return false
					
func get_solar_type():
	var component = get_solar_component()
	
	if component == null: return
	
	if component.get("type", "pv_panel") == "solarglass":
		return SolarType.SOLAR_ROOF
	else:
		return SolarType.SOLAR_PANEL
