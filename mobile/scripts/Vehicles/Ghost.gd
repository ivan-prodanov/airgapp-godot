tool 
extends Vehicle

func get_roof_fade_resource_names():
	return []

func set_paint_color(color): pass
func set_paint_color_by_name(color_key: String): pass
func set_interior_type(type: String): pass
func set_interior_by_viz_name(interior: String): pass
func set_wheel_type_by_gtw_name(gtw_enum_name: String): pass
func set_fade_roof(fade: bool = true, animated: bool = true, duration: float = 0.75): pass

export (NodePath) var front_suspension_path: NodePath
export (NodePath) var rear_suspension_path: NodePath
export (NodePath) var battery_path: NodePath

enum GHOST_CONFIG{NONE = 0, BATTERY = 1, SUSPENSION = 2}
export (GHOST_CONFIG) var ghost_view setget set_ghost_view

export (TIME_OF_DAY) var time_of_day setget set_time_of_day

func set_time_of_day(tod):
	time_of_day = tod;
	var body: MeshInstance = get_node(body_path);
	var mat;
	
	match (tod):
		TIME_OF_DAY.DAY:
			mat = load("res://" + local_dir + "/Transparent_Light_Background.material");
		TIME_OF_DAY.NIGHT:
			mat = load("res://" + local_dir + "/Transparent_Dark_Background.material");
			
	if body: body.set_surface_material(0, mat);
	
func set_ghost_view(v):
	var front_suspension: MeshInstance = get_node(front_suspension_path)
	var rear_suspension: MeshInstance = get_node(rear_suspension_path)
	var battery: MeshInstance = get_node(battery_path)
	
	ghost_view = v
	var mainmat;
	var blackmat;
	var batmat;
	
	match (ghost_view):
		GHOST_CONFIG.NONE, GHOST_CONFIG.BATTERY:
			batmat = load("res://" + local_dir + "/Main_Batteries_Solid.material");
			mainmat = load("res://" + local_dir + "/Main_Suspension_See_Through.material");
			blackmat = load("res://" + local_dir + "/Black_Suspension_See_Through.material");

		GHOST_CONFIG.SUSPENSION:
			batmat = load("res://" + local_dir + "/Main_Batteries_See_Through.material");
			mainmat = load("res://" + local_dir + "/Main_Suspension_Solid.material");
			blackmat = load("res://" + local_dir + "/Black_Suspension_Solid.material");
	
	if battery:
		battery.set_surface_material(0, batmat);
		
	if front_suspension:
		front_suspension.set_surface_material(0, mainmat);
		front_suspension.set_surface_material(1, blackmat);
	if rear_suspension:
		rear_suspension.set_surface_material(0, mainmat);
		rear_suspension.set_surface_material(1, blackmat);

	
