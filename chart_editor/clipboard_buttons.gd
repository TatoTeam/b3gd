extends HBoxContainer

@onready var copy_button = $CopyButton
@onready var paste_button = $PasteButton

func _process(_delta: float) -> void:
	copy_button.disabled = ChartEditor.instance.selection.size() == 0
	var clipboard_contents = str_to_var(DisplayServer.clipboard_get())
	paste_button.disabled = !(clipboard_contents is Array[TimelinePoint])

func _on_copy_button_pressed() -> void:
	pass
	var copied_data = ChartEditor.instance.selection.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	for timeline_point in copied_data:
		if timeline_point is Event:
			timeline_point.parent = null
	DisplayServer.clipboard_set(var_to_str(copied_data))

func _on_paste_button_pressed() -> void:
	var clipboard_contents = str_to_var(DisplayServer.clipboard_get())
	# UUuuurgh
	
	#ChartEditor.undo_redo.create_action("Paste Objects")
	
	# xxx okay
	
	#ChartEditor.undo_redo.commit_action()
