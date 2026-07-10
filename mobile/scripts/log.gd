extends Node
class_name LOG

const GodotMsg = preload("res://mobile/scripts/GodotMsg.gd")
const rn_messages_file_path = "user://logs/rn_messages_log.txt"

var mobile_comm
var rn_messages_file = File.new()
var queued_messages = []
var file_mutex = Mutex.new()
var queue_mutex = Mutex.new()

func _ready():
	mobile_comm = get_node("../MobileComm")
	start_rn_messages_log()


func l(message: String):
	print(message)
	var data: Dictionary = {"message": "[Godot]: " + message}
	mobile_comm.send_message(GodotMsg.LOG, data)

func err(message: String):
	printerr(message)
	var data: Dictionary = {"message": "[Godot]: ERROR: " + message}
	mobile_comm.send_message(GodotMsg.LOG, data)

func start_rn_messages_log():
	var dir = Directory.new()
	dir.open("user://")
	if not dir.dir_exists("user://logs"):
		if dir.make_dir("user://logs") == OK:
			l("Created godot logs directory")
	else:
		l("Godot logs directory present")
			
	
	rn_messages_file.open(rn_messages_file_path, File.WRITE_READ)
	rn_messages_file.close()

func store_rn_message(message: String):
	if file_mutex.try_lock() == OK:
		rn_messages_file.open(rn_messages_file_path, File.READ_WRITE)
		queue_mutex.lock()
		queued_messages.append(message)
		for queued_message in queued_messages:
			
			var index = 0
			while index < queued_message.length():
				var length = min(index + 4096, queued_message.length() - index)
				var substring = queued_message.substr(index, length)
				index += length
				rn_messages_file.store_string(substring)
			rn_messages_file.store_string("\n")
		queue_mutex.unlock()
		rn_messages_file.close()
		file_mutex.unlock()
	else:
		queue_mutex.lock()
		queued_messages.append(message)
		queue_mutex.unlock()

func get_stored_rn_messages(file_path: String):
	var file = File.new()
	if not file.file_exists(file_path):
		printerr(file_path + " does not exist")
		return []
	file.open(file_path, File.READ)
	var messages = []
	while not file.eof_reached():
		messages.append(file.get_line())
	file.close()
	return messages
