extends Node

class_name EnergySitePowerflowWireRemapper











export (NodePath) var wire_display_path = ""
onready var wire_display = get_node_or_null(wire_display_path)





func get_wire_exists_between_components():
	return []
	
func _ready():
	process_priority = 10

	var energy_site = find_parent("EnergySite*")

	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)

func update(data: EnergySiteData):
	var wire_between_components = get_wire_exists_between_components()
	var wires_we_draw = []
	var wire_sources = []
	var show_idle_wire = false
	
	for wire in data.energy_site_config.wires:
		for component_pair in wire_between_components:
			var matches_forwards = wire.source == component_pair[0] and wire.destination == component_pair[1]
			var matches_reverse = wire.source == component_pair[1] and wire.destination == component_pair[0]
			if matches_forwards or matches_reverse:
				if wire.is_flowing:
					
					
					if wire_sources.has(wire.source):
						continue
					var direction = PowerflowDisplay.Direction.FLOW_IN if matches_forwards else PowerflowDisplay.Direction.FLOW_OUT
					wires_we_draw.append(EnergySitePowerflowWireDisplay.Wire.new(direction, wire.source, wire.wire_color))
					wire_sources.append(wire.source)
				else:
					show_idle_wire = true

	var wire_count = wires_we_draw.size()
	
	
	if data.energy_site_config.hide_all_labels:
		wire_count = - 1

	
	
	
	if show_idle_wire and wire_count == 0:
		wire_count = 1
		wires_we_draw.append(EnergySitePowerflowWireDisplay.Wire.new(PowerflowDisplay.Direction.IDLE))

	if wire_display != null:
		if wire_count >= 1:
			wire_display.wire = wires_we_draw[0]
		return

	for c in get_children():
		c.visible = false

	var delegate = get_node_or_null("%s-%d" % [name, wire_count])
	
	
	if delegate == null:
		printerr("No wire delegate '%s-%d'" % [name, wire_count])
		return

	delegate.show_wires(wires_we_draw)
