tool 
extends Spatial

const ColorToHighlightMap: Dictionary = {
	"RedMulticoat": Color("#f13d3d"), 
	"SolidBlack": Color("#6d6d6d"), 
	"SilverMetallic": Color("#c1c1c1"), 
	"MidnightSilver": Color("#999ea9"), 
	"DeepBlue": Color("#1667ee"), 
	"PearlWhite": Color("#dadada"), 
	"MidnightCherryRed": Color("#eb4b69"), 
	"Quicksilver": Color("#d0d9f7"), 
	"UltraRed": Color("#f03042"), 
	"StealthGrey": Color("#929ba7"), 
	"GlacierBlue": Color("#42599c"), 
	"DiamondBlack": Color("#6d6d6d"), 
	"SilkroadSilver": Color("#c1c1c1"), 
	"MarineBlue": Color("#1f4b75")
}


export (NodePath) var viewport_path: NodePath
export (NodePath) var camera_path: NodePath
export (NodePath) var terrain_path: NodePath
export (NodePath) var background_plane_path: NodePath


export (float) var fade: float setget set_fade
export (bool) var day_mode: bool setget set_day_mode
export (bool) var solar_angle_day_mode: bool setget set_solar_angle_day_mode
export (float) var cluster_expand_pct: float setget set_cluster_expand_pct


export (Color) var day_mode_color: Color
export (Vector2) var day_mode_normal_map_range: Vector2
export (float) var day_mode_reflection_strength: float
export (float) var day_mode_floor_effect_on_reflection: float
export (float) var day_mode_highlight_fade: float
export (float) var day_mode_ao: float

export (Color) var solar_angle_day_mode_color: Color
export (Vector2) var solar_angle_day_mode_normal_map_range: Vector2
export (float) var solar_angle_day_mode_reflection_strength: float
export (float) var solar_angle_day_mode_floor_effect_on_reflection: float
export (float) var solar_angle_day_mode_highlight_fade: float
export (float) var solar_angle_day_mode_ao: float

export (Color) var night_mode_color: Color
export (Vector2) var night_mode_normal_map_range: Vector2
export (float) var night_mode_reflection_strength: float
export (float) var night_mode_floor_effect_on_reflection: float
export (float) var night_mode_highlight_fade: float
export (float) var night_mode_ao: float


onready var viewport: Viewport = get_node_or_null(viewport_path)
onready var camera: Camera = get_node_or_null(camera_path)
onready var terrain: MeshInstance = get_node_or_null(terrain_path)
onready var terrain_material: ShaderMaterial = terrain.get_surface_material(0) if terrain else null
onready var background_plane: MeshInstance = get_node_or_null(background_plane_path)
onready var background_plane_material: ShaderMaterial = background_plane.get_surface_material(0) if background_plane else null


var highlight_color
var highlight_fade_from_camera_angle = 1.0
var highlight_fade_from_cluster = 1.0
var highlight_fade_from_day_mode = 1.0


var editor_viewport
var editor_camera_3d

func _process(timestep: float):
	if fade < 0.01:
		return

	var active_camera = editor_camera_3d if Engine.editor_hint else get_viewport().get_camera()
	var active_camera_pos = active_camera.global_transform.origin
	var active_camera_forward = - active_camera.global_transform.basis.z

	camera.global_transform = active_camera.global_transform
	camera.fov = active_camera.fov
	camera.near = active_camera.near
	camera.far = active_camera.far

	var desired_cam_position = active_camera_pos
	desired_cam_position.y = - desired_cam_position.y
	camera.global_transform.origin = desired_cam_position

	var up_vector = Vector3(0.0, 1.0, 0.0)
	var camera_forward = active_camera_forward.reflect(up_vector)
	camera.global_transform.basis.z = camera_forward
	camera.global_transform.basis.y = camera_forward.cross(camera.global_transform.basis.x)

	var inv_camera_transform = camera.global_transform.inverse()
	terrain_material.set_shader_param("inv_camera_matrix", inv_camera_transform.basis)
	terrain_material.set_shader_param("inv_camera_pos", inv_camera_transform.origin)

	var active_viewport = editor_viewport if Engine.editor_hint else get_viewport()
	viewport.size = active_viewport.size
	
	update_highlight_color()
	update_highlight_fade()
	
func get_ego():
	if Engine.editor_hint:
		return get_node_or_null(NodePath("ROOT"))
	elif get_parent() != null:
		return get_parent().get_node_or_null("ego/ROOT")
	
