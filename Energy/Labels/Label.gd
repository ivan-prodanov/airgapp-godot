extends Control
class_name EnergyLabel



onready var theme_manager: ThemeManager = get_node("/root/Mobile/ThemeManager") as ThemeManager
onready var app_config_manager: AppConfigManager = get_node("/root/Mobile/AppConfigManager") as AppConfigManager

export (String) var identifier: String = ""
export (NodePath)onready var label_icon = get_node_or_null(label_icon)


export (float) var minimum_line_length = 0.1

export (String) var header_text: String = "" setget set_header_text
export (String) var body_text: String = "" setget set_body_text
export (String) var charging_state: String = "" setget set_charging_state

var override_color: String = "" setget set_override_color

export (bool) var error = false setget set_error

export (bool) var show_body_icon = false setget set_show_body_icon


export (NodePath)onready var reference_position_path setget set_reference_position_path


onready var reference_position = get_node(reference_position_path)

onready var label_layout_manager: Node = get_node_or_null("/root/Mobile/MainViewContainter/Viewport/root/ProductSwitcher/Slot/LabelLayoutManager/root/Mobile/MainViewContainer/Viewport/root/ProductSwitcher/Slot/EnergySite/LabelLayoutManager")


var background_stylebox = StyleBoxFlat.new()


var reference_point = Vector2(0, 0)

var show_label = false setget set_show_label
var layout_ready = false setget set_layout_ready

const VECTOR2_OFFSCREEN = Vector2(100000, 100000)


signal click

var is_dirty = false
onready var large_font_scale_threshold = 1.7

onready var camera_node = get_node_or_null("/root/Mobile/MainViewContainer/Viewport/root/ProductSwitcher/Slot/EnergySite/Camera")
onready var site_root_node = get_node_or_null("/root/Mobile/MainViewContainer/Viewport/root/ProductSwitcher/Slot/EnergySite/SiteRoot")
onready var tween_line = $Line / Tween
export (NodePath)onready var tween_text_path
onready var tween_text

onready var is_off_screen = false
onready var separator_dot = " · "

func set_header_text(text: String):
	header_text = text
	is_dirty = true
	
func set_body_text(text: String):
	body_text = text
	is_dirty = true
	
func set_charging_state(text: String):
	charging_state = text
	is_dirty = true

func set_error(is_error: bool):
	error = is_error
	is_dirty = true

func set_show_body_icon(is_show_body_icon: bool):
	show_body_icon = is_show_body_icon
	is_dirty = true

func set_override_color(new_override_color: String):
	override_color = new_override_color
	is_dirty = true

func set_show_label(new_show_label: bool):
	show_label = new_show_label
	is_dirty = true

func set_layout_ready(new_layout_ready: bool):
	layout_ready = new_layout_ready
	is_dirty = true

func get_error_icon_node():
	return $CenterContainer / VBox / Header / ErrorIcon
	
func get_body_icon_node():
	return $CenterContainer / VBox / Header / ErrorIcon
	
func get_header_label():
	return $CenterContainer / VBox / Header
	
func get_body_label():
	return $CenterContainer / VBox / HBoxContainer / Body
	
func get_body_left_label():
	return $CenterContainer / VBox / HBoxContainer / BodyLeft
	
func get_body_right_label():
	return $CenterContainer / VBox / HBoxContainer / BodyRight
	
func get_charging_icon():
	return $CenterContainer / VBox / HBoxContainer / VBoxContainer / ChargeIcon
	

onready var theme_attributes = {
	theme_manager.ThemeType.LIGHT: {
		"line_color": Color(0.3765, 0.3765, 0.3765, 0.8), 
		"header_color": Color(0.3765, 0.3765, 0.3765, 1.0), 
		"body_color": Color(0.1333, 0.1333, 0.1333, 1.0), 
	}, 
	theme_manager.ThemeType.DARK: {
		"line_color": Color(0.4, 0.4, 0.4, 0.8), 
		"header_color": Color(0.608, 0.608, 0.608, 1.0), 
		"body_color": Color(0.96, 0.96, 0.96, 1.0), 
		"body_color_dimmed": Color(0.96, 0.96, 0.96, 0.5), 
	}
}
	
func update_text():
	get_header_label().text = ("× " if error else "") + header_text
	get_header_label().text = header_text
	
	
	var use_split_layout = separator_dot in body_text and charging_state != "" and charging_state != "STANDBY"
	if use_split_layout:
		var parts = body_text.split(separator_dot)
		if parts.size() >= 2:
			get_body_left_label().text = parts[0]
			get_body_right_label().text = parts[1]
			get_body_label().visible = false
			get_body_left_label().visible = true
			get_body_right_label().visible = true
		else:
			use_split_layout = false
	
	if not use_split_layout:
		
		get_body_label().text = body_text
		get_body_label().visible = not body_text.empty()
		get_body_left_label().visible = false
		get_body_right_label().visible = false
	
	if get_charging_icon():
		format_charging_icon(charging_state)
	
	var body_color = theme_attributes[theme_manager.app_theme].body_color_dimmed if (body_text == "0 kW" or body_text == "Idle") else theme_attributes[theme_manager.app_theme].body_color
	get_body_label().add_color_override("font_color", body_color)
	get_body_left_label().add_color_override("font_color", body_color)
	get_body_right_label().add_color_override("font_color", body_color)
	
	get_header_label().visible = not get_header_label().text.empty()
		
	update_size()

	
	call_deferred("update_size")

