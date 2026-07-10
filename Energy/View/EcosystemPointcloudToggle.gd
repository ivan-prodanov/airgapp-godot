extends Node


onready var energy_site = find_parent("EnergySite*")

export (NodePath) var pointcloud_path
onready var pointcloud = get_node(pointcloud_path)

func _ready():
	
	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)
	
func update(data: EnergySiteData):
	if data == null: return
	if pointcloud == null: return
	
	pointcloud.enabled = data.has_grid() or data.has_generator() or data.has_solar() or data.has_battery() or data.has_load() or data.is_empty_site()
