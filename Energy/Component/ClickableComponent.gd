extends Node

export (String, "BATTERY", "LOAD", "SOLAR", "GRID", "GENERATOR", "VEHICLE_1", "VEHICLE_2") var component_name

onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm") as MobileComm
signal click

func _ready():
	connect("click", self, "on_click")

func on_click():
	mobile_comm.send_message(GodotMsg.ENERGY_SITE_COMPONENT_SELECTED, {"component": component_name, "type": "3d"})
