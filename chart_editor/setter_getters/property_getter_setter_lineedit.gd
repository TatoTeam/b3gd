extends PropertyGetterSetter
class_name PropertyGetterSetterLineEdit

@export var variant_value: bool = false

func _ready():
	var parent: LineEdit = get_parent()
	
	parent.text_submitted.connect(func(text):
		send_outgoing_value(str_to_var(text) if variant_value else text)
	)

func set_incoming_value(value: Variant):
	var parent: LineEdit = get_parent()
	
	parent.text = var_to_str(value) if variant_value else str(value)

func get_outgoing_value() -> Variant:
	var parent: LineEdit = get_parent()
	return null if variant_value else parent.text

func can_set_incoming_value() -> bool:
	var parent: LineEdit = get_parent()
	return !parent.is_editing()
