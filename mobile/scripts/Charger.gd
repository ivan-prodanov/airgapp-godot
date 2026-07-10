extends Spatial

export (NodePath) var base_path

onready var base: Spatial = get_node(base_path)

func reset_base_position():
	if base != null:
		base.global_transform.origin.y = 0

func _ready():
	reset_base_position();
