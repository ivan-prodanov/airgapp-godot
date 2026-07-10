extends Line2D

onready var label: EnergyLabel = get_parent()


func update_position(below: bool):
	var padding = label.get_specification("padding_vertical")
	var line_text_gap = 5
	
	
	var label_center_x = label.rect_position[0] + label.rect_size[0] / 2
	var reference_point = label.reference_point
	
	if below:
		
		var top_offset = padding - line_text_gap
		set_point_position_global(0, Vector2(label_center_x, label.rect_position[1] + top_offset))
		set_point_position_global(1, Vector2(label_center_x, reference_point[1]))
		set_point_position_global(2, Vector2(label_center_x, reference_point[1]))
	else:
		
		var bottom_offset = label.rect_size[1] - padding + line_text_gap
		set_point_position_global(0, Vector2(label_center_x, label.rect_position[1] + bottom_offset))
		set_point_position_global(1, Vector2(label_center_x, reference_point[1]))
		set_point_position_global(2, Vector2(label_center_x, reference_point[1]))


func set_point_position_global(index: int, position: Vector2):
	if width < 1.5:
		position[0] += 0.5
		
	points[index] = position - label.rect_position
	
	
func set_pixel_ratio(pixel_ratio: float):
	set_width(EnergyLabel.SPECIFICATIONS.get("line_width") * pixel_ratio)
