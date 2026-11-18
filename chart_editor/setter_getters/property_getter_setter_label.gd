extends PropertyGetterSetter
class_name PropertyGetterSetterLabel

func set_incoming_value(value: Variant):
	var parent: Label = get_parent()
	
	parent.text = str(value)

func get_outgoing_value() -> Variant:
	return null

func can_set_incoming_value() -> bool:
	return true
