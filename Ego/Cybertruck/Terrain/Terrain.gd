tool 
class_name Terrain
extends Node

const TerrainConfig = preload("res://Ego/Cybertruck/Terrain/TerrainConfig.gd")

export (NodePath) var terrain_path: NodePath
export (bool) var use_mobile_material setget set_use_mobile_material

onready var terrain: MeshInstance = get_node_or_null(terrain_path)

export (NodePath) var day_config_path: NodePath
export (NodePath) var day_dark_config_path: NodePath
export (NodePath) var night_config_path: NodePath
export (NodePath) var mars_config_path: NodePath
export (NodePath) var mobile_config_path: NodePath

onready var day_config: Node = get_node_or_null(day_config_path)
onready var day_dark_config: Node = get_node_or_null(day_dark_config_path)
onready var night_config: Node = get_node_or_null(night_config_path)
onready var mars_config: Node = get_node_or_null(mars_config_path)
onready var mobile_config: Node = get_node_or_null(mobile_config_path)

export (bool) var day_mode = false setget set_day_mode;
export (bool) var solar_angle_day_mode = false setget set_solar_angle_day_mode;
export (bool) var mars_mode = false setget set_mars_mode;


var LOADING_ANIMATION_DURATION: float = 0.1

func set_use_mobile_material(use_mobile: bool):
	if not terrain: return
	use_mobile_material = use_mobile
	if use_mobile:
		apply_config(mobile_config)

func fade_terrain_material(fade_out: bool, tween: Tween):
	var material = terrain.get_surface_material(0) if terrain else null
	if not material: return
	if tween == null: return
	tween.interpolate_property(
		material, 
		"shader_param/cyber_terrain_fade_in", 
		material.get_shader_param("cyber_terrain_fade_in"), 
		0 if fade_out else 1, 
		LOADING_ANIMATION_DURATION, 
		Tween.TRANS_QUINT, 
		Tween.EASE_OUT, 
		LOADING_ANIMATION_DURATION)
	tween.start()
	
func get_appropriate_config():
	if mars_mode:
		return mars_config
	elif day_mode:
		return day_config
	elif solar_angle_day_mode:
		return day_dark_config
	else:
		return night_config

func apply_config(config: TerrainConfig):
	var material = terrain.get_surface_material(0) if terrain else null
	if not material: return
	material.set_shader_param("color", config.color)
	material.set_shader_param("roughness", config.roughness)
	material.set_shader_param("metallic", config.metallic)
	material.set_shader_param("ao_light_affect", config.ao_light_affect)
	material.set_shader_param("color_map_factor", config.color_map_factor)
	material.set_shader_param("color_map_flat_factor", config.color_map_flat_factor)
	material.set_shader_param("distance_dim_factor", config.distance_dim_factor)
	
	print(config.color_map_factor)

func update_terrain_config():
	apply_config(get_appropriate_config())
	
func set_day_mode(new_day_mode):
	if day_mode == new_day_mode: return
	day_mode = new_day_mode
	update_terrain_config()
	
func set_solar_angle_day_mode(new_day_mode):
	if solar_angle_day_mode == new_day_mode: return
	solar_angle_day_mode = new_day_mode
	update_terrain_config()
	
func set_mars_mode(new_mars_mode):
	if mars_mode == new_mars_mode: return
	mars_mode = new_mars_mode
	update_terrain_config()
