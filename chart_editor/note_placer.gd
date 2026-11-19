extends ColorRect

@onready var strumline_object: EditorStrumLine = $".."

var preview: EditorNote

var mouse_inside: bool = false

var placing_note: bool = false

var note_time: float = 0.0
var note_length: float = 0.0

var note_dir: int = 0

func _ready():
	_create_preview.call_deferred()

	mouse_entered.connect(func():
		mouse_inside = true
	)
	
	mouse_exited.connect(func():
		mouse_inside = false
	)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if placing_note && event.pressed == false:
				add_note()
			
			placing_note = event.pressed && !event.shift_pressed
			accept_event()

func _has_point(point: Vector2) -> bool:
	if !Rect2(Vector2.ZERO, size).has_point(point): 
		return false
	
	var mouse_position = get_global_transform() * point
	for node: EditorNote in ChartEditor.instance.timeline.note_nodes.values():
		if node.head.mouse_filter == Control.MOUSE_FILTER_IGNORE: 
			continue
		if node.head.get_global_rect().has_point(mouse_position): 
			return false
	return true

func remove_note(receptor: int, time: float, create_new_action: bool = true):
	if receptor > strumline_object.strumline.receptors.size() - 1 || receptor < 0: 
		return
	
	var notes = strumline_object.strumline.receptors[receptor].notes
	for note in notes:
		if is_equal_approx(note.time, time):
			if create_new_action:
				ChartEditor.undo_redo.create_action("Remove Note")
			
			ChartEditor.remove_from_selection(note)
			ChartEditor.undo_redo.add_do_reference(note)
			
			ChartEditor.undo_redo.add_do_method(func():
				notes.erase(note)
				ChartLoader.instance.load_notes()
			)
			
			ChartEditor.undo_redo.add_undo_method(func():
				notes.append(note)
				ChartLoader.instance.load_notes()
			)
			
			if create_new_action: 
				ChartEditor.undo_redo.commit_action()
			
			break

func add_note():
	if note_dir > strumline_object.strumline.receptors.size() - 1 || note_dir < 0: 
		return
	
	ChartEditor.undo_redo.create_action("Place Note")
	ChartEditor.clear_selection()
	
	for note in strumline_object.strumline.receptors[note_dir].notes:
		if (note.time > note_time and note.time <= note_time + note_length) or note.time == note_time:
			remove_note(note_dir, note.time, false)
		if (note_time > note.time and note_time <= note.time + note.length):
			var snap = (4.0 / ChartEditor.instance.settings.snapping)
			var new_note_length_beat = ChartEditor.song_audio_player.get_beat_from_seconds((note_time - note.time)) - snap
			var new_note_length = max(ChartEditor.song_audio_player.get_seconds_from_beat(new_note_length_beat), 0)
			
			ChartEditor.undo_redo.add_do_property(note, "length", new_note_length)
			ChartEditor.undo_redo.add_undo_property(note, "length", note.length)
	
	var receptor: Receptor = strumline_object.strumline.receptors.get(note_dir)
	var new_note: Note = load(ChartEditor.current_note_type).new()
	new_note.time = note_time
	new_note.length = note_length
	
	ChartEditor.undo_redo.add_do_reference(new_note)
	ChartEditor.undo_redo.add_do_method(func():
		receptor.notes.append(new_note)
		ChartLoader.instance.load_notes()
	)
	ChartEditor.undo_redo.add_undo_method(func():
		receptor.notes.erase(new_note)
		ChartLoader.instance.load_notes()
	)
	ChartEditor.undo_redo.commit_action()

func _process(_delta):
	if strumline_object.strumline == null or strumline_object.strumline.receptors.is_empty():
		if is_instance_valid(preview):
			preview.hide()
		return
	
	var mouse_position := get_local_mouse_position()
	var timeline := ChartEditor.instance.timeline
	var timeline_mouse := timeline.global_to_timeline(get_global_mouse_position())
	var mouse_time := timeline.y_to_time(timeline_mouse.y)
	if !placing_note:
		var step := size.x / strumline_object.strumline.receptors.size()
		note_dir = floori(mouse_position.x / step)
		note_time = timeline.y_to_snapped_time(timeline_mouse.y)
		note_length = 0.0
	else:
		note_length = maxf(ChartEditor.instance.settings.snap_time(maxf(mouse_time - note_time, 0.0)), 0.0)
	
	_update_preview()

func _create_preview() -> void:
	preview = EditorTimeline.NOTE_SCENE.instantiate()
	preview.note = Note.new()
	preview.visible = false
	preview.z_index = 1
	for control in [preview, preview.get_node("Note"), preview.get_node("Note/Color"), preview.get_node("Hold"), preview.get_node("Hold/Color")]:
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ChartEditor.instance.timeline.add_child(preview)

func _exit_tree() -> void:
	if is_instance_valid(preview):
		preview.queue_free()

func _update_preview() -> void:
	if not is_instance_valid(preview):
		return

	preview.visible = (mouse_inside or placing_note) and note_dir >= 0 and note_dir < strumline_object.strumline.receptors.size()
	if not preview.visible:
		return

	var timeline := ChartEditor.instance.timeline
	preview.note.time = note_time
	preview.note.length = note_length
	preview.direction = note_dir

	preview.position = Vector2(timeline.global_to_timeline(global_position).x + note_dir * ChartEditor.instance.settings.NOTE_SIZE, note_time * timeline.pixels_per_second)
	preview.head.scale.y = min(1.0, ChartEditor.instance.settings.editor_zoom)
	preview.head.position.y = -(preview.head.size.y * preview.head.scale.y * 0.5)
	
	preview.update_visuals(strumline_object.strumline.receptors.size(), timeline.pixels_per_second, timeline.timing_revision, true)
