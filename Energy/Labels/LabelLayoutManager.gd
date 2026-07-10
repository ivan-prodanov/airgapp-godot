extends Node

const EnergySiteData = preload("res://mobile/scripts/data/EnergySiteData.gd")

onready var app_config_manager: AppConfigManager = get_node("/root/Mobile/AppConfigManager") as AppConfigManager
export (String, FILE, "*.tscn") var residential_compound_energy_site_path: String = "res://Energy/Load/Residential/Compound/ResidentialCompound.tscn"
export (String, FILE, "*.tscn") var residential_modern_energy_site_path: String = "res://Energy/Load/Residential/Modern/ResidentialPowershare.tscn"
onready var toggle_mobile_view_node = get_node_or_null("/root/Mobile/Inspector/Panel/Container/TabContainer/Energy/MarginContainer/EnergySiteController/ToggleMobileView")

var label_dictionary = {}
onready var mobile_view_active = false


export var frame_padding = Vector2(8, 16)


export var label_separation = Vector2(12, 8)


export var vertical_align_tolerance = 16


export var minimum_line_length = 14
export var constant_line_offset = 80


export var editor_bottom_offset = 50

var viewport_offset = Vector2(0, 0)
var viewport_size = Vector2(1080, 1080)
var viewport_scale = 1
var start_of_viewport = 0
var offscreen_index_below = 0
var offscreen_index_above = 0
export var stacked_labels_below = []
export var stacked_labels_above = []


var cached_container = null

var layout_dirty = true

func _ready():
	
	
	
	process_priority = 2
	if toggle_mobile_view_node != null:
		toggle_mobile_view_node.connect("toggle_mobile_view", self, "on_toggle_mobile_view")
	
	cached_container = find_parent("MainViewContainer")



func add_label(label: EnergyLabel):
	if label.identifier.length() == 0: return
	label_dictionary[label.identifier] = label
	layout_dirty = true
	
func remove_label(label: EnergyLabel):
	if label_dictionary.has(label.identifier) and label_dictionary[label.identifier].get_instance_id() != label.get_instance_id():
		return

	label_dictionary.erase(label.identifier)
	layout_dirty = true
	
func _process(_delta):
	if layout_dirty:
		layout_labels()
		layout_dirty = false
	
	
	for label in label_dictionary.values():
		if label.is_dirty:
			layout_dirty = true
			break

func layout_labels():
	var pixel_ratio = app_config_manager.pixel_ratio
	var energy_site = get_parent()
	
	
	
	var is_classic = false
	if energy_site and energy_site.data:
		is_classic = energy_site.data.get_site_variant() == EnergySiteData.EnergySiteType.RESIDENTIAL_CLASSIC
		
	if cached_container == null:
		cached_container = find_parent("MainViewContainer")
	
	
	
	if cached_container != null and not cached_container.container_size.is_equal_approx(Vector2(1, 1)):
		viewport_size = cached_container.container_size
		viewport_offset = cached_container.container_offset
	
	
	var frame_padding_px = frame_padding * pixel_ratio
	var label_separation_px = pixel_ratio * label_separation
	var vertical_align_tolerance_px = pixel_ratio * vertical_align_tolerance
	var constant_line_offset_px = constant_line_offset * pixel_ratio
	var editor_offset_px = editor_bottom_offset * pixel_ratio
	
	var start_of_viewport_local = viewport_offset[0] + frame_padding_px[0]
	var end_of_viewport = viewport_offset[0] + viewport_size[0] - frame_padding_px[0]
	var top_of_viewport = viewport_offset[1] + frame_padding_px[1]
	var bottom_of_viewport = viewport_size[1] + viewport_offset[1] - frame_padding_px[1]
	
	start_of_viewport = start_of_viewport_local
	
	var energy_site_path = energy_site.get_energy_site_path()
	match energy_site_path:
		residential_compound_energy_site_path:
			layout_label_identifiers_into_row(false, ["solar", "load", "vehicle_1"], frame_padding_px, label_separation_px, vertical_align_tolerance_px, constant_line_offset_px, editor_offset_px, start_of_viewport_local, end_of_viewport, top_of_viewport, bottom_of_viewport, is_classic)
			layout_label_identifiers_into_row(true, ["battery", "grid", "generator", "vehicle_2"], frame_padding_px, label_separation_px, vertical_align_tolerance_px, constant_line_offset_px, editor_offset_px, start_of_viewport_local, end_of_viewport, top_of_viewport, bottom_of_viewport, is_classic)
		residential_modern_energy_site_path:
			layout_label_identifiers_into_row(false, ["load", "solar", "vehicle_1"], frame_padding_px, label_separation_px, vertical_align_tolerance_px, constant_line_offset_px, editor_offset_px, start_of_viewport_local, end_of_viewport, top_of_viewport, bottom_of_viewport, is_classic)
			layout_label_identifiers_into_row(true, ["grid", "battery", "generator", "vehicle_2"], frame_padding_px, label_separation_px, vertical_align_tolerance_px, constant_line_offset_px, editor_offset_px, start_of_viewport_local, end_of_viewport, top_of_viewport, bottom_of_viewport, is_classic)
		_:
			layout_label_identifiers_into_row(false, ["vehicle_2", "vehicle_1", "solar", "load"], frame_padding_px, label_separation_px, vertical_align_tolerance_px, constant_line_offset_px, editor_offset_px, start_of_viewport_local, end_of_viewport, top_of_viewport, bottom_of_viewport, is_classic)
			layout_label_identifiers_into_row(true, ["battery", "generator", "grid"], frame_padding_px, label_separation_px, vertical_align_tolerance_px, constant_line_offset_px, editor_offset_px, start_of_viewport_local, end_of_viewport, top_of_viewport, bottom_of_viewport, is_classic)


