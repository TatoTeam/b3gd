extends OptionButton

@onready var current_time_label_setter = $"../CurrentTimeLabel/CurrentTimeLabelSetter"
@onready var total_time_label_setter = $"../HBoxContainer/TotalTimeLabel2/TotalTimeLabelSetter"


func _on_item_selected(index):
	current_time_label_setter.type = index
	total_time_label_setter.type = index
