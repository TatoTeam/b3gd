extends HBoxContainer

@onready var copy_button = $CopyButton
@onready var paste_button = $PasteButton

func _process(_delta: float) -> void:
	copy_button.disabled = ChartEditor.selection.size() == 0
	paste_button.disabled = !(ChartEditor.clipboard.size())

func _on_copy_button_pressed() -> void:
	ChartEditor.clipboard_note_info.clear()
	ChartEditor.clipboard = ChartEditor.selection
	
	for timeline_point in ChartEditor.clipboard:
		if timeline_point is not Note:
			continue
		
		for strum_line in ChartEditor.instance.chart.strum_lines:
			for receptor in strum_line.receptors:
				if receptor.notes.find(timeline_point) != -1:
					ChartEditor.clipboard_note_info.set(timeline_point, receptor)
					continue

func _on_paste_button_pressed() -> void:
	pass
	
	var time_offset = 0xfffffffffffffff
	for timeline_point in ChartEditor.clipboard:
		time_offset = min(timeline_point.time, time_offset)
	
	ChartEditor.undo_redo.create_action("Place Note")
	
	ChartEditor.clear_selection(false)
	
	for timeline_point in ChartEditor.clipboard:
		var new_timeline_point = timeline_point.duplicate()
		ChartEditor.add_to_selection(new_timeline_point, false)
		new_timeline_point.time -= time_offset
		new_timeline_point.time += ChartEditor.song_audio_player.song_position_seconds
		if timeline_point is Note:
			var receptor: Receptor = ChartEditor.clipboard_note_info[timeline_point as Note]
			ChartEditor.undo_redo.add_do_reference(new_timeline_point)
			ChartEditor.undo_redo.add_do_method(func():
				receptor.notes.append(new_timeline_point)
				receptor.sort_notes()
				ChartLoader.instance.load_notes()
			)
			ChartEditor.undo_redo.add_undo_method(func():
				receptor.notes.erase(new_timeline_point)
				receptor.sort_notes()
				ChartLoader.instance.load_notes()
			)
		if timeline_point is Event:
			ChartEditor.undo_redo.add_do_reference(new_timeline_point)
			ChartEditor.undo_redo.add_do_method(func():
				ChartEditor.instance.chart.events.append(new_timeline_point)
				ChartEditor.instance.chart.sort_events()
				new_timeline_point.parent = EventPlayer.instance
				new_timeline_point.init()
			)
			ChartEditor.undo_redo.add_undo_method(func():
				ChartEditor.instance.chart.events.erase(new_timeline_point)
				ChartEditor.instance.chart.sort_events()
			)
	
	ChartEditor.undo_redo.commit_action()
	
	#var clipboard_contents = ChartEditor.clipboard
	
	# UUuuurgh
	
	#ChartEditor.undo_redo.create_action("Paste Objects")
	
	# xxx okay
	
	#ChartEditor.undo_redo.commit_action()

func add_note():
	
	#var receptor: Receptor = strumline_object.strumline.receptors.get(note_dir)
	var new_note: Note = load(ChartEditor.current_note_type).new()
	#new_note.time = note_time
	#new_note.length = note_length
	
	#ChartEditor.undo_redo.add_do_reference(new_note)
	#ChartEditor.undo_redo.add_do_method(func():
	#	receptor.notes.append(new_note)
	#	receptor.sort_notes()
	#	ChartLoader.instance.load_notes()
	#)
	#ChartEditor.undo_redo.add_undo_method(func():
	#	receptor.notes.erase(new_note)
	#	receptor.sort_notes()
	#	ChartLoader.instance.load_notes()
	#)
	#ChartEditor.undo_redo.commit_action()
