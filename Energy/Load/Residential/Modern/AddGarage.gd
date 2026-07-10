extends Spatial

onready var energy_site = find_parent("EnergySite*")

func _ready():
	
	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")
	
	update(energy_site.data, false)
	
func update(data: EnergySiteData, animate = false):
	if data == null: return
	if data.energy_site_summary.has_wall_connector_1 and data.energy_site_summary.has_wall_connector_2 == true:
		for i in self.get_children():
			
			i.visible = true
	else:
		for i in self.get_children():
			i.visible = false
