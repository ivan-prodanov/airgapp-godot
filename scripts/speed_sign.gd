tool 
extends Spatial

export (NodePath) var Speed_5: NodePath
export (NodePath) var Speed_10: NodePath
export (NodePath) var Speed_15: NodePath
export (NodePath) var Speed_20: NodePath
export (NodePath) var Speed_25: NodePath
export (NodePath) var Speed_30: NodePath
export (NodePath) var Speed_35: NodePath
export (NodePath) var Speed_40: NodePath
export (NodePath) var Speed_45: NodePath
export (NodePath) var Speed_50: NodePath
export (NodePath) var Speed_55: NodePath
export (NodePath) var Speed_60: NodePath
export (NodePath) var Speed_65: NodePath
export (NodePath) var Speed_70: NodePath
export (NodePath) var Speed_75: NodePath
export (NodePath) var Speed_80: NodePath
export (NodePath) var Speed_85: NodePath
export (NodePath) var Speed_90: NodePath
export (NodePath) var Speed_95: NodePath
export (NodePath) var Speed_100: NodePath
export (NodePath) var Speed_105: NodePath
export (NodePath) var Speed_110: NodePath
export (NodePath) var Speed_115: NodePath
export (NodePath) var Speed_120: NodePath
export (NodePath) var Speed_125: NodePath
export (NodePath) var Speed_130: NodePath
export (NodePath) var Speed_135: NodePath
export (NodePath) var Speed_140: NodePath

onready var speeds = [
	get_node_or_null(Speed_5), 
	get_node_or_null(Speed_5), 
	get_node_or_null(Speed_10), 
	get_node_or_null(Speed_15), 
	get_node_or_null(Speed_20), 
	get_node_or_null(Speed_25), 
	get_node_or_null(Speed_30), 
	get_node_or_null(Speed_35), 
	get_node_or_null(Speed_40), 
	get_node_or_null(Speed_45), 
	get_node_or_null(Speed_50), 
	get_node_or_null(Speed_55), 
	get_node_or_null(Speed_60), 
	get_node_or_null(Speed_65), 
	get_node_or_null(Speed_70), 
	get_node_or_null(Speed_75), 
	get_node_or_null(Speed_80), 
	get_node_or_null(Speed_85), 
	get_node_or_null(Speed_90), 
	get_node_or_null(Speed_95), 
	get_node_or_null(Speed_100), 
	get_node_or_null(Speed_105), 
	get_node_or_null(Speed_110), 
	get_node_or_null(Speed_115), 
	get_node_or_null(Speed_120), 
	get_node_or_null(Speed_125), 
	get_node_or_null(Speed_130), 
	get_node_or_null(Speed_135), 
	get_node_or_null(Speed_140)
];


var current_speed_node;

export (int, 0, 150, 5) var speed_value = 3 setget set_speed_value;
func set_speed_value(v):
	print("set_speed_value: " + String(v))
	speed_value = v;
	update_speed();


func _ready():
	if speeds:
		for node in speeds:
			if node: node.hide();
	update_speed();

func get_node_by_speed(speed):
	var idx = round(speed / 5);
	if speeds:
		if idx < speeds.size():
			return speeds[idx];
		elif speeds.size():
			return speeds[0];
	return null;
	

func update_speed():
	if current_speed_node: current_speed_node.hide();
	current_speed_node = get_node_by_speed(speed_value);
	if current_speed_node: current_speed_node.show();
	
