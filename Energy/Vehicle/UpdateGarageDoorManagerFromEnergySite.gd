extends Node

onready var energy_site = find_parent("EnergySite*")

func _ready():
	if energy_site == null: return
	energy_site.connect("on_energy_site_update", self, "update")
	
func update(data: EnergySiteData):
	get_parent().open = data.has_wall_connector_1()
