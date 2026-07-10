extends Node

onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm") as MobileComm
const GodotMsg = preload("res://mobile/scripts/GodotMsg.gd")




onready var energy_site = find_parent("EnergySite*")

export (String, "BATTERY", "LOAD", "SOLAR", "GRID", "GENERATOR", "VEHICLE_1", "VEHICLE_2", "WALL_CONNECTOR_1", "WALL_CONNECTOR_2") var component_name

export var manage_visibility = true

export (NodePath) var label_path
onready var label = get_node(label_path)

func _ready():
	if label == null: return
	
	
	if energy_site == null:
		label.header_text = "--"
		label.body_text = "--"
		label.error = true
		return
	
	if component_name.empty():
		label.header_text = "--"
		label.body_text = "--"
		label.error = true
		return
	
	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)
	
	label.connect("click", self, "on_click")

func update(data: EnergySiteData):
	if data == null: return

	var component = data.get_component(component_name)
	
	if component == null: return

	if label == null: return

	label.show_label = component.get("visible", false)
	label.show_label = component.get("showLabel", label.show_label)

	label.header_text = component.get("header", "")
	label.body_text = component.get("body", "")
	label.override_color = component.get("color", null)
	
	label.error = component.get("error", false)
	
	if data.energy_site_config.hide_all_labels:
		label.show_label = false
	
	
	var properties = component.get("properties")
	if properties == null:
		label.charging_state = ""
		return
	label.charging_state = properties.get("batteryChargingState")

func on_click():
	mobile_comm.send_message(GodotMsg.ENERGY_SITE_COMPONENT_SELECTED, {"component": component_name, "type": "label"})
