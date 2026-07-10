extends Node



export (NodePath) var battery_with_inverter_path = ""
export (NodePath) var battery_without_inverter_path = ""

onready var battery_with_inverter = get_node_or_null(battery_with_inverter_path)
onready var battery_without_inverter = get_node_or_null(battery_without_inverter_path)

func _ready():
	process_priority = 10

	var energy_site = find_parent("EnergySite*")
	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)

func update(data: EnergySiteData):
	if battery_with_inverter == null or battery_without_inverter == null: return
	
	var battery_type = data.get_battery_type()
	
	var has_inverter = data.get_battery_has_integrated_inverter()
	
	
	has_inverter = false
			
	battery_with_inverter.visible = has_inverter
	battery_without_inverter.visible = not has_inverter