func layout_label_identifiers_into_row(below: bool, label_identifiers: Array, frame_padding_px: Vector2, label_separation_px: Vector2, vertical_align_tolerance_px: float, constant_line_offset_px: float, editor_offset_px: float, start_of_viewport_local: float, end_of_viewport: float, top_of_viewport: float, bottom_of_viewport: float, is_classic: bool):
	var labels = []
	
	for identifier in label_identifiers:
		var label = label_dictionary.get(identifier)
		if label and label.show_label:
			labels.append(label)
		
	layout_labels_into_row(below, labels, frame_padding_px, label_separation_px, vertical_align_tolerance_px, constant_line_offset_px, editor_offset_px, start_of_viewport_local, end_of_viewport, top_of_viewport, bottom_of_viewport, is_classic)



func layout_labels_into_row(below: bool, labels: Array, frame_padding_px: Vector2, label_separation_px: Vector2, vertical_align_tolerance_px: float, constant_line_offset_px: float, editor_offset_px: float, start_of_viewport_local: float, end_of_viewport: float, top_of_viewport: float, bottom_of_viewport: float, is_classic: bool):
	if labels.size() == 0: return
	
	
	for label in labels:
		label.update_label_position()
		
		
		if below:
			label.rect_position[1] = bottom_of_viewport - label.rect_size[1]
		else:
			label.rect_position[1] = label.reference_point[1] - label.rect_size[1] - constant_line_offset_px

		







		
		
		label.rect_position[0] = label.reference_point[0] - label.rect_size[0] * 0.5
		label.rect_position[0] = min(end_of_viewport - label.rect_size[0], label.rect_position[0])
		label.rect_position[1] = clamp(label.rect_position[1], top_of_viewport, bottom_of_viewport - label.rect_size[1])
	
	
	var stacked_labels_below_dict = {}
	var stacked_labels_above_dict = {}
	
	
	if not is_classic:
		var last_overlapped = false
		
		for i in range(labels.size() - 1, - 1, - 1):
			if i == labels.size() - 1:
				continue
			
			var label = labels[i]
			var right_label = labels[i + 1]
			var right_edge_of_current_label = label.rect_position[0] + label.rect_size[0]
			
			
			if right_edge_of_current_label + label_separation_px[0] > right_label.rect_position[0]:
				
				if last_overlapped:
					last_overlapped = true
					continue
				
				last_overlapped = true
				
				
				var vertical_clear_position = right_label.rect_position[1] - label.rect_size[1] - label_separation_px[1]
				
				
				var can_move_vertically = (vertical_clear_position >= top_of_viewport) and (vertical_clear_position + label.rect_size[1] <= bottom_of_viewport)
				
				if can_move_vertically:
					
					label.rect_position[1] = vertical_clear_position
				else:
					if label.is_off_screen:
						if below:
							if not stacked_labels_below_dict.has(label):
								stacked_labels_below.append(label)
								stacked_labels_below_dict[label] = true
								offscreen_index_below += 1
							label.rect_position[1] -= (label.rect_size[1] * offscreen_index_below)
						else:
							if not stacked_labels_above_dict.has(label):
								stacked_labels_above.append(label)
								stacked_labels_above_dict[label] = true
								offscreen_index_above += 1
							label.rect_position[1] += (label.rect_size[1] * offscreen_index_above)
						label.rect_position[0] = start_of_viewport_local + label_separation_px[0]
					else:
						label.rect_position[0] = min(right_label.rect_position[0] - label.rect_size[0] - label_separation_px[0], label.reference_point[0])
				
				if not label.is_off_screen:
					var vertical_difference = abs(label.rect_position[1] - right_label.rect_position[1])
					if vertical_difference < vertical_align_tolerance_px * 2:
						var alignment = inverse_lerp(vertical_align_tolerance_px * 2, vertical_align_tolerance_px, vertical_difference)
						alignment = smoothstep(0, 1, alignment)
						label.rect_position[1] = lerp(label.rect_position[1], right_label.rect_position[1], alignment)
			else:
				last_overlapped = false
	
	for label in labels:
		label.update_line(below)
		label.layout_ready = true
	
func get_start_of_viewport():
	return start_of_viewport
	
func clear_vertical_stack_list():
	stacked_labels_above.clear()
	stacked_labels_above.clear()
	offscreen_index_above = 0
	offscreen_index_below = 0
	
func on_toggle_mobile_view():
	mobile_view_active = not mobile_view_active
	layout_dirty = true
	
