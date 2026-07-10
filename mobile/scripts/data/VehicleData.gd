extends ProductData

class_name VehicleData
	
const vehicle_model_key_from_vin = {
	"S": "models2", 
	"3": "model3", 
	"X": "modelx", 
	"Y": "modely", 
	"C": "cybertruck", 
	"T": "semitruck", 
}

class VehicleConfig extends Resource:
	var car_type: String
	var fascia_type: String
	var rhd: bool
	var exterior_color: String
	var paint_color_override: String
	var wheel_type: String
	var spoiler_type: String
	var eu_vehicle: bool
	var exterior_trim: String
	var exterior_trim_override: String
	var interior_trim_type: String
	var rear_seat_type: int
	var third_row_seats: int
	var trim_badging: String
	var charge_port_type: String
	var headlamp_type: String
	var aux_park_lamps: String
	var steering_wheel_type: int
	var red_brake_calipers: bool
	var rearlight_type: int
	var has_tesla_badge: bool
	var has_tesla_word_mark: bool
	var accessory_lightbar_type: int
	var drivetrain_type: int
	var chassis_type: String
	var has_stalk: bool
	var has_front_fascia_camera: bool
	var badge_version: int
	var window_tint_color: String
	var interior_upper_trim_materials: int
	var badging_material_type: int
	var special_badging_type: int

	func _init(data: Dictionary = {}, vin: String = "0003"):
		car_type = ProductData.getValue(data, "car_type", "unknown")
		if car_type == "unknown":
			
			car_type = vehicle_model_key_from_vin.get(vin[3], "modely")
		fascia_type = ProductData.getValue(data, "fascia_type", "original")
		rhd = ProductData.getValue(data, "rhd", false)
		exterior_color = ProductData.getValue(data, "exterior_color", "PearlWhite")
		paint_color_override = ProductData.getValue(data, "paint_color_override", "")
		wheel_type = ProductData.getValue(data, "wheel_type", "Unknown")
		spoiler_type = ProductData.getValue(data, "spoiler_type", "None")
		eu_vehicle = ProductData.getValue(data, "eu_vehicle", false)
		exterior_trim = ProductData.getValue(data, "exterior_trim", "Black")
		exterior_trim_override = ProductData.getValue(data, "exterior_trim_override", "")
		interior_trim_type = ProductData.getValue(data, "interior_trim_type", "Black")
		rear_seat_type = ProductData.getValue(data, "rear_seat_type", RearSeatType.BASE)
		third_row_seats = ThirdRowSeatValue.get(ProductData.getValue(data, "third_row_seats", "None"), ThirdRowSeatType.NONE)
		trim_badging = ProductData.getValue(data, "trim_badging", "")
		charge_port_type = ProductData.getValue(data, "charge_port_type", "US")
		headlamp_type = ProductData.getValue(data, "headlamp_type", "Premium")
		aux_park_lamps = ProductData.getValue(data, "aux_park_lamps", "NaPremium")
		steering_wheel_type = ProductData.getValue(data, "steering_wheel_type", 0)
		red_brake_calipers = ProductData.getValue(data, "red_brake_calipers", false)
		rearlight_type = ProductData.getValue(data, "rearlight_type", 0)
		has_tesla_badge = ProductData.getValue(data, "has_tesla_badge", true)
		has_tesla_word_mark = ProductData.getValue(data, "has_tesla_word_mark", true)
		accessory_lightbar_type = ProductData.getValue(data, "accessory_lightbar_type", 0)
		drivetrain_type = ProductData.getValue(data, "drivetrain_type", 0) + 1
		chassis_type = ProductData.getValue(data, "chassis_type", "model_y")
		has_stalk = ProductData.getValue(data, "has_stalk", false)
		has_front_fascia_camera = ProductData.getValue(data, "has_front_fascia_camera", false)
		badge_version = ProductData.getValue(data, "badge_version", 0)
		window_tint_color = ProductData.getValue(data, "window_tint_color", "0,0,0,153")
		interior_upper_trim_materials = ProductData.getValue(data, "interior_upper_trim_materials", 0)
		badging_material_type = ProductData.getValue(data, "badging_material_type", - 1)
		special_badging_type = ProductData.getValue(data, "car_special_type", 0)

