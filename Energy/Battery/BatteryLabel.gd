extends Node



onready var label = $Label

onready var energy_site = find_parent("EnergySite*")

func _ready():
	if energy_site == null: return
	
	energy_site.connect("on_energy_site_update", self, "update")

	label.connect("click", self, "on_click")

func update(data: EnergySiteData):
	label.visible = battery_manager.label_shown
	
	label.header_text = battery_manager.label_header
	label.body_text = battery_manager.label_body
	
	label.error = battery_manager.error

func on_click():
	if battery_manager == null: return
	
	battery_manager.emit_signal("click")