func format_charging_icon(charging_state):
	if charging_state == "": return
	var charging_icon = get_charging_icon()
	if charging_icon == null: return
	
	match charging_state:
		"CHARGING":
			charging_icon.flip_v = false
			charging_icon.visible = true
			charging_icon.material.set_shader_param("albedo", Color(0.06, 0.89, 0.55, 1.0))
		"DISCHARGING":
			charging_icon.flip_v = true
			charging_icon.visible = true
			charging_icon.material.set_shader_param("albedo", Color(0.06, 0.89, 0.55, 1.0))
		_:
			charging_icon.visible = false

	


func set_reference_position_path(path: String):
	reference_position_path = path
	reference_position = get_node(reference_position_path)
	



func get_reference_point():
	
	
	if reference_position == null: return VECTOR2_OFFSCREEN
	
	return reference_position.global_transform.origin


func update_label_position():
	var camera: Camera = get_viewport().get_camera()
	reference_point = camera.unproject_position(get_reference_point())

const SPECIFICATIONS = {
	
	"padding_horizontal": 5, 
	
	
	"padding_vertical": 5, 
	
	
	"line_offset": - 1, 
	
	"font_size_body": 16, 
	"font_size_header": 11, 
	
	"error_icon_size": 14, 
	
	
	"error_icon_padding": 5, 
	
	"body_icon_padding": 12, 
	
	"line_above_gap": 3, 
	"line_below_gap": - 2, 
	
	"line_width": 1.5
}


func get_specification(name):
	return SPECIFICATIONS.get(name, 0) * app_config_manager.pixel_ratio
	
func update_size():
	
	
	var pixel_ratio = app_config_manager.pixel_ratio
	var font_scale = clamp(app_config_manager.font_scale, 0.1, large_font_scale_threshold)
	
	background_stylebox.content_margin_top = get_specification("padding_vertical")
	background_stylebox.content_margin_bottom = get_specification("padding_vertical")
	background_stylebox.content_margin_left = get_specification("padding_horizontal")
	background_stylebox.content_margin_right = get_specification("padding_horizontal")

	
	var icon_size_natural = 24 * 4

	
	var icon_size_actual = get_specification("error_icon_size") * font_scale
	var icon_offset = get_specification("error_icon_padding")
	var body_icon_offset = get_specification("body_icon_padding")
	
	if show_body_icon:
		get_body_icon_node().margin_left = - icon_size_actual / 2
		get_body_icon_node().margin_top = - icon_size_actual / 2
		get_body_icon_node().rect_scale = Vector2(1.0, 1.0) * (icon_size_actual / icon_size_natural)
		get_body_icon_node().rect_min_size = Vector2(icon_size_actual, icon_size_actual)

	
	var charging_icon = get_charging_icon()
	if charging_icon:
		var body_font_size = get_specification("font_size_body") * font_scale
		var icon_size = body_font_size * 0.5
		charging_icon.rect_scale = Vector2(1.0, 1.0) * (icon_size / icon_size_natural)
		charging_icon.rect_min_size = Vector2(icon_size_natural, icon_size_natural)
		
		var container = $CenterContainer / VBox / HBoxContainer / VBoxContainer
		container.rect_min_size.y = body_font_size
		container.rect_min_size.x = icon_size * 1.45
		container.visible = get_body_left_label().visible
		charging_icon.margin_top = - icon_size / 2.0
		charging_icon.margin_bottom = icon_size / 2.0
		charging_icon.margin_left = body_font_size * 0.15

	
	$CenterContainer / VBox.add_constant_override("separation", get_specification("line_header"))

	
	get_header_label().get_font("font").size = get_specification("font_size_header") * font_scale
	var body_font_size = get_specification("font_size_body") * font_scale
	get_body_label().get_font("font").size = body_font_size
	get_body_left_label().get_font("font").size = body_font_size
	get_body_right_label().get_font("font").size = body_font_size
	
	










		
	
	rect_size = Vector2(1, 1)
	$Line.set_pixel_ratio(pixel_ratio)
	if label_layout_manager == null: return
	if self.rect_position[0] < label_layout_manager.get_start_of_viewport():
		self.is_off_screen = true

var transparent_color = Color(0.4, 0.4, 0.4, 0.0)

