extends GridMap


export (Vector3) var effect_epicenter = Vector3(4, 0, 0)
export (Vector3) var grid_size = Vector3(45, 0, 40)

export (bool) var active
export (bool) var color
export (float) var sync_time


export (int) var max_wave_size = 2
export (int) var wave_trail_size = 2
export (int) var wave_front_size = 2
export (int) var wave_diminish_distance = 2



var LARGE_CIRCLE_INDEX = 2
var LARGE_FADED_CIRCLE_INDEX = 5
var MEDIUM_CIRCLE_INDEX = 1
var MEDIUM_FADED_CIRCLE_INDEX = 3
var SMALL_CIRCLE_INDEX = 0
var SMALL_FADED_CIRCLE_INDEX = 4


var animationTimerS = 0
var timer
var blockStep = 0


func _ready() -> void :
	
	createEffectGrid(cell_scale, blockStep)
	pass


func createEffectGrid(scale: float, blockStep: int) -> void :
	clear()
	set_cell_scale(scale)
	
	if blockStep == 0:
		return
	
	var diminishWave = blockStep >= wave_diminish_distance
	var waveSize = max_wave_size
	var waveMinTrailSize = wave_trail_size
	var waveMaxFrontSize = wave_front_size
	
	if diminishWave:
		waveSize /= 2
		waveMinTrailSize /= 2
	
	var waveBound = max(blockStep - waveSize, 0)
	var waveMinTrail = max(waveBound - waveMinTrailSize, 0)
	var waveMaxTrail = blockStep + waveMaxFrontSize / 2
	
	
	var hyp = sqrt(pow(blockStep, 2) + pow(blockStep, 2))
	var waveFrontHyp = sqrt(pow(waveMaxTrail, 2) + pow(waveMaxTrail, 2))
	
	var xBlocks = (0 if cell_size.x == 0 else grid_size.x / cell_size.x)
	var zBlocks = (0 if cell_size.z == 0 else grid_size.z / cell_size.z)
	for x in range(xBlocks):
		for z in range(zBlocks):
			var dx = abs(effect_epicenter.x - x)
			var dz = abs(effect_epicenter.z - z)
			
			if effect_epicenter.x == x and effect_epicenter.z == z:
				set_cell_item(x, 0, z, MEDIUM_CIRCLE_INDEX)
			
			elif ((dx <= blockStep and dx > waveBound) or (dz <= blockStep and dz > waveBound)) and (sqrt(pow(dx, 2) + pow(dz, 2)) <= hyp):
				if diminishWave:
					set_cell_item(x, 0, z, MEDIUM_FADED_CIRCLE_INDEX)
				else:
					set_cell_item(x, 0, z, MEDIUM_CIRCLE_INDEX)
			
			elif ((dx <= waveBound and dx > waveMinTrail) or (dz <= waveBound and dz > waveMinTrail)) and (sqrt(pow(dx, 2) + pow(dz, 2)) <= hyp):
				if diminishWave:
					set_cell_item(x, 0, z, SMALL_CIRCLE_INDEX)
				else:
					set_cell_item(x, 0, z, MEDIUM_FADED_CIRCLE_INDEX)
			
			elif ((dx <= waveMaxTrail and dx > blockStep) or (dz <= waveMaxTrail and dz > blockStep)) and (sqrt(pow(dx, 2) + pow(dz, 2)) <= waveFrontHyp):
				if diminishWave:
					set_cell_item(x, 0, z, SMALL_CIRCLE_INDEX)
				else:
					set_cell_item(x, 0, z, MEDIUM_FADED_CIRCLE_INDEX)



const cycles_per_second = 0.9 * 1.2375
var oldDivisions = 0


func _process(delta) -> void :
	
	if not active:
		animationTimerS = 0
		return
	
	var currentTimeMS = OS.get_ticks_msec()
	var timeElapsedMS = currentTimeMS
	var numDivisions = floor(timeElapsedMS / (cycles_per_second * 1000))
	
	
	var xBlocks = (0 if cell_size.x == 0 else grid_size.x / cell_size.x)
	var zBlocks = (0 if cell_size.z == 0 else grid_size.z / cell_size.z)
	var totalSteps = max(abs(xBlocks - effect_epicenter.x), abs(zBlocks - effect_epicenter.z))
	
	
	var animationSpeedX = 2.5
	var stepTimeS = cycles_per_second / totalSteps / animationSpeedX
	
	
	if numDivisions > oldDivisions:
		animationTimerS += delta
		if animationTimerS > stepTimeS:
			blockStep += 1
			
			if blockStep > totalSteps:
				blockStep = 0
				oldDivisions = numDivisions
			createEffectGrid(cell_scale, blockStep)
			
			
			animationTimerS = 0
