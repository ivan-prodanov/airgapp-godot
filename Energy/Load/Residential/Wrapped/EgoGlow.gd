extends MeshInstance


export var time = 0.0
export var frequency = 1.0
export var amplitude = 1.0
export var falloff_minimum = 0.32
export var falloff_maximum = 0.52

func _process(delta):
	time += delta
	
	var sine_value = rad2deg(sin(2.0 * PI * frequency * time) * amplitude) / 2.71828
	
	var falloff = remap_value(sine_value, - 1, 1, falloff_minimum, falloff_maximum)
	self.get_surface_material(0).set_shader_param("falloff", falloff)

func remap_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	if from_max - from_min != 0:
		return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
	else: return 0.0
