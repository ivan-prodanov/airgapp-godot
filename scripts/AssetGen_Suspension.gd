tool 
extends Spatial






func setup():
	print("setup: " + self.name);
	var current_ego_scene = get_node_or_null("/root/visualizer/ego/ROOT");
	if current_ego_scene and current_ego_scene.has_method("hide_wheels"):
		current_ego_scene.hide_wheels(true);


func teardown():
	print("teardown: " + self.name);
	var current_ego_scene = get_node_or_null("/root/visualizer/ego/ROOT");
	if current_ego_scene and current_ego_scene.has_method("hide_wheels"):
		current_ego_scene.hide_wheels(false);