func _on_fade_in_labels(dimmed = false):
	label_layout_manager.clear_vertical_stack_list()
	
	if tween_line.is_active():
		tween_line.stop_all()
		

	tween_line.interpolate_property($Line, "default_color", transparent_color, theme_attributes[theme_manager.app_theme].line_color, 1.5, 
	Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween_line.start()

	tween_text.interpolate_method(self, 
			"fade_in_header", transparent_color, theme_attributes[theme_manager.app_theme].header_color, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween_text.start()

	tween_text.interpolate_method(self, 
			"fade_in_body", transparent_color, theme_attributes[theme_manager.app_theme].body_color_dimmed, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween_text.start()
	
func _on_fade_out_labels():
	label_layout_manager.clear_vertical_stack_list()

	if tween_line.is_active():
		tween_line.stop_all()
		
	label_icon.visible = false
	tween_line.interpolate_property($Line, "default_color", theme_attributes[theme_manager.app_theme].line_color, transparent_color, 0.8, 
	Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween_line.start()

	tween_text.interpolate_method(self, 
			"fade_in_header", theme_attributes[theme_manager.app_theme].header_color, transparent_color, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween_text.start()

	tween_text.interpolate_method(self, 
			"fade_in_body", theme_attributes[theme_manager.app_theme].body_color, transparent_color, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween_text.start()

func fade_in_body(current_color):
	get_body_label().add_color_override("font_color", current_color)

func fade_in_header(current_color):
	get_header_label().add_color_override("font_color", current_color)

func update_theme(theme: int):
	var colors = theme_attributes[theme]

	background_stylebox.bg_color = Color(1.0, 1.0, 1.0, 0)











func add_to_label_layout_manager():
	var energy_site = find_parent("EnergySite*")
	if energy_site == null: return
	
	label_layout_manager = energy_site.get_node("LabelLayoutManager")
	if label_layout_manager == null: return

	label_layout_manager.add_label(self)

func _enter_tree():
	add_to_label_layout_manager()

func _exit_tree():
	if label_layout_manager == null: return
	
	label_layout_manager.remove_label(self)
	
func update_visible():
	visible = show_label and layout_ready
	
func _ready():
	process_priority = 1
	rect_position = VECTOR2_OFFSCREEN
	
	if tween_text_path != null:
		tween_text = get_node(tween_text_path)
	
	
	add_to_label_layout_manager()
	
	
	app_config_manager.connect("set_pixel_ratio", self, "on_set_pixel_ratio")
	app_config_manager.connect("set_font_scale", self, "on_set_font_scale")

	var main_view_container = find_parent("MainViewContainer") as MainViewContainer
	if main_view_container != null:
		main_view_container.connect("scroll_fraction_change", self, "on_scroll_fraction_change")
		on_scroll_fraction_change(main_view_container.current_scroll_fraction)
	
	theme_manager.connect("set_app_theme", self, "update_theme")
	
	add_stylebox_override("panel", background_stylebox)
	
	visible = false
	update_visible()
	update_text()
	update_theme(theme_manager.app_theme)
	update_size()
	if camera_node == null:
		$Line.default_color = theme_attributes[theme_manager.app_theme].line_color
		get_header_label().add_color_override("font_color", theme_attributes[theme_manager.app_theme].header_color)
		get_body_label().add_color_override("font_color", theme_attributes[theme_manager.app_theme].body_color)
	else:
		camera_node.connect("fade_in_labels", self, "_on_fade_in_labels")
		
	if site_root_node != null:
		site_root_node.connect("fade_out_labels", self, "_on_fade_out_labels")
		site_root_node.connect("fade_in_labels", self, "_on_fade_in_labels")
	
func _process(delta: float):
	rect_position = VECTOR2_OFFSCREEN
	if is_dirty:
		is_dirty = false
		update_visible()
		update_text()
		update_theme(theme_manager.app_theme)

func update_line(below: bool):
	$Line.update_position(below)
	
func on_set_pixel_ratio(pixel_ratio: float):
	update_size()

func on_set_font_scale(font_scale: float):
	update_size()
	
func on_scroll_fraction_change(scroll_fraction: float):
	var fade = clamp(inverse_lerp(0.7, 1, scroll_fraction), 0.0, 1.0)
	modulate = Color(1, 1, 1, fade)


const click_distance = 10


export var click_extra_margin = 15


var pressed_event: InputEvent


func _input(event: InputEvent) -> void :
	if not (event is InputEventScreenTouch): return

	
	if not visible: return

	
	if not get_global_rect().grow(click_extra_margin * app_config_manager.pixel_ratio).has_point(event.position): return

	if event.pressed:
		pressed_event = event
		return

	
	if pressed_event == null: return

	
	if event.position.distance_to(pressed_event.position) > click_distance * app_config_manager.pixel_ratio:
		pressed_event = null
		return
	
	pressed_event = null

	emit_signal("click")
