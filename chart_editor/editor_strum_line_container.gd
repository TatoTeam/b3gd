extends HBoxContainer
class_name EditorStrumLineContainer

const STRUM_LINE = preload("uid://b7l3q0pg1d1ir")

var strumlines: Array[EditorStrumLine] = []

func _ready():
	for strumline in ChartEditor.instance.chart.strum_lines:
		var strum_line: EditorStrumLine = STRUM_LINE.instantiate()
		strum_line.load_strumline(strumline)
		add_child(strum_line)
		strumlines.append(strum_line)
