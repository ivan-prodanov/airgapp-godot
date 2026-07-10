extends Node


onready var energy_site = find_parent("EnergySite*")


export (String, "BATTERY", "LOAD", "SOLAR", "GRID", "GENERATOR", "WALL_CONNECTOR_1", "WALL_CONNECTOR_2", "VEHICLE_1", "VEHICLE_2") var component_name

export (NodePath) var pointcloud_path
onready var pointcloud = get_node_or_null(pointcloud_path)

func _ready():
	
	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)
	
func update(data: EnergySiteData):
	if data == null: return
	if pointcloud == null: return
	
	pointcloud.enabled = data.has_component(component_name)
