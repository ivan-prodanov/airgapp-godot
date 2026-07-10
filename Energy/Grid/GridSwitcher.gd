extends Spatial
class_name EnergyGridLabelManager

export (NodePath) var grid_standalone_path
export (NodePath) var grid_with_generator_path

func _ready():
	var grid_label = load("res://Energy/Grid/GridLabel.tscn").instance()
	
	grid_label.grid_standalone = get_node(grid_standalone_path)
	if grid_with_generator_path != null:
		grid_label.grid_with_generator = get_node(grid_with_generator_path)
	
	add_child(grid_label)

