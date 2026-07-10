extends Node



export (NodePath) var powershare_with_battery_path = ""
export (NodePath) var powershare_without_battery_path = ""

onready var powershare_with_battery = get_node_or_null(powershare_with_battery_path)
onready var powershare_without_battery = get_node_or_null(powershare_without_battery_path)

func _ready():
	process_priority = 10

	var energy_site = find_parent("EnergySite*")
	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)

func update(data: EnergySiteData):
	if powershare_with_battery == null or powershare_without_battery == null: return
			
	powershare_with_battery.visible = data.has_battery()
	powershare_without_battery.visible = not data.has_battery()
