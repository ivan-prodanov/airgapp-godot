extends Spatial
class_name EnergySite

onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm") as MobileComm
onready var LOG: LOG = get_node("/root/Mobile/Log")

const MobileComm = preload("res://mobile/scripts/MobileComm.gd")
const EnergySiteData = preload("res://mobile/scripts/data/EnergySiteData.gd")
const GodotMsg = preload("res://mobile/scripts/GodotMsg.gd")

signal on_energy_site_update(energy_site_data)

export (NodePath)onready var site_root = get_node(site_root)

export (String, FILE, "*.tscn") var residential_classic_energy_site_path: String = "res://Energy/Load/Residential/Classic/ResidentialClassic.tscn"
export (String, FILE, "*.tscn") var residential_compound_energy_site_path: String = "res://Energy/Load/Residential/Compound/ResidentialCompound.tscn"
export (String, FILE, "*.tscn") var industrial_energy_site_path: String = "res://Energy/Load/Industrial/Generic/IndustrialGeneric.tscn"
export (String, FILE, "*.tscn") var residential_powershare_energy_site_path: String = "res://Energy/Load/Residential/Modern/ResidentialPowershare.tscn"

var energy_site_id: String
var data: EnergySiteData

var current_energy_site_path: String = ""
var energy_site_spatial: Spatial

var dirty = true

func _ready():
	process_priority = - 1

func get_energy_site_path():
	if data == null: return ""
	
	match data.get_site_variant():
		EnergySiteData.EnergySiteType.INDUSTRIAL:
			return industrial_energy_site_path
		EnergySiteData.EnergySiteType.RESIDENTIAL_COMPOUND:
			return residential_compound_energy_site_path
		EnergySiteData.EnergySiteType.RESIDENTIAL_POWERSHARE:
			return residential_powershare_energy_site_path
		_:
			return residential_classic_energy_site_path

func update(data: EnergySiteData, animated: bool = false):
	self.data = data
	energy_site_id = data.id

	update_model()
	dirty = true
	
func update_model():
	if get_energy_site_path() == current_energy_site_path:
		return
		
	current_energy_site_path = get_energy_site_path()

	if energy_site_spatial != null:
		energy_site_spatial.get_parent().remove_child(energy_site_spatial)
		energy_site_spatial.queue_free()
		energy_site_spatial = null

	if current_energy_site_path == "": return
	
	energy_site_spatial = load(current_energy_site_path).instance()
	site_root.add_child(energy_site_spatial)






const ray_length = 1000
const pressInOutDeltaThreshold = 10


const LABEL_TAP_TARGET_MASK = 1 << 14

var pressInEvent = null
var pressOutEvent = null
var handlingEvent = false

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			pressInEvent = event
		else:
			pressOutEvent = event

func crossesEventThresh():
	var pressInOutDeltaX = pressInEvent.position.x - pressOutEvent.position.x
	var pressInOutDeltaY = pressInEvent.position.y - pressOutEvent.position.y
	return abs(pressInOutDeltaX) < pressInOutDeltaThreshold and abs(pressInOutDeltaY) < pressInOutDeltaThreshold

func shouldHandleTouchEvent():
	return pressInEvent != null and pressOutEvent != null and not handlingEvent and crossesEventThresh()








func _process(delta):
	if dirty:
		emit_signal("on_energy_site_update", data)
		dirty = false
		
	var camera: Camera = get_camera()

	if shouldHandleTouchEvent():
		handlingEvent = true
		var from = camera.project_ray_origin(pressOutEvent.position)
		var to = from + camera.project_ray_normal(pressOutEvent.position) * ray_length
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [], LABEL_TAP_TARGET_MASK, true, true)
		if result:
			result.collider.emit_signal("click")
			
		pressInEvent = null
		pressOutEvent = null
		handlingEvent = false

func get_camera():
	return $Camera
