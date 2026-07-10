tool 
extends Camera

export (int) var width;
export (int) var height;
export (bool) var hide_standard_ego;
export (bool) var transparent = true;
export (bool) var hide_roof = false;
export (String) var day_skin_override = "";
export (String) var night_skin_override = "";
export (Color) var day_bg
export (Color) var night_bg

export (bool) var preview_viewport setget set_preview_viewport

enum TIME_OF_DAY{DAY_ONLY = 0, NIGHT_ONLY = 1, DAY_AND_NIGHT = 2}
export (TIME_OF_DAY) var time_of_day = TIME_OF_DAY.DAY_AND_NIGHT;

enum GHOST_CONFIG{NONE = 0, BATTERY = 1, SUSPENSION = 2}
export (GHOST_CONFIG) var ghost_car_config = GHOST_CONFIG.NONE;

func set_preview_viewport(v):
	if v:
		ProjectSettings.set_setting("display/window/size/width", width);
		ProjectSettings.set_setting("display/window/size/height", height);
		preview_viewport = false;
