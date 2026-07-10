tool 
extends "res://Ego/Bayberry/Script/Bayberry.gd"

func get_roof_fade_resource_names():
	return ["GlassTopFade", 
			"GlassSkyboxFade", 
			"Cover_Fade", 
			"Trim_Fade", 
			"Interior_Fade", 
			"Glass_Trunk_Interior_Fade", 
			"Metal_Fade", 
			"Paint_Rough_Fade", 
			"PaintFade"]

func get_skin_file_path(skin_name):
	return "res://" + local_dir + "/Textures/Skins/" + skin_name + ".png"