enum RearSeatType{
		BASE = 0, 
		RECARO = 1, 
		EXECUTIVE = 2, 
		TWO_SEAT = 3, 
		FOLD_FLAT = 4, 
}

enum ThirdRowSeatType{INVALID, NONE, FUTURIS_FOLD_FLAT, FUTURIS_NO_FOLD_FLAT, FLAT_FOLD}
const ThirdRowSeatValue = {
		"<invalid>": ThirdRowSeatType.INVALID, 
		"None": ThirdRowSeatType.NONE, 
		"FuturisFoldFlat": ThirdRowSeatType.FUTURIS_FOLD_FLAT, 
		"FuturisNoFoldFlat": ThirdRowSeatType.FUTURIS_NO_FOLD_FLAT, 
		"FlatFold": ThirdRowSeatType.FLAT_FOLD, 

}

class VehicleState extends Resource:
	var df: bool
	var dr: bool
	var pf: bool
	var pr: bool
	var ft: bool
	var rt: bool
	var tn: int
	var accessory_lightbar_middle_on: bool
	var basecamp_mode_on: bool
	var colorizer_paint_remap_enabled: bool
	
	func _init(data: Dictionary = {}):
		df = ProductData.getValue(data, "df", false)
		dr = ProductData.getValue(data, "dr", false)
		pf = ProductData.getValue(data, "pf", false)
		pr = ProductData.getValue(data, "pr", false)
		ft = ProductData.getValue(data, "ft", false)
		rt = ProductData.getValue(data, "rt", false)
		tn = ProductData.getValue(data, "tn", 0)
		accessory_lightbar_middle_on = ProductData.getValue(data, "accessory_lightbar_middle_on", false)
		basecamp_mode_on = ProductData.getValue(data, "basecamp_mode_on", false)
		colorizer_paint_remap_enabled = ProductData.getValue(data, "colorizer_color_remap_enabled", false)

class VehicleChargeState extends Resource:

	enum FlowState{
		Disabled = 0, 
		Flow = 1, 
		Pulse = 2, 
		Solid = 3, 
		Rave = 4, 
		Powershare = 5, 
	}

	var charge_port_door_open: bool
	var is_charging: bool
	var charge_port_color: String
	var charge_port_flow_state: int
	var powershare_type: int
	var powershare_status: int
	var vehicle_to_home_ready: bool = false
	
	func _init(data: Dictionary = {}):
		charge_port_door_open = ProductData.getValue(data, "charge_port_door_open", false)
		charge_port_flow_state = ProductData.getValue(data, "charge_port_flow_state", FlowState.Disabled)
		powershare_type = ProductData.getValue(data, "powershare_type", 0)
		powershare_status = ProductData.getValue(data, "powershare_status", 0)
		if charge_port_flow_state == FlowState.Disabled:
			charge_port_color = "000000"
		else:
			charge_port_color = ProductData.getValue(data, "charge_port_color", "000000")
		if powershare_type == 2 and (powershare_status == 2 or powershare_status == 5):
			is_charging = false
			vehicle_to_home_ready = true
		else:
			vehicle_to_home_ready = false
			is_charging = ProductData.getValue(data, "chargeport_flow_state", null) != null or ProductData.getValue(data, "charge_port_color", null) != null

class VehicleDriveState extends Resource:
	var speed: int
	var shift_state: int
		
	func _init(data: Dictionary = {}):
		speed = ProductData.getValue(data, "speed", 0)
		shift_state = ShiftState.get(ProductData.getValue(data, "shift_state", "P"), ShiftStateType.PARKED)

class VehicleClimateState extends Resource:
	var is_climate_on: bool
	var is_preconditioning: bool
	var is_front_defroster_on: bool
	var is_rear_defroster_on: bool
		
	func _init(data: Dictionary = {}):
		is_climate_on = ProductData.getValue(data, "is_climate_on", false)
		is_preconditioning = ProductData.getValue(data, "is_preconditioning", false)
		is_front_defroster_on = ProductData.getValue(data, "is_front_defroster_on", false)
		is_rear_defroster_on = ProductData.getValue(data, "is_rear_defroster_on", false)

