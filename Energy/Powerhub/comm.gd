extends Node


var instance_id = ""

func _ready():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		
		if argument.find("=") > - 1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
			
	instance_id = arguments.get("instance_id", "")
	
	print("instance id: '%s'" % instance_id)
	
	
	
	var mobile_comm = get_parent()
	if mobile_comm == null: return
	
	mobile_comm.register_listener(ReactMsg.QUIT, funcref(self, "onQuit"))
	
func pendingMessagesCount():
	var pendingMessages = JavaScript.eval("window.godot_comm.godot_pendingMessagesCount('%s')" % instance_id)
	if pendingMessages != null: return pendingMessages
	
	return 0
	
func sendMessage(msg: String):
	JavaScript.eval("window.godot_comm.godot_sendMessage('%s', '%s')" % [instance_id, msg.replace("'", "\\'")])
	
func getMessage():
	return JavaScript.eval("window.godot_comm.godot_getMessage('%s')" % instance_id)

func onQuit(data: Dictionary):
	print("Quitting at request of Powerhub")
	get_tree().quit()
