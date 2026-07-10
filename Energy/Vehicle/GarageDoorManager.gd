extends MeshInstance

export var open = false setget set_open

export (NodePath) var shadow
onready var shadow_node = get_node_or_null(shadow)

func set_open(new_open):
	open = new_open
	update()

func update(animate = true):
	visible = not open
	shadow_node.visible = open

