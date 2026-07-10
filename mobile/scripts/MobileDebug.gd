extends Label

const ReactMsg = preload("res://mobile/scripts/ReactMsg.gd")
onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm")


func _ready():
	mobile_comm.register_listener(ReactMsg.SHOW_FPS, funcref(self, "on_show_fps"))

func on_show_fps(data: Dictionary):
	visible = data.get("show", false)
	

func _process(delta):
	if not visible: return
	text = "FPS: " + String(Engine.get_frames_per_second())
