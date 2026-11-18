extends PropertyGetterSetter
class_name PropertyGetterSetterSpinBox

@export var radians_as_degrees: bool = false

func _ready():
	var parent: SpinBox = get_parent()
	
	parent.value_changed.connect(func(value):
		send_outgoing_value(deg_to_rad(value) if radians_as_degrees else value)
	)

func set_incoming_value(value: Variant):
	var parent: SpinBox = get_parent()
	
	parent.set_value_no_signal(rad_to_deg(value) if radians_as_degrees else value)

func get_outgoing_value() -> Variant:
	var parent: SpinBox = get_parent()
	return deg_to_rad(parent.value) if radians_as_degrees else parent.value

func can_set_incoming_value() -> bool:
	return true
