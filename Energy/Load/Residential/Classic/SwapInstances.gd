extends Spatial


onready var swap_button = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/SwapInstances")

export (NodePath)onready var instance_1 = get_node(instance_1)
export (NodePath)onready var instance_1_a = get_node(instance_1_a)
export (NodePath)onready var instance_2 = get_node(instance_2)

onready var instance_1_active = true
onready var instance_2_active = false


func _ready():
	if swap_button != null:
		swap_button.connect("swap_instances", self, "_on_swap_instances")
		
func _on_swap_instances():
	print("swapping instances")
	if instance_1_active:
		instance_1.visible = false
		instance_2.visible = true
		if instance_1_a: instance_1_a.visible = false

		instance_1_active = false
	else:
		instance_1.visible = true
		instance_2.visible = false
		if instance_1_a: instance_1_a.visible = true

		instance_1_active = true

