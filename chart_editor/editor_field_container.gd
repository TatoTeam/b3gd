extends GridContainer

@onready var note_class = $NoteClass

func _ready():
	ChartEditor.current_note_type = note_class.class_paths[note_class.selected]

func _on_note_class_item_selected(index):
	ChartEditor.current_note_type = note_class.class_paths[index]
