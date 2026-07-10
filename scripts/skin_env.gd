tool 
class_name SkinEnv
extends Resource
	
export (Color, RGB) var background_color = Color("#eeeeee") setget set_bgcolor
func set_bgcolor(color):
	background_color = color;
	emit_signal("changed");
	
export (float, 0, 20, 0.1) var background_energy_drive = 3.5 setget set_bgenergy_drive;
func set_bgenergy_drive(v):
	background_energy_drive = v;
	emit_signal("changed");
	
export (float, 0, 20, 0.1) var background_energy_park = 3.5 setget set_bgenergy_park;
func set_bgenergy_park(v):
	background_energy_park = v;
	emit_signal("changed");
	
export (float, 0, 20, 0.1) var background_ambient_drive = 2 setget set_bgambient_drive;
func set_bgambient_drive(v):
	background_ambient_drive = v;
	emit_signal("changed");
	
export (float, 0, 20, 0.1) var background_ambient_park = 2 setget set_bgambient_park;
func set_bgambient_park(v):
	background_ambient_park = v;
	emit_signal("changed");
	
export (Vector3) var background_rotation_drive = Vector3(0, - 5, 0) setget set_background_rotation_drive;
func set_background_rotation_drive(v):
	background_rotation_drive = v;
	emit_signal("changed");
	
export (Vector3) var background_rotation_park = Vector3(0, - 5, 0) setget set_background_rotation_park;
func set_background_rotation_park(v):
	background_rotation_park = v;
	emit_signal("changed");

export (Texture) var panorama setget set_panorama
func set_panorama(v):
	panorama = v;
	emit_signal("changed");

export (int) var panorama_radiance_size = Sky.RADIANCE_SIZE_512 setget set_panorama_radiance_size
func set_panorama_radiance_size(v):
	panorama_radiance_size = v;
	emit_signal("changed");

export (CubeMap) var skybox setget set_skybox
func set_skybox(v):
	skybox = v;
	emit_signal("changed");
	
export (float, 0, 10) var skybox_intensity setget set_skybox_intensity
func set_skybox_intensity(v):
	skybox_intensity = v;
	emit_signal("changed");
