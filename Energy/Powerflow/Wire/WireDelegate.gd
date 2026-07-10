extends Spatial





class_name EnergySitePowerflowWireDelegate

const INDEX_MAP = "ABCDEF"


func show_wires(wires: Array):
	visible = true
	for index in wires.size():
		var wire = wires[index]
		var node_name = "%s-%s" % [name, INDEX_MAP[index]]
		var wire_node = get_node_or_null(node_name)
		
		if wire_node == null:
			printerr("Missing wire node '%s'" % node_name)
			continue
			
		wire_node.wire = wire
