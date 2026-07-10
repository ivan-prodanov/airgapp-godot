tool 
class_name SkinColors
extends Resource

export (Vector3) var matcap_mul = Vector3(1, 1, 1) setget set_matcap_mul;
func set_matcap_mul(v):
	matcap_mul = v;
	update_skin();

export (Vector3) var matcap_tint = Vector3(0, 0, 0) setget set_matcap_tint;
func set_matcap_tint(v):
	matcap_tint = v;
	update_skin();

export (float, 0, 25, 0.001) var surround_obj_light_intensity = 20 setget set_surround_obj_light_intensity;
func set_surround_obj_light_intensity(v):
	surround_obj_light_intensity = v;
	update_skin();

export (float, 0, 1, 0.001) var surround_obj_light_ambient = 0.3 setget set_surround_obj_light_ambient;
func set_surround_obj_light_ambient(v):
	surround_obj_light_ambient = v;
	update_skin();
	
	
export (Vector3) var surround_obj_control_tint = Vector3(1, 1, 1) setget set_surround_obj_control_tint
func set_surround_obj_control_tint(color):
	surround_obj_control_tint = color;
	update_skin();
	
export (Vector3) var surround_obj_warning_tint = Vector3(1, 1, 1) setget set_surround_obj_warning_tint
func set_surround_obj_warning_tint(color):
	surround_obj_warning_tint = color;
	update_skin();

export (Color, RGBA) var lane_line_disengaged = Color(0.2, 0.2, 0.2, 0.2) setget set_lane_line_disengaged
func set_lane_line_disengaged(color):
	lane_line_disengaged = color;
	update_skin();

export (Color, RGBA) var lane_line_unavailable = Color(0.06, 0.06, 0.06, 0.06) setget set_lane_line_unavailable
func set_lane_line_unavailable(color):
	lane_line_unavailable = color;
	update_skin();
	
export (Color, RGBA) var stop_line = Color("#cccccc") setget set_stop_line
func set_stop_line(color):
	stop_line = color;
	update_skin();
	
export (Color, RGBA) var don_desired_spline = Color(0.3, 0.3, 0.3, 0.3) setget set_don_desired_spline
func set_don_desired_spline(color):
	don_desired_spline = color;
	update_skin();
	
	
export (Color, RGBA) var autopilot_blue = Color("#006CFF") setget set_autopilot_blue
func set_autopilot_blue(color):
	autopilot_blue = color;
	update_skin();
	
export (Color, RGBA) var construction = Color(1.0, 0.5, 0.0, 1.0) setget set_construction
func set_construction(color):
	construction = color;
	update_skin();

	
export (Color, RGBA) var lane_line_warning = Color("#ED4E3B") setget set_lane_line_warning
func set_lane_line_warning(color):
	lane_line_warning = color;
	update_skin();

export (Color, RGBA) var eu_sign_content = Color("#000000") setget set_eu_sign_content
func set_eu_sign_content(color):
	eu_sign_content = color;
	update_skin();
	
export (Color, RGBA) var us_sign_content = Color("#000000") setget set_us_sign_content
func set_us_sign_content(color):
	us_sign_content = color;
	update_skin();
	
export (Color, RGBA) var sign_white_text = Color("#fdfdfd") setget set_sign_white_text
func set_sign_white_text(color):
	sign_white_text = color;
	update_skin();
	
export (Color, RGBA) var bev_roadway = Color("#eeeeee") setget set_bev_roadway
func set_bev_roadway(color):
	bev_roadway = color;
	update_skin();
	
export (Color, RGBA) var bev_roadway_ao = Color("#eeeeee") setget set_bev_roadway_ao
func set_bev_roadway_ao(color):
	bev_roadway_ao = color;
	update_skin();
	
export (Color, RGBA) var bev_curb_top = Color("#eeeeee") setget set_bev_curb_top
func set_bev_curb_top(color):
	bev_curb_top = color;
	update_skin();

export (Color, RGBA) var bev_curb_side = Color("#eeeeee") setget set_bev_curb_side
func set_bev_curb_side(color):
	bev_curb_side = color;
	update_skin();
	
export (Color, RGBA) var bev_curb_outter = Color("#eeeeee") setget set_bev_curb_outter
func set_bev_curb_outter(color):
	bev_curb_outter = color;
	update_skin();
	
export (Color, RGBA) var bev_line_paint = Color("#eeeeee") setget set_bev_line_paint
func set_bev_line_paint(color):
	bev_line_paint = color;
	update_skin();
	
export (Color, RGBA) var bev_point_edge = Color("#111111") setget set_bev_point_edge
func set_bev_point_edge(color):
	bev_point_edge = color;
	update_skin();
	
export (Color, RGBA) var bev_point_divider = Color("#111111") setget set_bev_point_divider
func set_bev_point_divider(color):
	bev_point_divider = color;
	update_skin();
	
export (Color, RGBA) var bev_yellow_line_paint = Color("#eeee00") setget set_bev_yellow_line_paint
func set_bev_yellow_line_paint(color):
	bev_yellow_line_paint = color;
	update_skin();
	
export (Color, RGBA) var bev_edge_divider = Color("#eeeeee") setget set_bev_edge_divider
func set_bev_edge_divider(color):
	bev_edge_divider = color;
	update_skin();
	
export (Color, RGBA) var bev_edge_island = Color("#eeeeee") setget set_bev_edge_island
func set_bev_edge_island(color):
	bev_edge_island = color;
	update_skin();

export (Color, RGBA) var voxel_bottom_layer = Color("#eeeeee") setget set_voxel_bottom_layer
func set_voxel_bottom_layer(color):
	voxel_bottom_layer = color;
	update_skin();
	
export (Color, RGBA) var voxel_top_layer = Color("#eeeeee") setget set_voxel_top_layer
func set_voxel_top_layer(color):
	voxel_top_layer = color;
	update_skin();

export (Color, RGBA) var bev_cloud = Color("#eeeeee") setget set_bev_cloud
func set_bev_cloud(color):
	bev_cloud = color;
	update_skin();


func update_skin():
	emit_signal("changed");

export (float, 0, 2, 0.1) var traffic_light_bulb_energy = 1 setget set_traffic_light_bulb_energy;
func set_traffic_light_bulb_energy(v):
	traffic_light_bulb_energy = v;
	update_skin();
	
export (float, 0, 1, 0.01) var projected_headlight_intensity = 1;
