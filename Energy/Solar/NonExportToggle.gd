extends Node




onready var energy_site = find_parent("EnergySite*")
var component_name = "SOLAR"

export (NodePath) var label_path
onready var label = get_node(label_path)

func _ready():
	if label == null: return
	
	
	if energy_site == null:
		label.body_icon = false
		return

	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)
	
func update(data: EnergySiteData):
	if data == null: return
	var component = data.get_component(component_name)
	
	if component == null: return
	if label == null: return

	var properties = component.get("properties", {})
	label.show_body_icon = properties.get("nonExport", false)
