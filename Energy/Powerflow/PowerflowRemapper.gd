extends Node




export (NodePath) var powerflow_display_path
onready var powerflow_display: PowerflowDisplay = get_node_or_null(powerflow_display_path)

onready var energy_site = find_parent("EnergySite*")

func _ready():
	process_priority = 10
	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")


func reset_display():
	powerflow_display.set_all_path_direction(PowerflowDisplay.Direction.HIDDEN)

func update(data: EnergySiteData):
	reset_display()
	powerflow_display.powerflow_offset = data.energy_site_config.eng_settings.get("powerflowOffset", - 1)

	
	for i in range(16):
		var direction = data.energy_site_config.paths[i] if i < data.energy_site_config.paths.size() else PowerflowDisplay.Direction.HIDDEN
		powerflow_display.set_path_direction(i, direction)
