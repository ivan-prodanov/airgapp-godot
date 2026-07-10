extends Node



export (float, 0, 1000) var solar_roof_wire_terminate = 1000
export (float, 0, 1000) var solar_panel_wire_terminate = 1

export (NodePath) var wire_display_path = ""
onready var wire_display = get_node_or_null(wire_display_path)

func _ready():
	process_priority = 10

	var energy_site = find_parent("EnergySite*")
	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)

func update(data: EnergySiteData):
	if wire_display == null: return

	wire_display.wire_terminate_at = solar_roof_wire_terminate if data.get_solar_type() == EnergySiteData.SolarType.SOLAR_ROOF else solar_panel_wire_terminate
