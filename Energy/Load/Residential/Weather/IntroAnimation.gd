extends Spatial

onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm")
export (NodePath)onready var gradient = get_node(gradient)
export (NodePath)onready var sun_object = get_node(sun_object)
export (NodePath)onready var cloud_controller = get_node(cloud_controller)

onready var animation_value = 70
onready var gradient_tween = gradient.get_child(0)
onready var time_of_day = 100
onready var previous_time_of_day = 100
var is_shown = false
var has_been_initialized = false
var previous_sky_scale = Vector3(1.5, 1.5, 1.5)

onready var energy_site = find_parent("EnergySite*")

func _ready():
	if energy_site == null: return
	energy_site.connect("on_energy_site_update", self, "update_weather")
	update_weather(energy_site.data)
	
func update_weather(data: EnergySiteData):
	if data == null:
		return

	
	_update_sky_scale(data)

	var weather = data.energy_site_summary.weather

	if weather == null or weather.empty():
		_update_visibility(false)
		return

	
	
	var is_night = weather.get("is_night", false)
	var should_show_weather = not is_night

	_update_visibility(should_show_weather)

func _update_visibility(should_show: bool):
	
	if has_been_initialized and (should_show == is_shown):
		return
		
	var fade_amount = 1 if should_show else 0
	fade_to_value(fade_amount)
	is_shown = should_show
	has_been_initialized = true
		
func fade_to_value(fade_number):
	gradient.fade_away(fade_number)
	sun_object.fade_away(null)
	cloud_controller.fade_away(null)

func _update_sky_scale(data: EnergySiteData):
	if data == null:
		return

	
	var target_scale = Vector3(1.5, 1.5, 1.5)

	
	if data.get_site_variant() == EnergySiteData.EnergySiteType.RESIDENTIAL_CLASSIC:
		
		var has_wall_connector = data.has_wall_connector_1()

		
		var pointcloud_wc = get_parent().get_node_or_null("PointcloudWallConnector")
		var pointcloud_enabled = pointcloud_wc != null and pointcloud_wc.enabled

		
		if not (has_wall_connector and pointcloud_enabled):
			target_scale = Vector3(1.42, 1.42, 1.42)

	
	if target_scale != previous_sky_scale:
		self.scale = target_scale
		previous_sky_scale = target_scale
