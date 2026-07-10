extends Node

const ReactMsg = preload("res://mobile/scripts/ReactMsg.gd")
const TIME_INCREMENT = 30000

onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm")

var cumulative_frames: float = 0.0
var ticks: int = 0
var time_since_last_update: int = 0

var fps_data: Dictionary = {
	"avg_frame": 0.0, 
}
	
func send_fps_report(current_ticks: int):
	if ticks == 0: return
	var avg_frame: float = cumulative_frames / float(ticks)
	
	fps_data["avg_frame"] = avg_frame
	
	print("[FPS Tracker] Sending FPS to mobile app ", fps_data)
	mobile_comm.send_message(GodotMsg.FPS_LOG_RECEIVED, fps_data)
	
	time_since_last_update = current_ticks
	cumulative_frames = 0.0
	ticks = 0

func _process(delta):
	var current_frame: float = Engine.get_frames_per_second()
	
	cumulative_frames += current_frame
	ticks += 1
	
	var current_ticks: int = OS.get_ticks_msec()
	if (current_ticks - time_since_last_update) > TIME_INCREMENT:
		send_fps_report(current_ticks)