func update_highlight_color():
	var ego = get_ego()
	if ego and background_plane_material:
		var desired_highlight_color
		if ColorToHighlightMap.has(ego.paint_color_name):
			desired_highlight_color = ColorToHighlightMap.get(ego.paint_color_name)
		else:
			var color_array = ego.paint_color_override.split_floats(",")
			if color_array.size() != 5: return
			desired_highlight_color = ego.remap_color(Color(color_array[0] / 255, color_array[1] / 255, color_array[2] / 255, 1.0))
			desired_highlight_color.v = clamp(desired_highlight_color.v * 5.0, 0.0, 0.7)
			
			var min_v = 0.4
			if (desired_highlight_color.v < min_v):
				var min_v_pct = (min_v - desired_highlight_color.v) / min_v
				desired_highlight_color.v += clamp(min_v_pct * 0.5, 0.0, 0.5)
				desired_highlight_color.s *= 1.0 - min_v_pct
		
		if desired_highlight_color != highlight_color:
			highlight_color = desired_highlight_color
			background_plane_material.set_shader_param("albedo", desired_highlight_color)

func update_highlight_fade():
	var active_camera = editor_camera_3d if Engine.editor_hint else get_viewport().get_camera()
	var camera_to_background = (background_plane.global_transform.origin - active_camera.global_transform.origin).normalized()
	var camera_forward = - active_camera.global_transform.basis.z.normalized()
	var forward_dot_dir_to_background = camera_forward.dot(camera_to_background)
	var desired_highlight_fade_from_angle = smoothstep(0.99, 1.0, forward_dot_dir_to_background)
	highlight_fade_from_camera_angle += (desired_highlight_fade_from_angle - highlight_fade_from_camera_angle) * 0.03
	
	apply_highlight_fade()
	
func update_shader_day_mode():
	var color
	var normal_map_range
	var reflection_strength
	var floor_effect_on_reflection
	var highlight_fade
	var ao
	
	if day_mode:
		color = day_mode_color
		normal_map_range = day_mode_normal_map_range
		reflection_strength = day_mode_reflection_strength
		floor_effect_on_reflection = day_mode_floor_effect_on_reflection
		highlight_fade = day_mode_highlight_fade
		ao = day_mode_ao
	elif solar_angle_day_mode:
		color = solar_angle_day_mode_color
		normal_map_range = solar_angle_day_mode_normal_map_range
		reflection_strength = solar_angle_day_mode_reflection_strength
		floor_effect_on_reflection = solar_angle_day_mode_floor_effect_on_reflection
		highlight_fade = solar_angle_day_mode_highlight_fade
		ao = solar_angle_day_mode_ao
	else:
		color = night_mode_color
		normal_map_range = night_mode_normal_map_range
		reflection_strength = night_mode_reflection_strength
		floor_effect_on_reflection = night_mode_floor_effect_on_reflection
		highlight_fade = night_mode_highlight_fade
		ao = night_mode_ao
		
	if terrain_material:
		terrain_material.set_shader_param("albedo", color)
		terrain_material.set_shader_param("normal_map_range", normal_map_range)
		terrain_material.set_shader_param("reflection_strength", reflection_strength)
		terrain_material.set_shader_param("floor_effect_on_reflection", floor_effect_on_reflection)
		terrain_material.set_shader_param("ao_factor", ao)
		
	highlight_fade_from_day_mode = highlight_fade
	apply_highlight_fade()
	
func set_background_visible(visible):
	if not background_plane: return
	
	if visible:
		background_plane.show()
	else:
		background_plane.hide()
	
func set_day_mode(day):
	day_mode = day
	update_shader_day_mode()
	set_background_visible( not day)
	
func set_cluster_expand_pct(expand_pct):
	if cluster_expand_pct == expand_pct: return
	cluster_expand_pct = expand_pct
	
	highlight_fade_from_cluster = expand_pct
	apply_highlight_fade()
	
func set_solar_angle_day_mode(solar_angle_day):
	solar_angle_day_mode = solar_angle_day
	update_shader_day_mode()
	
func compute_highlight_fade():
	return highlight_fade_from_camera_angle * highlight_fade_from_cluster * highlight_fade_from_day_mode * fade
	
func apply_highlight_fade():
	if background_plane_material:
		background_plane_material.set_shader_param("overall_fade", compute_highlight_fade())
	
func set_fade(new_fade):
	fade = new_fade
	if terrain_material:
		terrain_material.set_shader_param("overall_fade", fade)
	apply_highlight_fade()
	if fade < 0.01:
		hide()
	else:
		show()
	
func _ready():
	if Engine.editor_hint:
		editor_viewport = find_editor_viewport_3d(get_node("/root/EditorNode"), 0)
		editor_camera_3d = editor_viewport.get_child(0)

func find_editor_viewport_3d(node: Node, recursive_level):
	if node.get_class() == "SpatialEditor":
		return node.get_child(1).get_child(0).get_child(0).get_child(0).get_child(0).get_child(0)
	else:
		recursive_level += 1
		if recursive_level > 15:
			return null
		for child in node.get_children():
			var result = find_editor_viewport_3d(child, recursive_level)
			if result != null:
				return result
