extends Node

var camera
onready var toggle_mobile_view_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/ToggleMobileView")
onready var mobile_view_active = false

func _ready():
	camera = get_node("../Camera")
	if toggle_mobile_view_node != null:
		toggle_mobile_view_node.connect("toggle_mobile_view", self, "on_toggle_mobile_view")
	
func on_toggle_mobile_view():
	print("SHOWING OVERLAY!" if not mobile_view_active else "HIDING OVERLAY!")
	if not mobile_view_active:
		camera.load_image_overlay("res://mobile/devinspector/EnergyHomeScreenOverlay.png")
		camera.show_overlay()
	else:
		camera.hide_overlay()
	mobile_view_active = not mobile_view_active
