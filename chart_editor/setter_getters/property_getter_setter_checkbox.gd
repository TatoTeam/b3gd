extends PropertyGetterSetter
class_name PropertyGetterSetterCheckBox

func _ready():
	var parent: CheckBox = get_parent()
	
	parent.toggled.connect(func(toggled_on):
		send_outgoing_value(toggled_on)
	)

func set_incoming_value(value: Variant):
	var parent: CheckBox = get_parent()
	
	parent.set_pressed_no_signal(bool(value))

func get_outgoing_value() -> Variant:
	var parent: CheckBox = get_parent()
	return parent.button_pressed

func can_set_incoming_value() -> bool:
	return true
