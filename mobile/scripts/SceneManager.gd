extends Node

const GodotMsg = preload("res://mobile/scripts/GodotMsg.gd")


onready var mobile_comm: MobileComm = get_node("MobileComm") as MobileComm
onready var pool_manager: PoolManager = get_node("PoolManager") as PoolManager
onready var viewport_container: MainViewContainer = get_node("MainViewContainer") as MainViewContainer
onready var app_config: AppConfigManager = get_node("AppConfigManager") as AppConfigManager


onready var rect_size = viewport_container.rect_size

func _ready():
	mobile_comm.send_message(GodotMsg.GODOT_READY)
	
func _notification(notif):
	if OS.get_name() == "Android" or OS.has_feature("editor"): return

	match notif:
		NOTIFICATION_WM_FOCUS_OUT:
			free_scene_memory()
		NOTIFICATION_WM_FOCUS_IN:
			restore_scene()

func free_scene_memory():
	if app_config != null and app_config.scale_framebuffer_on_background == false: return
	print("[SceneManager] Resetting scene")
	
	
	viewport_container.rect_size = Vector2.ONE
	
func restore_scene():
	if app_config != null and app_config.scale_framebuffer_on_background == false: return
	if viewport_container.rect_size != rect_size:
		print("[SceneManager] Restoring scene")
		
		viewport_container.rect_size = rect_size
