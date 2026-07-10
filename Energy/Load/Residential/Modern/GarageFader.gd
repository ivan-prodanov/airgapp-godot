extends Node

onready var vehicle_node = get_node_or_null("/root/Mobile/MainViewContainer/Viewport/root/ProductSwitcher/Slot/ROOT")
onready var product_manager_node = get_node_or_null("/root/Mobile/ProductManager")
onready var garage_node = get_parent()
onready var tween = get_parent().get_child(1)
signal start_powerflow

func _ready():
	if vehicle_node != null:
		vehicle_node.connect("fade_garage", self, "on_fade_garage")
	else:
		print("Vehicle Manager node is null")

	if product_manager_node != null:
		product_manager_node.connect("unfade_garage", self, "on_unfade_garage")
	else:
		print("Product Manager node is null")

func on_fade_garage():
	if garage_node == null: return
	if tween == null:
		garage_node.get_surface_material().set_shader_param("fade_amount", 0.2)
		return
	
	tween.connect("tween_all_completed", self, "on_tween_completed")
	tween.interpolate_property(garage_node.get_surface_material(0), "shader_param/fade_amount", 0.7, 0.2, 2.0, 
	Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func on_tween_completed():
	emit_signal("start_powerflow")

func on_unfade_garage():
	if garage_node == null: return
	if tween == null:
		garage_node.get_material().set_shader_param("fade_amount", 0.7)
		return

	tween.interpolate_property(garage_node.get_surface_material(0), "shader_param/fade_amount", - 0.2, 1.2, 3.0, 
	Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
