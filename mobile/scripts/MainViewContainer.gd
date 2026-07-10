tool 
extends ViewportContainer

class_name MainViewContainer

const ReactMsg = preload("res://mobile/scripts/ReactMsg.gd")

onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm")
onready var tween: Tween = get_node("Tween")
onready var viewport: Viewport = get_node("Viewport")
onready var root_node: Spatial = get_node("Viewport/root")



signal scroll_fraction_change(fraction)

var current_scroll_fraction: float = 1




var container_offset = Vector2(0, 0)
var container_size = Vector2(1, 1)

func _ready():
	mobile_comm.register_listener(ReactMsg.UPDATE_MAIN_VIEW_FRAME, funcref(self, "on_update_main_view_frame"))
	
func on_update_main_view_frame(data: Dictionary):
	var screen_width: float = get_viewport().size.x
	var screen_height: float = get_viewport().size.y

	print("[MainViewController] screen_width: %f screen_height: %f" % [screen_width, screen_height])
	
	var top_margin = data.get("top_margin", 0)
	var left_margin = data.get("left_margin", 0)
	var width = data.get("width", screen_width)
	var height = data.get("height", screen_height)
	# iOS fit: RN reports the main-view frame in points; the Godot viewport is in device pixels,
	# so scale by pixel_ratio or the car renders tiny in the corner. No-op when pixel_ratio==1
	# (the local dev harness) or off-iOS.
	if OS.get_name() == "iOS":
		var _acm = get_node_or_null("/root/Mobile/AppConfigManager")
		if _acm != null and _acm.pixel_ratio > 0:
			top_margin *= _acm.pixel_ratio
			left_margin *= _acm.pixel_ratio
			width *= _acm.pixel_ratio
			height *= _acm.pixel_ratio
	
	var animated = data.get("animated", true)
	var duration = data.get("duration", 0.75)
	var transition_type = data.get("transition_type", Tween.TRANS_QUART)
	var ease_type = data.get("ease_type", Tween.EASE_IN_OUT)
	
	var scale: Vector3 = Vector3.ONE * (height / screen_height)
	var center_x = left_margin + (screen_width / 2 * width / screen_width)
	var center_y = top_margin + (screen_height / 2 * scale.y)
	var position_x = center_x - (screen_width / 2)
	var position_y = center_y - (screen_height / 2)
	
	var scroll_fraction = data.get("scroll_fraction", clamp(inverse_lerp(0.4, 0.8, scale.x), 0, 1))
		
	container_offset = Vector2(screen_width / 2 - width / 2, screen_height / 2 - height / 2)
	container_size = Vector2(width, height)
	
	
	if current_scroll_fraction != scroll_fraction:
		current_scroll_fraction = scroll_fraction
		emit_signal("scroll_fraction_change", scroll_fraction)
	
	if animated:
		tween.interpolate_property(self, "rect_position", null, Vector2(position_x, position_y), duration, transition_type, ease_type)
		tween.interpolate_property(root_node, "scale", null, scale, duration, transition_type, ease_type)
		tween.start()
	else:
		if tween.is_active():
			tween.stop_all()
		rect_position = Vector2(position_x, position_y)
		root_node.scale = scale

func _process(delta):
	
	if not OS.has_feature("editor") or Engine.editor_hint: return
	
	var inspector = get_node_or_null("../Inspector")
	if inspector == null:
		return
	var inspector_width = 0
	
	if inspector != null and inspector.shown:
		inspector_width = inspector.get_size().x
	on_update_main_view_frame({
		"top_margin": 0, 
		"left_margin": inspector_width, 
		"width": get_viewport().size.x - inspector_width, 
		"height": get_viewport().size.y, 
		"animated": false, 
		"scroll_fraction": 1, 
	})

# === iOS free orbit: drag to rotate + release inertia (injected by fix_godot_project.py) ===
# Ports LocalDevMessageInjector free-orbit (drag spin + inertial coast). GodotHost.mm's
# UIPanGestureRecognizer feeds InputEventScreenTouch/Drag into Input; this root-viewport node
# consumes them and spins the CameraPivot, which lives in the sub-Viewport (out of input's reach).
# DISABLED (2026-06-21, after exhaustive testing). Even with the recognizer gated to Controls
# only, even with edge-touch rejection, even with inertia killed — orbit still crashed within
# seconds of any drag because the rapid camera mutation feeds the same GLES2 driver corruption
# that gl_view.mm touchesBegan triggers on iOS 26 / A19 Pro. Belt-and-suspenders: gate here
# in GDScript too, so even if the native recognizer is mistakenly re-enabled the orbit script
# returns early. Re-enable both this const AND the VehicleCanvas prop only after Phase 8.
const _ORBIT_ENABLED = false
const _ORBIT_YAW_SENS = 0.16
const _ORBIT_PITCH_SENS = 0.06
const _ORBIT_MIN_PITCH = 1.0
const _ORBIT_MAX_PITCH = 79.0
# whenever the user navigated away mid-coast (or even a fraction of a second after release):
# both _physics_process and Tween mutated pivot.rotation_degrees in the same frame, crashing
# Godot. Effective inertia = 0 by making min-threshold larger than any realistic velocity.
const _ORBIT_INERTIA_DAMPING = 99.0
const _ORBIT_MIN_INERTIA = 1.0e9
var _orbit_dragging = false
var _orbit_velocity = Vector2.ZERO

func _orbit_pivot():
	return get_node_or_null("Viewport/CameraManager/CameraPivot")

func _orbit_apply(pivot, rotation_delta):
	var r = pivot.rotation_degrees
	r.y += rotation_delta.x
	r.x = clamp(r.x + rotation_delta.y, _ORBIT_MIN_PITCH, _ORBIT_MAX_PITCH)
	r.z = 0
	pivot.rotation_degrees = r

func _input(event):
	if Engine.editor_hint or not _ORBIT_ENABLED:
		return
	var pivot = _orbit_pivot()
	if pivot == null:
		return
	if event is InputEventScreenTouch:
		_orbit_dragging = event.pressed
		_orbit_velocity = Vector2.ZERO  # belt-and-suspenders: kill velocity on both press AND release
		if event.pressed:
			var ct = get_node_or_null("Viewport/CameraManager/Tween")
			if ct != null and ct.is_active():
				ct.remove_all()
	elif event is InputEventScreenDrag and _orbit_dragging:
		var rotation_delta = Vector2(-event.relative.x * _ORBIT_YAW_SENS, -event.relative.y * _ORBIT_PITCH_SENS)
		_orbit_apply(pivot, rotation_delta)
		_orbit_velocity = rotation_delta / max(get_physics_process_delta_time(), 0.008)

func _physics_process(delta):
	if Engine.editor_hint or not _ORBIT_ENABLED or _orbit_dragging:
		return
	if _orbit_velocity.length() < _ORBIT_MIN_INERTIA:
		_orbit_velocity = Vector2.ZERO
		return
	var pivot = _orbit_pivot()
	if pivot == null:
		return
	_orbit_apply(pivot, _orbit_velocity * delta)
	_orbit_velocity = _orbit_velocity.linear_interpolate(Vector2.ZERO, min(1.0, _ORBIT_INERTIA_DAMPING * delta))