class MobileAppState extends Resource:
	var is_loading: bool
	
	var show_terrain: bool
	var wheel_turn_deg: int
	var window_animation_state: Dictionary

	func _init(data: Dictionary = {}):
		is_loading = ProductData.getValue(data, "is_loading", false)
		show_terrain = ProductData.getValue(data, "show_terrain", false)
		wheel_turn_deg = ProductData.getValue(data, "wheel_turn_deg", 0)
		var local_window_animation_state = data.get("window_animation_state", {})
		window_animation_state = local_window_animation_state if local_window_animation_state is Dictionary else {}

class CarWrapState extends Resource:
	var skin: String

	func _init(data: Dictionary = {}):
		skin = ProductData.getValue(data, "skin", "")

enum ShiftStateType{PARKED, REVERSE, NEUTRAL, DRIVE}
const ShiftState = {
	"P": ShiftStateType.PARKED, 
	"R": ShiftStateType.REVERSE, 
	"N": ShiftStateType.NEUTRAL, 
	"D": ShiftStateType.DRIVE, 
}


var vin: String
var vehicle_config: VehicleConfig = VehicleConfig.new()
var vehicle_2_config: VehicleConfig = VehicleConfig.new()
var vehicle_state: VehicleState = VehicleState.new()
var charge_state: VehicleChargeState = VehicleChargeState.new()
var drive_state: VehicleDriveState = VehicleDriveState.new()
var climate_state: VehicleClimateState = VehicleClimateState.new()
var mobile_app_state: MobileAppState = MobileAppState.new()
var car_wrap_state: CarWrapState = CarWrapState.new()

func _init(data: Dictionary):
	type = ProductType.VEHICLE
	id = ProductData.getValue(data, "id", "")
	vin = ProductData.getValue(data, "vin", "0003")

	update(data)

func update(data: Dictionary):
	var state = data.get("vehicle_state")
	if state != null:
		vehicle_state = VehicleState.new(state)
	
	var config = data.get("vehicle_config")
	var config2 = data.get("vehicle_2_config")

	if config != null:
		vehicle_config = VehicleConfig.new(config, vin)
		if data.get("wall_connector_2_visible"):
			vehicle_2_config = VehicleConfig.new(config2)

	var charge = data.get("charge_state")
	if charge != null:
		charge_state = VehicleChargeState.new(charge)
		
	var drive = data.get("drive_state")
	if drive != null:
		drive_state = VehicleDriveState.new(drive)

	var climate = data.get("climate_state")
	if climate != null:
		climate_state = VehicleClimateState.new(climate)
	
	var mobileApp = data.get("mobile_app_state")
	if mobileApp != null:
		mobile_app_state = MobileAppState.new(mobileApp)

	var carWrap = data.get("car_wrap_state")
	if carWrap != null:
		car_wrap_state = CarWrapState.new(carWrap)

func isDriving():
	return drive_state.shift_state != ShiftState.P and drive_state.shift_state != null
	
func inReverse():
	return drive_state.shift_state == ShiftState.R

func isChargerConnected():
	return charge_state.is_charging
	
func isClimateOn():
	return climate_state.is_climate_on or climate_state.is_preconditioning

func hasGlobalHeadlamp():
	return vehicle_config.headlamp_type == "Global"

func hasFogLamps():
	return vehicle_config.aux_park_lamps != "None"

func isLoading():
	return mobile_app_state.is_loading == true

func showTerrain():
	return vehicle_config.car_type == "cybertruck" and mobile_app_state.show_terrain and not isDriving()

func vehicle_to_home_ready():
	return charge_state.vehicle_to_home_ready

static func id_from_data(data: Dictionary):
	var id = ProductData.getValue(data, "id", null)
	if id == null:
		printerr("Invalid vehicle data: ", data)
	
	return id
