tool 
extends Spatial

enum TIME_OF_DAY{DAY = 0, NIGHT = 1}

export (bool) var is_visible setget set_visible
export (TIME_OF_DAY) var time_of_day setget set_time_of_day

export (Texture) var day_texture
export (Texture) var night_texture

export (NodePath) var marker_sprite_path
export (NodePath) var tween_path

onready var marker_sprite: Sprite3D = get_node_or_null(marker_sprite_path)
onready var tween: Tween = get_node_or_null(tween_path)

func _ready():
	if not Engine.editor_hint:
		marker_sprite.scale.y = 0.0

func show():
	if not tween or not marker_sprite: return false
	
	tween.interpolate_property(marker_sprite, "scale:y", 
		marker_sprite.scale.y, 1.0, 1, 
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	return true

func hide():
	if not tween or not marker_sprite: return false
	
	tween.interpolate_property(marker_sprite, "scale:y", 
		marker_sprite.scale.y, 0.0001, 1, 
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	return true
	
func set_visible(visible: bool):
	if is_visible == visible: return
	is_visible = visible
	
	if visible:
		show()
	else:
		hide()

func set_time_of_day(new_time_of_day):
	if time_of_day == new_time_of_day: return
	time_of_day = new_time_of_day
	
	update_color()

func update_color():
	var new_texture = night_texture;
	if time_of_day == TIME_OF_DAY.DAY:
		new_texture = day_texture;
		
	marker_sprite.texture = new_texture
