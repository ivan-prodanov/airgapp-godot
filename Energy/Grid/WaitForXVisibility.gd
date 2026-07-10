extends MeshInstance

onready var energy_site = find_parent("EnergySite*")

export (Color) var intentional_color = Color("#ff8c00")
export (Color) var unintentional_color = Color("#FF3A3A")

func _ready():
	if energy_site == null: return

	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)

func get_material():
	return get_surface_material(0)

func update(data: EnergySiteData):
	visible = false
	if data == null: return
	
	var component = data.get_grid_component()
	if component == null: return

	var properties = component.get("properties", null)
	if properties == null: return
	
	var island_status = properties.get("islandStatus", null)
	if island_status == null: return
	
	match island_status.to_upper():
		"OFF_GRID_UNINTENTIONAL_WAIT_FOR_SOLAR", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_JUMP_START", "OFF_GRID_UNINTENTIONAL_OVERLOAD", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER_MANUAL_BACKUP", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER_LOW_SOE", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER_NO_INVERTERS_READY", "OFF_GRID_UNINTENTIONAL_WAIT_FOR_USER_RETRIES_EXHAUSTED":
			visible = true
			get_material().set_shader_param("color", unintentional_color)
		_:
			visible = false
