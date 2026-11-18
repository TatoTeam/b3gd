extends PanelContainer
class_name EventInspectPanel

@onready var event_id = $Margin/EventContainer/Header/EventID
@onready var event_header = $Margin/EventContainer/Header/EventHeader
@onready var event_field_container = $Margin/EventContainer/EventFieldContainer

var event: Event


func _load_event(p_event: Event):
	event = p_event
	event_header.text = event.get_script().get_global_name()
	
	for child in event_field_container.get_children():
		event_field_container.remove_child(child)
		child.queue_free()
	
	for property in event.get_property_list():
		if !(property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
		if !(property.usage & PROPERTY_USAGE_EDITOR): continue
		
		_add_field(property.name.capitalize(), property.name, property.type, property.hint, property.hint_string)

func _add_field(label_text: String, property_path: String, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = ""):
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = label_text + ":"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	
	var input: Control
	var binding: PropertyGetterSetter
	match type:
		TYPE_BOOL:
			input = CheckBox.new()
			binding = PropertyGetterSetterCheckBox.new()
		TYPE_INT, TYPE_FLOAT:
			if hint == PROPERTY_HINT_ENUM:
				var options = OptionButton.new()
				var value = 0
				for option in hint_string.split(","):
					if option.contains(":"):
						value = int(option.get_slice(":", 1))
					options.add_item(option.get_slice(":", 0), value)
					value += 1
				input = options
				binding = PropertyGetterSetterOptionButton.new()
			else:
				var spinbox = SpinBox.new()
				spinbox.allow_greater = true
				spinbox.allow_lesser = true
				spinbox.step = 1.0 if type == TYPE_INT else 0.001
				input = spinbox
				binding = PropertyGetterSetterSpinBox.new()
				if hint == PROPERTY_HINT_RANGE:
					var range_settings = hint_string.split(",")
					spinbox.min_value = float(range_settings[0])
					spinbox.max_value = float(range_settings[1])
					if range_settings.size() > 2:
						spinbox.step = float(range_settings[2])
					spinbox.allow_greater = range_settings.has("or_greater")
					spinbox.allow_lesser = range_settings.has("or_less")
					spinbox.exp_edit = range_settings.has("exp")
					binding.radians_as_degrees = range_settings.has("radians_as_degrees")
					for setting in range_settings:
						if setting.begins_with("suffix:"):
							spinbox.suffix = setting.trim_prefix("suffix:")
					if range_settings.has("degrees") || binding.radians_as_degrees:
						spinbox.suffix = "°"
					if spinbox.step == 0.0:
						spinbox.custom_arrow_step = 1.0 if type == TYPE_INT else 0.001
		TYPE_VECTOR2:
			_add_field(label_text + " X", property_path + ":x", TYPE_FLOAT, hint, hint_string)
			_add_field(label_text + " Y", property_path + ":y", TYPE_FLOAT, hint, hint_string)
			row.free()
			return
		_:
			input = LineEdit.new()
			binding = PropertyGetterSetterLineEdit.new()
			binding.variant_value = type != TYPE_STRING
	
	input.custom_minimum_size.x = 120
	binding.node = self
	binding.resource = event
	binding.property_path = property_path
	input.add_child(binding)
	binding.set_incoming_value(event.get_indexed(property_path))
	row.add_child(input)
	event_field_container.add_child(row)
