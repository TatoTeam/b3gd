extends Control
class_name EditorTimeline

const NOTE_SCENE: PackedScene = preload("res://b3gd/chart_editor/note.tscn")
const EVENT_SCENE: PackedScene = preload("res://b3gd/chart_editor/event.tscn")
const EVENT_ICON: Texture2D = preload("res://b3gd/chart_editor/event_unknown.png")

@onready var work_area: Control = get_parent().get_parent()
@onready var strum_line_container: EditorStrumLineContainer = $"../../StrumLineContainer"
@onready var event_container: Control = get_parent()

var note_nodes: Dictionary = {}
var event_nodes: Dictionary = {}
var timing_revision: int = 0
var _timing_state: Array = []

var _class_icon_paths: Dictionary = {}
var _script_icons: Dictionary = {}
var _icons_initialized := false

var pixels_per_second: float:
	get():
		return ChartEditor.instance.settings.NOTE_SIZE * ChartEditor.instance.settings.editor_zoom

var receptor_y_pos: float:
	get():
		return work_area.size.y * ChartEditor.instance.settings.receptor_offset

func _process(_delta: float) -> void:
	if ChartEditor.instance.chart == null or ChartEditor.song_audio_player == null:
		return
	
	position.x = -event_container.position.x
	position.y = receptor_y_pos - ChartEditor.song_audio_player.song_position_seconds * pixels_per_second
	_update_timing_revision()
	_sync_notes()
	_sync_events()

func _input(event):
	if event is InputEventMouse:
		var editing_notes = event.shift_pressed || event.button_mask & MOUSE_BUTTON_MASK_RIGHT
		if event is InputEventMouseButton:
			editing_notes = editing_notes || (event.pressed && event.button_index == MOUSE_BUTTON_RIGHT)
		for node: EditorNote in note_nodes.values():
			node.head.mouse_filter = Control.MOUSE_FILTER_STOP if editing_notes else Control.MOUSE_FILTER_IGNORE
	
	if event is InputEventMouseMotion && event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		if !is_visible_in_tree(): return
		if !work_area.get_global_rect().has_point(event.position): return
		
		for node: EditorNote in note_nodes.values():
			if node.head.get_global_rect().has_point(event.position):
				node.remove_note()

func _update_timing_revision() -> void:
	var state: Array = []
	for bpm_event in ChartEditor.song_audio_player.bpm_events:
		state.append(Vector2(bpm_event.time, bpm_event.bpm))
	
	if state != _timing_state:
		_timing_state = state
		timing_revision += 1

func _sync_notes() -> void:
	var present: Dictionary = {}
	
	for strumline in strum_line_container.strumlines:
		if not is_instance_valid(strumline) or strumline.strumline == null:
			continue
		
		var origin_x := global_to_timeline(strumline.note_area.global_position).x
		var receptors := strumline.strumline.receptors
		
		for dir in receptors.size():
			var receptor: Receptor = receptors[dir]
			for note in receptor.notes:
				if note == null:
					continue
				
				present[note] = true
				var node: EditorNote = note_nodes.get(note)
				
				if node == null:
					node = NOTE_SCENE.instantiate()
					node.note = note
					add_child(node)
					note_nodes[note] = node
				
				node.receptor = receptor
				node.note_placer = strumline.note_area
				node.direction = dir
				node.position = Vector2(origin_x + dir * ChartEditor.instance.settings.NOTE_SIZE, note.time * pixels_per_second)
				node.update_visuals(receptors.size(), pixels_per_second, timing_revision)
	
	_remove_missing(note_nodes, present)

func _sync_events() -> void:
	var present: Dictionary = {}
	var origin_x := get_event_origin_x()

	for event in ChartEditor.instance.chart.events:
		if event == null:
			continue

		present[event] = true
		var node: EditorEvent = event_nodes.get(event)

		if node == null:
			node = EVENT_SCENE.instantiate()
			node.event = event
			add_child(node)
			event_nodes[event] = node

		node.position = Vector2(origin_x - event.lane * EditorEvent.LANE_WIDTH, event.time * pixels_per_second)
		node.update_visuals(get_script_icon(event.get_script()))

	_remove_missing(event_nodes, present)

func _remove_missing(nodes: Dictionary, present: Dictionary) -> void:
	for resource in nodes.keys():
		if not present.has(resource):
			var node: Node = nodes[resource]
			remove_child(node)
			node.queue_free()
			nodes.erase(resource)

func global_to_timeline(point: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * point

func time_to_y(time: float) -> float:
	return time * pixels_per_second

func y_to_time(y: float) -> float:
	return y / pixels_per_second

func y_to_snapped_time(y: float) -> float:
	return ChartEditor.instance.settings.snap_time(y_to_time(y))

func get_event_origin_x() -> float:
	return global_to_timeline(event_container.global_position).x - 39.0

func get_script_icon(script: Script) -> Texture2D:
	if script == null:
		return EVENT_ICON
	if _script_icons.has(script):
		return _script_icons[script]
	
	if not _icons_initialized:
		for entry in ProjectSettings.get_global_class_list():
			_class_icon_paths[entry["path"]] = entry["icon"]
		_icons_initialized = true
	
	var path: String = _class_icon_paths.get(script.resource_path, "")
	var icon: Texture2D = EVENT_ICON
	if not path.is_empty():
		icon = load(path) as Texture2D
		if icon == null:
			icon = EVENT_ICON
	
	_script_icons[script] = icon
	return icon
