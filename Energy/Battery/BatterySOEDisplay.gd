extends Spatial


export (NodePath) var soe_path: NodePath
export (NodePath)onready var powerwall_node = get_node(powerwall_node)

onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm") as MobileComm
onready var soe_mesh_instance: MeshInstance = get_node(soe_path)

onready var energy_site = find_parent("EnergySite*")
onready var is_tesla_wrapped_active

func _ready():
	if energy_site == null: return

	make_material_unique()
	
	energy_site.connect("on_energy_site_update", self, "update")
	update(energy_site.data)

	if mobile_comm != null:
		mobile_comm.register_listener(ReactMsg.ENTER_TESLA_WRAPPED, funcref(self, "set_tesla_wrapped_active"))
		mobile_comm.register_listener(ReactMsg.EXIT_TESLA_WRAPPED, funcref(self, "set_tesla_wrapped_inactive"))

func get_material():
	return soe_mesh_instance.get_surface_material(0)


func update(data: EnergySiteData):
	if data == null: return
	
	var component = data.get_battery_component()
	if component == null: return

	var properties = component.get("properties")
	if properties == null: return
	
	if data.get_site_variant() == EnergySiteData.EnergySiteType.RESIDENTIAL_POWERSHARE:
		
		flip_across_global_x_axis( - 1)
	else:
		flip_across_global_x_axis(1)
	
	if properties.get("batteryChargingState", "UNAVAILABLE") == "UNAVAILABLE":
		soe_mesh_instance.visible = false
	else:
		soe_mesh_instance.visible = true

	var soe = properties.get("batterySOE", 0)
	
	get_material().set_shader_param("soe", soe / 100)
	
	get_material().set_shader_param("pulse_strength", 0 if properties.get("batteryChargingState", "STANDBY") == "STANDBY" else 1)


func _process(delta):
	var time = (OS.get_ticks_msec() / 1000) % 10
	get_material().set_shader_param("time", time)
	
func flip_across_global_x_axis(flip_factor):
	if powerwall_node == null: return
	if is_tesla_wrapped_active: return
	self.translation.x = ( - abs(self.translation.x)) * flip_factor
	
	powerwall_node.get_surface_material(0).set_shader_param("LIGHT_DIRECTION", Vector3(flip_factor, 0, 0))
	
func make_material_unique():
	
	if powerwall_node == null: return
	powerwall_node.set_surface_material(0, powerwall_node.get_surface_material(0).duplicate())
	
func set_tesla_wrapped_active(data: Dictionary):
	is_tesla_wrapped_active = true
	
func set_tesla_wrapped_inactive(data: Dictionary):
	is_tesla_wrapped_active = false
