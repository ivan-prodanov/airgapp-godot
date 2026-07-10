extends Spatial
class_name EnergyVehicleGarageManager

onready var energy_site = find_parent("EnergySite*")

export (NodePath)onready var vehicle = get_node_or_null(vehicle)

var shown = false

var should_animate = true

var charge_port_node = null

signal vehicle_1_plugged_in_change(plugged_in, animate)
signal vehicle_charge_port_node_change(spatial)

onready var tween: Tween = get_node("Tween")

var shown_fraction = 0

func _ready():
	
	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")
	
	if vehicle != null:
		vehicle.connect("vehicle_charge_port_node_change", self, "onVehicleChargePortNodeChange")
		
	update(energy_site.data, false)
	
func update(data: EnergySiteData, animate = false):
	if data == null: return
	
	if vehicle != null:
		vehicle.updateFromEnergySite(data)
	
	var new_shown = data.has_vehicle_1()
	if new_shown == shown: return
	
	shown = new_shown
	should_animate = animate
	
	if shown:
		$AnimationPlayer.play("enter")
	else:
		$AnimationPlayer.play("exit")

	
	if not animate:
		$AnimationPlayer.advance(100)
		setVehiclePluggedIn(shown)

func setVehiclePluggedIn(plugged_in: bool, animate = false):
	call_deferred("emit_signal", "vehicle_1_plugged_in_change", plugged_in, animate if should_animate else false)
	

func onVehicleChargePortNodeChange(spatial: Spatial):
	charge_port_node = spatial
	
func _process(delta):
	emit_signal("vehicle_charge_port_node_change", charge_port_node)
