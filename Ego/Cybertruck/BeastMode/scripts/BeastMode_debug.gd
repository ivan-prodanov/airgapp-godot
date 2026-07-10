extends Spatial

var accKeyDown = false
var brakeKeyDown = false
var cheetahStanceDown = false


onready var beastMode = $BeastMode
onready var camera = $Camera
onready var tween = $Tween

func _ready():
	ProjectSettings.set_setting("display/window/size/width", 1920);
	ProjectSettings.set_setting("display/window/size/height", 720);
	ProjectSettings.save();

func _input(ev):
	
	if Input.is_key_pressed(KEY_K):
		if ( not accKeyDown):
			accKeyDown = true
			onKeyUpdate()
		
	if not Input.is_key_pressed(KEY_K):
		if (accKeyDown):
			accKeyDown = false
			onKeyUpdate()
			
	if Input.is_key_pressed(KEY_J):
		if ( not brakeKeyDown):
			brakeKeyDown = true
			onKeyUpdate()
		
	if not Input.is_key_pressed(KEY_J):
		if (brakeKeyDown):
			brakeKeyDown = false
			onKeyUpdate()
			
	if Input.is_key_pressed(KEY_S):
		if ( not cheetahStanceDown):
			cheetahStanceDown = true
			onKeyUpdate()
			
	if not Input.is_key_pressed(KEY_S):
		if (cheetahStanceDown):
			cheetahStanceDown = false
			onKeyUpdate()
		
func onKeyUpdate():
	if ( not beastMode.isPrimed):
		if (accKeyDown and brakeKeyDown):
			beastMode.prime()
			
			tween.interpolate_property($Camera, "translation", 
				$Camera.translation, Vector3(0, 2, 14), 4, 
				Tween.TRANS_CUBIC, Tween.EASE_OUT)
			
			tween.interpolate_property($Camera, "rotation_degrees", 
				$Camera.rotation_degrees, Vector3( - 1, 0, 0), 4, 
				Tween.TRANS_CUBIC, Tween.EASE_OUT)
				
			tween.interpolate_property($Camera, "fov", 
				$Camera.fov, 40, 4, 
				Tween.TRANS_CUBIC, Tween.EASE_OUT)
			tween.start()
			
	else:
		if (cheetahStanceDown):
			beastMode.cheetah_stance_ready()
		
		if (accKeyDown and not brakeKeyDown and not beastMode.isLaunched):
			beastMode.go()
			
			tween.stop($Camera, "translation")
			tween.stop($Camera, "rotation_degrees")
			tween.stop($Camera, "fov")
			
			tween.interpolate_property($Camera, "translation", 
				$Camera.translation, Vector3(0, 2.5, 8), 1, 
				Tween.TRANS_EXPO, Tween.EASE_OUT, 0.3)
				
			tween.interpolate_property($Camera, "rotation_degrees", 
				$Camera.rotation_degrees, Vector3( - 1, 0, 0), 4, 
				Tween.TRANS_CUBIC, Tween.EASE_OUT)
				
			tween.interpolate_property($Camera, "fov", 
				$Camera.fov, 55, 1, 
				Tween.TRANS_EXPO, Tween.EASE_OUT, 0.3)
			tween.start()
			
		if ( not accKeyDown and not brakeKeyDown):
			beastMode.stop()
			
			var duration = 4
			var delay = 0.3
			if ( not beastMode.isLaunched):
				delay = 0
				duration = 2
			
			tween.interpolate_property($Camera, "translation", 
				$Camera.translation, Vector3(0, 4, 14), duration, 
				Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, delay)
				
			tween.interpolate_property($Camera, "rotation_degrees", 
				$Camera.rotation_degrees, Vector3( - 7, 0, 0), duration, 
				Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, delay)
				
			tween.interpolate_property($Camera, "fov", 
				$Camera.fov, 40, duration, 
				Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, delay)
			tween.start()

