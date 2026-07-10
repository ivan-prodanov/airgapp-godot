tool 
class_name ThemeManager
extends Node

onready var mobile_comm: MobileComm = get_node("../MobileComm")

signal set_app_theme(theme)

enum ThemeType{
	LIGHT, 
	DARK
}

const ThemeTypeMap = {
	"light": ThemeType.LIGHT, 
	"dark": ThemeType.DARK
}

export (ThemeType) var app_theme = ThemeType.DARK setget set_app_theme

func _ready():
	mobile_comm.register_listener(ReactMsg.SET_APP_THEME, funcref(self, "on_set_app_theme"))

func on_set_app_theme(data: Dictionary):
	var mobile_app_theme = data.get("theme", "dark")
	var theme = ThemeTypeMap.get(mobile_app_theme, ThemeType.DARK)
	set_app_theme(theme)

func set_app_theme(theme):
	app_theme = theme
	emit_signal("set_app_theme", app_theme)
