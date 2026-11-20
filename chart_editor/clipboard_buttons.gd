extends HBoxContainer

@onready var copy_button = $CopyButton
@onready var paste_button = $PasteButton

func _process(_delta: float) -> void:
	copy_button.disabled = ChartEditor.selection.size() == 0
	paste_button.disabled = !(ChartEditor.clipboard.size())

func _on_copy_button_pressed() -> void:
	ChartEditor.clipboard = ChartEditor.selection

func _on_paste_button_pressed() -> void:
	pass
	#var clipboard_contents = ChartEditor.clipboard
	
	# UUuuurgh
	
	#ChartEditor.undo_redo.create_action("Paste Objects")
	
	# xxx okay
	
	#ChartEditor.undo_redo.commit_action()
