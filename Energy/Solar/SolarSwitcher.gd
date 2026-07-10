extends EnergyComponentSwitcher
class_name EnergySolarSwitcher

export (String, FILE, "*.tscn") var no_solar_resource_path
export (String, FILE, "*.tscn") var solar_roof_resource_path
export (String, FILE, "*.tscn") var solar_panel_resource_path
export (String, FILE, "*.tscn") var two_car_solar_panel_resource_path
export (String, FILE, "*.tscn") var two_car_solar_roof_resource_path

onready var RESOURCE_PATH = {
	EnergySiteData.SolarType.SOLAR_ROOF: solar_roof_resource_path, 
	EnergySiteData.SolarType.SOLAR_PANEL: solar_panel_resource_path, 
}

func _ready():
	component_name = "SOLAR"

func check_solar_size():
	
	if energy_site.data == null: return
	
	if (energy_site.data.has_wall_connector_1() and energy_site.data.has_wall_connector_2()):
		RESOURCE_PATH[EnergySiteData.SolarType.SOLAR_PANEL] = two_car_solar_panel_resource_path
		RESOURCE_PATH[EnergySiteData.SolarType.SOLAR_ROOF] = two_car_solar_roof_resource_path
	else:
		RESOURCE_PATH[EnergySiteData.SolarType.SOLAR_PANEL] = solar_panel_resource_path
		RESOURCE_PATH[EnergySiteData.SolarType.SOLAR_ROOF] = solar_roof_resource_path

func get_resource_path():
	if energy_site.data == null: return
	
	if not energy_site.data.has_solar(): return no_solar_resource_path
	if energy_site.data.get_site_variant() == EnergySiteData.EnergySiteType.RESIDENTIAL_POWERSHARE:
		
		check_solar_size()
	return RESOURCE_PATH.get(energy_site.data.get_solar_type(), solar_panel_resource_path)
