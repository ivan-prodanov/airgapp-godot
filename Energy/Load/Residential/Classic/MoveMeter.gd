extends Spatial

onready var energy_site = find_parent("EnergySite*")

export var default_location = Vector3(0.0, 0.39, 0.2)
export var empty_site_location = Vector3(0.0, 0.39, 0.95)

func _ready():
	
	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)
	
func update(data: EnergySiteData):
	if data == null: return
	
	
	
	if data.is_empty_site():
		self.translation = empty_site_location
	else:
		self.translation = default_location
