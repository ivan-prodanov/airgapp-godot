extends Spatial

onready var theme_manager: ThemeManager = get_node("/root/Mobile/ThemeManager") as ThemeManager
export (NodePath) var generator_path: NodePath
onready var generator: MeshInstance = get_node(generator_path)

onready var themeParams = {
	theme_manager.ThemeType.LIGHT: {
		"albedo": Color8(50, 50, 50), 
	}, 
	theme_manager.ThemeType.DARK: {
		"albedo": Color8(13, 13, 13), 
	}
}

func _ready():
	theme_manager.connect("set_app_theme", self, "updateThemeParams")
	updateThemeParams(theme_manager.app_theme)

func updateThemeParams(theme):
	var theme_params = themeParams[theme]
	if (generator == null): return
	var generatorMaterial = generator.mesh.surface_get_material(0)
	if (generatorMaterial == null): return
	generatorMaterial.set_albedo(theme_params["albedo"])
