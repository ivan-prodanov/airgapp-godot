tool 
extends Spatial

export (NodePath) var player_path: NodePath setget set_player_path
export (int) var open_percentage
export (int) var animation_speed_up_factor setget set_animation_speed_up_factor
export (NodePath) var tween_path: NodePath
export (NodePath) var cover_path: NodePath

onready var tween: Tween = get_node_or_null(tween_path)
onready var player: AnimationPlayer = get_node_or_null(player_path)
onready var cover: MeshInstance = get_node_or_null(cover_path)
var animation_length: float = 0.0
var current_percentage: float = 0.0

func _ready():
	animation_length = player.get_animation(get_animation_name(player)).length if get_animation_name(player) else 0.0

func set_is_mobile(_is_mobile: bool):
	if cover:
		cover.set_visible( not _is_mobile)

func set_player_path(new_player_path: NodePath):
	player_path = new_player_path
	player = get_node_or_null(player_path)
	animation_length = player.get_animation(get_animation_name(player)).length if get_animation_name(player) else 0.0

func set_open_percentage(percentage: int, animated: bool):
	if not player:
		print("[Tonneau] no animation player set!")
		return
	if animated and not tween:
		print("[Tonneau] no tween found!")
		return
	play_to(percentage, animated)

func set_animation_speed_up_factor(new_factor: int):
	animation_speed_up_factor = new_factor

func play_to(percentage: int, animated: bool):
	var animation_name = get_animation_name(player)
	if not animation_name:
		return
	player.play(animation_name, - 1, 0)
	tween.stop(self)
	var duration = abs(percentage - current_percentage) / (animation_speed_up_factor * 100) * animation_length
	if animated:
		tween.interpolate_method(self, "seek", current_percentage, percentage, duration)
		tween.start()
	else:
		seek(percentage)

func seek(percentage: int):
	current_percentage = percentage
	var animation_name = get_animation_name(player)
	var second = animation_length * percentage / 100
	print("[Tonneau] seek second", second)
	player.seek(second, true)

func get_animation_name(player: AnimationPlayer):
	if not player:
		printerr("player is null")
		return null
	var animation_list = player.get_animation_list()
	if animation_list.empty():
		printerr("Animation list empty")
		return null
	return animation_list[0]
