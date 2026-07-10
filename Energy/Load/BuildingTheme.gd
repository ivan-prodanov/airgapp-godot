extends MeshInstance



onready var theme_manager: ThemeManager = get_node("/root/Mobile/ThemeManager") as ThemeManager

func _ready():
	make_material_unique()

	if theme_manager != null:
		theme_manager.connect("set_app_theme", self, "update_theme")
		update_theme(theme_manager.app_theme)

func make_material_unique():
	set_surface_material(0, get_material().duplicate());

func get_material():
	return get_surface_material(0)

func update_theme(theme):
	print("Updating theme to %s" % theme)
	get_material().set_shader_param("theme", 1.0 if theme == ThemeManager.ThemeType.LIGHT else 0.0)
