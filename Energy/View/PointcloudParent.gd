extends Spatial
class_name EnergyPointcloudParent





var pointcloud_name = ""

var energy_camera = null

export var enabled = true setget set_enabled, get_enabled

func _ready():
	var energy_site = find_parent("EnergySite*")
	if energy_site == null: return
	pointcloud_name = name
	
	energy_camera = energy_site.get_camera()
	energy_camera.add_pointcloud(self)


func _exit_tree():
	if energy_camera == null: return
	energy_camera.remove_pointcloud(self)

func _enter_tree():
	if energy_camera == null: return
	energy_camera.add_pointcloud(self)

func get_enabled():
	return enabled
	
func set_enabled(new_enabled: bool):
	if enabled == new_enabled: return

	enabled = new_enabled

	if energy_camera == null: return
	energy_camera.set_dirty()
