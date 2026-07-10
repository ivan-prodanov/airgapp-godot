class_name Road
extends Node

onready var left_lane: CSGMesh = get_node("lane_left")
onready var right_lane: CSGMesh = get_node("lane_right")
onready var tween: Tween = get_node("Tween")

export (float) var min_speed: float = - 20
export (float) var max_speed: float = 60

var offset_speed: float = 0

func _ready():
	var mat = left_lane.material as SpatialMaterial
	if mat == null: return
	mat = mat.duplicate()
	left_lane.material = mat
	right_lane.material = mat
	mat.albedo_color.a = 0
	tween.connect("tween_completed", self, "on_tween_completed")

func set_speed(speed: int):
	var clamped_speed = clamp(float(speed), min_speed, max_speed)
	
	offset_speed = clamped_speed / max_speed * 1.8
	
func show(show: bool, duration: float):
	var mat = left_lane.material as SpatialMaterial
	if mat == null: return
	
	var alpha: float = 0
	if show == true:
		alpha = 1.0
	
	tween.stop_all()
	tween.interpolate_property(left_lane.material, "albedo_color:a", null, alpha, duration, Tween.TRANS_QUART, Tween.EASE_IN)
	tween.start()

func on_tween_completed(object: Object, key_path: NodePath):
	if left_lane.material.albedo_color.a == 0:
		self.queue_free()
	
func _process(delta):
	var mat = left_lane.material as SpatialMaterial
	if mat != null:
		mat.uv1_offset.y = fmod(mat.uv1_offset.y + offset_speed * delta, 10.0)
