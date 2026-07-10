extends EnergyComponentSwitcher
class_name EnergyGeneratorSwitcher

export (String, FILE, "*.tscn") var generator_resource_path

export (NodePath) var generator_standalone_node
export (NodePath) var generator_with_grid_node

func _ready():
	component_name = "GENERATOR"

func get_resource_path():
	if not energy_site.data.has_component(component_name): return ""
	return generator_resource_path

func get_parent_node() -> Node:
	if energy_site == null: return null
	if energy_site.data == null: return null
	
	if energy_site.data.has_grid():
		return get_node(generator_with_grid_node)
	
	return get_node(generator_standalone_node)
