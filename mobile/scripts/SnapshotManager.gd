extends Node

onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm")
onready var LOG: LOG = get_node("/root/Mobile/Log")

var queue: Array = []
var is_busy: bool = false


func _ready():
	mobile_comm.register_listener(ReactMsg.TAKE_SNAPSHOTS, funcref(self, "take_snapshot"))


func take_snapshot(data: Dictionary):
	
	queue.append(data)
	
	
	if is_busy:
		print("[SnapshotManager] Busy. Waiting...")
		return
	is_busy = true

	
	var snapshot_scene = load("res://mobile/scenes/Snapshot.tscn").instance()
	add_child(snapshot_scene)
	if snapshot_scene == null: return
	
	
	while queue.size() > 0:
		var snapshot_data = queue.pop_front()
		print("[SnapshotManager] Taking snapshot")
		if snapshot_data.get("energy_site") != null:
			yield(snapshot_scene.take_energy_snapshot(snapshot_data), "completed")
		else:
			yield(snapshot_scene.take_snapshot(snapshot_data), "completed")
		print("The updated queue size is ", queue.size())
	print("[SnapshotManager] Complete")

	
	
	call_deferred("remove_child", snapshot_scene)
	if is_instance_valid(snapshot_scene):
		snapshot_scene.queue_free()
	is_busy = false
