extends Spatial
class_name EnergyComponentSwitcher

var component_name = ""



var current_spatial: Spatial = null
var current_resource_path: String = ""


onready var energy_site: Node

signal click

func _ready():
	if get_name().match ("EnergySite*"): energy_site = self
	else: energy_site = find_parent("EnergySite*")
	
	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update_model")
	
	update_model(energy_site.data)


func get_parent_node() -> Node:
	return self


func get_resource_path():
	return ""


func before_model_add():
	pass

func set_model_parent(parent: Node):
	if parent == null: parent = self
	if current_spatial == null: return

	if current_spatial.get_parent() != null:
		current_spatial.get_parent().remove_child(current_spatial)

	parent.add_child(current_spatial)


func switch_model(resource_path: String):
	if current_resource_path == resource_path: return
	
	
	remove_model()

	
	if resource_path == "": return
	
	current_resource_path = resource_path
	
	current_spatial = load(resource_path).instance()

	before_model_add()

	set_model_parent(get_parent_node())

func remove_model():
	current_resource_path = ""
	
	if current_spatial != null:
		if current_spatial.get_parent() != null: current_spatial.get_parent().remove_child(current_spatial)
		current_spatial.queue_free()
		current_spatial = null

	
func update_model(data: EnergySiteData):
	if data == null: return

	var component = data.get_component(component_name)

	if component == null:
		remove_model()
		return
	
	switch_model(get_resource_path())
