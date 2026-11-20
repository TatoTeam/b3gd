extends Control

@onready var class_box = $ClassBox

var event_time: float = 0.0
var lane: int = 0

func _process(_delta):
	if ChartEditor.song_audio_player == null: return
	
	if Input.is_key_pressed(KEY_SHIFT):
		visible = false
		return
	else:
		visible = true
	
	var timeline := ChartEditor.instance.timeline

	if !class_box.button_pressed:
		event_time = timeline.y_to_snapped_time(timeline.global_to_timeline(get_global_mouse_position()).y)

	global_position.y = (timeline.get_global_transform() * Vector2(0.0, timeline.time_to_y(event_time))).y

	lane = 0
	for event in ChartEditor.instance.chart.events:
		if abs(event.time - event_time) < 0.05:
			if event.lane >= lane:
				lane = event.lane + 1
	
	position.x = -39.0 - lane * EditorEvent.LANE_WIDTH - EditorEvent.BUTTON_SIZE.x

func _on_class_box_item_selected(index):
	class_box.select(-1)
	
	var event: Event = load(class_box.class_paths[index]).new()
	event.parent = EventPlayer.instance
	event.time = event_time
	event.lane = lane
	event.init()
	
	ChartEditor.instance.chart.events.append(event)
	ChartEditor.select_only(event)
