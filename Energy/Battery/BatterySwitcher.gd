extends EnergyComponentSwitcher
class_name EnergyBatterySwitcher



var powerwall2_resource_path = "res://Energy/Battery/Powerwall2/Powerwall2.tscn"
var solar_powerwall_resource_path = "res://Energy/Battery/SPW/SPW.tscn"
var powerpack_resource_path = "res://Energy/Battery/Powerpack/Powerpack.tscn"
var megapack_resource_path = "res://Energy/Battery/Megapack/Megapack.tscn"
var penguin_resource_path = "res://Energy/Battery/Penguin/Penguin.tscn"

onready var RESOURCE_PATH = {
	EnergySiteData.BatteryType.DC_POWERWALL: powerwall2_resource_path, 
	EnergySiteData.BatteryType.AC_POWERWALL: powerwall2_resource_path, 
	EnergySiteData.BatteryType.SOLAR_POWERWALL: solar_powerwall_resource_path, 
	EnergySiteData.BatteryType.POWERPACK: powerpack_resource_path, 
	EnergySiteData.BatteryType.MEGAPACK: megapack_resource_path, 
	EnergySiteData.BatteryType.PENGUIN: penguin_resource_path, 
}

func _ready():
	component_name = "BATTERY"

func before_model_add():
	if (energy_site.data.get_battery_type() == EnergySiteData.BatteryType.PENGUIN):
		self.current_spatial.scale = Vector3(1.35, 1.35, 1)

	if energy_site.data.get_site_variant() == EnergySiteData.EnergySiteType.RESIDENTIAL_POWERSHARE:
		if (energy_site.data.get_battery_type() != EnergySiteData.BatteryType.SOLAR_POWERWALL):
			self.current_spatial.scale = Vector3(1.18, 1.18, 1)

func get_resource_path():
	if not energy_site.data.has_component(component_name): return ""
	return RESOURCE_PATH.get(energy_site.data.get_battery_type(), powerwall2_resource_path)
