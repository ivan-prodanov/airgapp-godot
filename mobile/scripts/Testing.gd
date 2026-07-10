class_name Testing
extends Node

onready var LOG: LOG = get_node("../Log") as LOG
onready var mobile_comm: MobileComm = get_node("../MobileComm") as MobileComm


func _ready():
	if not OS.has_feature("editor"):
		return

	OS.center_window()
	yield(get_parent(), "ready")
	load_fake_messages()

	var inspector_scene_path = "res://mobile/devinspector/Inspector.tscn"
	if ResourceLoader.exists(inspector_scene_path):
		get_parent().add_child(load(inspector_scene_path).instance())

	







func message_from_jsonl_file(file_path: String):
	var count = 0
	for message in LOG.get_stored_rn_messages(file_path):
		count += 1
		print("Stored message ", count)
		if message.empty(): continue
		mobile_comm._on_message(message)


func message_from_resource(filename: String):
	var file = File.new()
	if file.open(filename, File.READ) != OK:
		print("could not open %s" % filename)
		return

	var text = file.get_as_text()
	file.close()

	mobile_comm._on_message(text)

func message_from_text(text: String):
	mobile_comm._on_message(text)


func message_from_file(filename: String):
	message_from_resource("res://mobile/messages/%s" % filename)

func load_fake_messages():
	var app_config_path = "res://mobile/messages/app_config.json"
	var file = File.new()
	if not file.file_exists(app_config_path):
		return
	message_from_file("app_config.json")
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	
	
	
	
	
	

	
	
	
	
	

	
	
	
	
	
	
	
	
