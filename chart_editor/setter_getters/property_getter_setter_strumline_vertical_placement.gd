extends PropertyGetterSetter

func _ready():
	var parent: VSlider = get_parent()
	
	parent.value_changed.connect(func(value):
		send_outgoing_value(1.0 - value)
	)

func set_incoming_value(value: Variant):
	var parent: VSlider = get_parent()
	parent.set_value_no_signal(1.0 - value)

func get_outgoing_value() -> Variant:
	var parent: VSlider = get_parent()
	return 1.0 - parent.value

func can_set_incoming_value() -> bool:
	return true
