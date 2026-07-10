extends Node

var pending_messages: Array = []
var sent_messages: Array = []


func addMessage(message: String):
	pending_messages.append(message)


func pendingMessagesCount() -> int:
	return pending_messages.size()


func getMessage() -> String:
	if pending_messages.empty():
		return ""
	return pending_messages.pop_front()


func sendMessage(message: String):
	sent_messages.append(message)
	print("[LocalGodotInterface] Godot -> host: %s" % message)
