extends Node



export (NodePath) var grid_path = ""
export (NodePath) var off_grid_path = ""

onready var grid = get_node_or_null(grid_path)
onready var off_grid = get_node_or_null(off_grid_path)

func _ready():
	process_priority = 10

	var energy_site = find_parent("EnergySite*")
	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)

func update(data: EnergySiteData):
	if grid == null or off_grid == null: return
	
	grid.visible = true
	off_grid.visible = false
	
	var component = data.get_grid_component()
	if component == null: return

	var properties = component.get("properties", null)
	if properties == null: return
	
	var island_status = properties.get("islandStatus", null)
	if island_status == null: return
	
	match island_status.to_upper():
		"OFF_GRID_INTENTIONAL", "OFF_GRID_UNINTENTIONAL", "OFF_GRID_UNINTENTIONAL_TRANSITIONING_ON_GRID", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_SOLAR", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_JUMP_START", "OFF_GRID_UNINTENTIONAL_OVERLOAD", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER_MANUAL_BACKUP", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER_LOW_SOE", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER_NO_INVERTERS_READY", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER_RETRIES_EXHAUSTED":
			grid.visible = false
			off_grid.visible = true
