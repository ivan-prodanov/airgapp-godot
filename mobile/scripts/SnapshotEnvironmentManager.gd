tool 
extends WorldEnvironment

export (Texture) var default_skybox_vehicle: Texture
export (Texture) var cyber_skybox_vehicle: Texture

const DEFAULT_ENV_ROTATION: Vector3 = Vector3.ZERO
const DEFAULT_ENV_ENERGY: float = 6.0
const DEFAULT_ENV_AMBIENT: float = 2.5

func prepare_for_pos(pose_settings, model_key):
	environment.background_sky_rotation_degrees = pose_settings.get("env_rotation", DEFAULT_ENV_ROTATION)
	environment.ambient_light_energy = pose_settings.get("env_ambient", DEFAULT_ENV_AMBIENT)
	environment.background_energy = pose_settings.get("env_energy", DEFAULT_ENV_ENERGY)
		
	match model_key:
		"cybertruck":
			environment.background_sky.panorama = cyber_skybox_vehicle
		_:
			environment.background_sky.panorama = default_skybox_vehicle
