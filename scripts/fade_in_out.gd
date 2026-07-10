tool 
extends MeshInstance

export (bool) var show_fade setget set_show_fade

func set_show_fade(v):
	if v != show_fade:
		show_fade = v;
		if v: fadeIn()
		else: fadeOut();

var alpha = 0;

func _ready():
	var tween = get_node("Tween");
	tween.connect("tween_completed", self, "on_tween_completed")
	get_surface_material(0).albedo_color.a = alpha;
			
	if (alpha > 0.01):
		show();
	else:
		hide();

func fadeIn():
	alpha = 1;
	update();

func fadeOut():
	alpha = 0;
	update();

func update():
	var tween = get_node("Tween");
	
	if (alpha > 0.01):
		show();

	tween.interpolate_property(self, "material/0:albedo_color:a", 
		get_surface_material(0).albedo_color.a, alpha, 0.5, 
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)

	tween.start()

func on_tween_completed(object: Object, key_path: NodePath):
	if (alpha < 0.01):
		hide();
