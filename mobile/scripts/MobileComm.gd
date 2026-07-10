class_name MobileComm

extends Node

const GodotMsg = preload("res://mobile/scripts/GodotMsg.gd")
const ReactMsg = preload("res://mobile/scripts/ReactMsg.gd")

onready var LOG: LOG = get_node("../Log")

var comm_interface = null
var sent_first_product_loaded = false
var local_dev_injector = null
export(bool) var local_dev_harness = false


var listeners: Dictionary = {}

func _ready():
	print("[MobileComm] OS=%s local_dev_harness=%s" % [OS.get_name(), str(local_dev_harness)])
	match OS.get_name():
		"iOS":
			if Engine.has_singleton("IOSGodotInterface"):
				comm_interface = Engine.get_singleton("IOSGodotInterface")
		"Android":
			if Engine.has_singleton("AndroidGodotInterface"):
				comm_interface = Engine.get_singleton("AndroidGodotInterface")
		"OpenHarmony":
			if Engine.has_singleton("OpenHarmonyGodotInterface"):
				comm_interface = Engine.get_singleton("OpenHarmonyGodotInterface")
		"HTML5":
			if local_dev_harness:
				_setup_local_interface()
			else:
				comm_interface = Node.new()
				comm_interface.set_script(load("res://Energy/Powerhub/comm.gd"))
				add_child(comm_interface)
		"X11", "Windows", "OSX", "Server":
			_setup_local_interface()

	if comm_interface == null and OS.has_feature("editor"):
		_setup_local_interface()

func _process(_delta):
	
	_check_for_messages()


func register_listener(type, callback: FuncRef):
	if listeners.has(type):
		listeners[type].append(callback)
	else:
		listeners[type] = [callback]



func send_message(type, data: Dictionary = {}):
	if comm_interface == null:
		printerr("Attempting to send message but godot interface is null")
		return
		
	if type == null:
		printerr("Attempting to send message of type null")
		return
		
	var typeName = GodotMsg.Name[type]
	if typeName == null:
		printerr("Attempting to send message with invalid type: ", type)
		return
		
	var message = {
		"type": typeName, 
		"data": data, 
	}
	
	var messageString = JSON.print(message)
	comm_interface.sendMessage(messageString)



func _on_message(message_string: String):
	
	
	var parse_result: JSONParseResult = JSON.parse(message_string)
	if parse_result.error != OK:
		LOG.err("Error parsing message: " + parse_result.error_string)
		return
	
	var time_start = OS.get_ticks_msec()
	
	var message = parse_result.result
	var message_type = message.get("type")
	if message_type == null:
		LOG.err("Received message without type: " + message_string)
		return
		
	var type = ReactMsg.Type.get(message_type)
	if type == null:
		LOG.err("Received message of unknown type: " + message_string)
		return

	for callback in listeners.get(type, []):
		if callback.is_valid():
			callback.call_func(message.get("data", {}))
			
	var elapsed = OS.get_ticks_msec() - time_start
	print("Done handling message %s in %fms" % [message_type, elapsed])
	
	if not sent_first_product_loaded and type == ReactMsg.SHOW_PRODUCT:
		sent_first_product_loaded = true
		send_message(GodotMsg.FIRST_PRODUCT_LOADED, {"elapsed": elapsed})
		



func _check_for_messages():
	if comm_interface == null:
		return
	
	
	while comm_interface.pendingMessagesCount() > 0:
		_on_message(comm_interface.getMessage())


func _setup_local_interface():
	if comm_interface != null:
		return

	comm_interface = Node.new()
	comm_interface.name = "LocalGodotInterface"
	comm_interface.set_script(load("res://mobile/scripts/LocalGodotInterface.gd"))
	add_child(comm_interface)

	local_dev_injector = Node.new()
	local_dev_injector.name = "LocalDevMessageInjector"
	local_dev_injector.set_script(load("res://mobile/scripts/LocalDevMessageInjector.gd"))
	local_dev_injector.setup(self, comm_interface)
	add_child(local_dev_injector)
