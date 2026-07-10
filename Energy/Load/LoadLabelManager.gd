extends Spatial
class_name EnergyLoadLabelManager

func _ready():
	var load_label = load("res://Energy/Load/LoadLabel.tscn").instance()
	add_child(load_label)

