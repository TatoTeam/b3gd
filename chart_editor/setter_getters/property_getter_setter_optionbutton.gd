extends PropertyGetterSetter
class_name PropertyGetterSetterOptionButton

func _ready():
	var parent: OptionButton = get_parent()
	
	parent.item_selected.connect(func(index):
		send_outgoing_value(parent.get_item_id(index))
	)

func set_incoming_value(value: Variant):
	var parent: OptionButton = get_parent()
	
	parent.select(parent.get_item_index(value))

func get_outgoing_value() -> Variant:
	var parent: OptionButton = get_parent()
	return parent.get_selected_id()

func can_set_incoming_value() -> bool:
	return true
