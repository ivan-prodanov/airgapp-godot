tool 
extends Spatial

enum GLOW_STATE{INVALID, OFF, BLUE_PULSE, WHITE_READY, BLUE_READY, RED}

export (GLOW_STATE) var state setget set_state
export (bool) var dark_background = true setget set_dark_background

var is_shown = false

func _ready():
	var glow = get_node("glow");
	var material = glow.get_surface_material(0).duplicate();
	glow.set_surface_material(0, material);

	var tween = get_node("Tween");
	tween.connect("tween_completed", self, "on_tween_completed")

	if Engine.editor_hint:
		set_state(GLOW_STATE.OFF);
		state = GLOW_STATE.INVALID;

func set_state(new_state):
	if (state == new_state): return ;
	var wasOff = state == GLOW_STATE.OFF;
	state = new_state;
	var tween = get_node("Tween");
	var glow = get_node("glow");
	var animation = get_node("AnimationPlayer")

	if (new_state == GLOW_STATE.OFF):
		animation.stop("Pulse");
		tween.interpolate_property(glow, "material/0:albedo_color:a", 
			glow.get_surface_material(0).albedo_color.a, 0, 0.5, 
			Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		is_shown = false;
		tween.start();
		return ;

	is_shown = true;
	show();

	var color = Color(1, 1, 1);
	match new_state:
		GLOW_STATE.BLUE_PULSE: color = Color(0.16, 0.45, 0.98) if dark_background else Color(0.1, 0.3, 1);
		GLOW_STATE.BLUE_READY: color = Color(0.16, 0.45, 0.98) if dark_background else Color(0.1, 0.3, 1);
		GLOW_STATE.RED: color = Color(1, 0, 0);

	
	tween.interpolate_property(glow, "material/0:albedo_color", 
		glow.get_surface_material(0).albedo_color, color, 0.5, 
		Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		
	tween.start();
	if (new_state == GLOW_STATE.BLUE_PULSE):
		animation.get_animation("Pulse").loop = true;
		animation.play("Pulse");
		if wasOff: animation.seek(0.5);
	else:
		animation.get_animation("Pulse").loop = false;

func set_dark_background(is_dark):
	dark_background = is_dark

func on_tween_completed(object: Object, key_path: NodePath):
	if not is_shown:
		hide();
