extends Node

onready var energy_site = find_parent("EnergySite*")

export (NodePath) var without_inverter_reference_point_path
export (NodePath) var with_inverter_reference_point_path

export (NodePath) var label_path

func _ready():
	if energy_site == null: return

	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)


func get_reference_path():
	if energy_site.data.get_battery_has_integrated_inverter():
		return with_inverter_reference_point_path
	else:
		return without_inverter_reference_point_path

func update(data: EnergySiteData):
	if data == null: return
	
	var reference_position = get_node_or_null(get_reference_path())
	if reference_position == null: return
	
	var label = get_node(label_path)
	
	if label == null: return
	
	label.reference_position = reference_position
