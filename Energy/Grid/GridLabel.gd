extends Node

onready var energy_site = find_parent("EnergySite*")


var grid_standalone: Node
var grid_with_generator: Node

export (NodePath) var label_path

func _ready():
	if energy_site == null: return

	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)


func get_reference_position(data: EnergySiteData):
	if data.has_generator():
		return grid_with_generator
	return grid_standalone

func update(data: EnergySiteData):
	if data == null: return
	
	var reference_position = get_reference_position(data)
	if reference_position == null: return

	var label = get_node(label_path)
	
	if label == null: return
	
	label.reference_position = reference_position
