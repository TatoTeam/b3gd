extends HBoxContainer

@export var editor_strumline: EditorStrumLine
@onready var receptor_count = $ReceptorCount

func _ready():
	receptor_count.text = str(editor_strumline.strumline.receptors.size())

func _process(_delta):
	receptor_count.text = str(editor_strumline.strumline.receptors.size())

func _on_add_receptor_pressed():
	var new_receptor = Receptor.new()
	
	ChartEditor.undo_redo.create_action("Add Receptor")
	ChartEditor.undo_redo.add_do_reference(new_receptor)
	ChartEditor.undo_redo.add_do_method(func():
		editor_strumline.strumline.receptors.append(new_receptor)
	)
	ChartEditor.undo_redo.add_undo_method(func():
		editor_strumline.strumline.receptors.erase(new_receptor)
	)
	ChartEditor.undo_redo.commit_action()

func _on_remove_receptor_pressed():
	if editor_strumline.strumline.receptors.size() == 1: return
	
	var last_receptor = editor_strumline.strumline.receptors[-1]
	
	ChartEditor.undo_redo.create_action("Add Receptor")
	ChartEditor.undo_redo.add_do_reference(last_receptor)
	ChartEditor.undo_redo.add_do_method(func():
		editor_strumline.strumline.receptors.erase(last_receptor)
	)
	ChartEditor.undo_redo.add_undo_method(func():
		editor_strumline.strumline.receptors.append(last_receptor)
	)
	ChartEditor.undo_redo.commit_action()
