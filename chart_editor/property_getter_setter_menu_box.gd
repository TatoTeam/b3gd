extends PropertyGetterSetter

@export var id = 0

@onready var parent: MenuButton = get_parent()

func _ready():
	parent.get_popup().id_pressed.connect(func(id_pressed):
		if id_pressed != id:
			return
		var toggled_on = parent.get_popup().is_item_checked(parent.get_popup().get_item_index(id))
		if id != 0:
			print(id)
		send_outgoing_value(!toggled_on)
	)

func set_incoming_value(value: Variant):
	print(value, id)
	parent.get_popup().set_item_checked(parent.get_popup().get_item_index(id), bool(value))

func get_outgoing_value() -> Variant:
	return parent.get_popup().is_item_checked(parent.get_popup().get_item_index(id))

func can_set_incoming_value() -> bool:
	return true
