extends HBoxContainer

@onready var undo_button = $UndoButton
@onready var redo_button = $RedoButton


func _process(_delta):
	undo_button.disabled = !ChartEditor.undo_redo.has_undo()
	redo_button.disabled = !ChartEditor.undo_redo.has_redo()

func _on_undo_button_pressed():
	ChartEditor.undo_redo.undo()

func _on_redo_button_pressed():
	ChartEditor.undo_redo.redo()

func _on_save_button_pressed():
	if ChartEditor.instance.chart.resource_path.get_extension() != "tres":
		_on_save_as_button_pressed()
	else:
		ResourceSaver.save(ChartEditor.instance.chart, ChartEditor.instance.chart.resource_path)

func _on_save_as_button_pressed():
	var save_dialog := FileDialog.new()
	save_dialog.filters = ["*.tres"]
	save_dialog.title = "Save Chart"
	
	add_child(save_dialog)
	save_dialog.show()
	
	save_dialog.file_selected.connect(func(path):
		ResourceSaver.save(ChartEditor.instance.chart, path)
		ChartEditor.instance.chart.take_over_path(path)
	)
