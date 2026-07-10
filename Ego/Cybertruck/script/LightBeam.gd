tool 
extends MeshInstance

var glow_materials: Array = []
var beam_material: SpatialMaterial = null
export (float) var beam_alpha = 1.0 setget set_alpha

func _ready():
	for glow in get_children():
		glow_materials.append(glow.get_surface_material(0))
		
	beam_material = mesh.surface_get_material(0)

func set_alpha(alpha: float):
	if beam_alpha == alpha: return
	beam_alpha = alpha
	
	var beam_albedo = beam_material.get_albedo()
	beam_albedo.a = alpha
	beam_material.set_albedo(beam_albedo)
	
	for glow_mat in glow_materials:
		var glow_albedo = glow_mat.get_shader_param("albedo")
		glow_albedo.a = alpha
		glow_mat.set_shader_param("albedo", glow_albedo)
