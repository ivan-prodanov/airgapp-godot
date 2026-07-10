tool 
class_name SkinProps
extends Node

var suppress_skin_update = false

export (Resource) var env setget set_skin_env;
func set_skin_env(v):
	if env and env.is_connected("changed", self, "update_skin"):
		env.disconnect("changed", self, "update_skin")
	if v:
		if not v.is_connected("changed", self, "update_skin"):
			v.connect("changed", self, "update_skin")
	env = v;
	update_skin();
	
export (Resource) var colors setget set_skin_colors;
func set_skin_colors(v):
	if colors and colors.is_connected("changed", self, "update_skin"):
		colors.disconnect("changed", self, "update_skin")
	if v:
		if not v.is_connected("changed", self, "update_skin"):
			v.connect("changed", self, "update_skin")
	colors = v;
	update_skin();

func update_skin():
	if (is_inside_tree() and get_parent() and get_parent().has_method("update_skin") and not suppress_skin_update):
		get_parent().update_skin();
