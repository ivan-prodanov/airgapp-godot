extends Viewport


onready var mobile_comm: MobileComm = get_node("/root/Mobile/MobileComm") as MobileComm
onready var LOG: LOG = get_node("/root/Mobile/Log")

const MobileComm = preload("res://mobile/scripts/MobileComm.gd")
const EnergySiteData = preload("res://mobile/scripts/data/EnergySiteData.gd")
const GodotMsg = preload("res://mobile/scripts/GodotMsg.gd")


func _ready():
	mobile_comm.register_listener(ReactMsg.INPUT_EVENT, funcref(self, "on_input_event"))

func on_input_event(data: Dictionary):
	var event_type = data.get("type", null)
	var event_data = data.get("data", null)
	
	if event_type == null or event_data == null: return
	
	if event_type.begins_with("TOUCH_"):
		on_touch_event(event_type, event_data)
	else:
		LOG.err("unknown input event type '%s'" % event_type)

func on_touch_event(type: String, data: Dictionary):
	
	var touch_index = data.get("index", null)
	var touch_position = data.get("position", null)
	if touch_index == null or touch_position == null: return
	
	if typeof(touch_position) != TYPE_ARRAY or touch_position.size() != 2: return
	touch_position = Vector2(touch_position[0], touch_position[1])
	
	match type:
		"TOUCH_START":
			on_touch_start(touch_index, touch_position)
		"TOUCH_MOVE":
			on_touch_move(touch_index, touch_position)
		"TOUCH_END":
			on_touch_end(touch_index, touch_position)
		_:
			LOG.err("unknown touch event type '%s'" % type)

func on_touch_start(index: int, position: Vector2):
	var event = InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = true
	send_input_event(event)
	
func on_touch_move(index: int, position: Vector2):
	var event = InputEventScreenDrag.new()
	event.index = index
	event.position = position
	
	send_input_event(event)

func on_touch_end(index: int, position: Vector2):
	var event = InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = false
	send_input_event(event)

func send_input_event(event: InputEvent):
	Input.parse_input_event(event)
