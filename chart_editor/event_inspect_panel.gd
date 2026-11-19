extends PanelContainer
class_name InspectPanel

@export var header_variation: FontVariation
@onready var header = $Margin/EventContainer/Header/EventHeader
@onready var field_container = $Margin/EventContainer/EventFieldContainer
@onready var paste_button = $Margin/EventContainer/Header/PasteButton
var timeline_point_source: Array
var timeline_point: TimelinePoint

func _process(_delta: float) -> void:
	var clipboard_object = str_to_var(DisplayServer.clipboard_get())
	
	if !clipboard_object is TimelinePoint:
		if !paste_button.disabled:
			paste_button.disabled = true
		return
	
	if clipboard_object.get_script().get_global_name() == timeline_point.get_script().get_global_name():
		if paste_button.disabled:
			paste_button.disabled = false
	elif !paste_button.disabled:
		paste_button.disabled = true

func _load_event(p_timeline_point: TimelinePoint):
	timeline_point = p_timeline_point
	
	if timeline_point is Event:
		timeline_point_source = ChartEditor.instance.chart.events
	if timeline_point is Note:
		timeline_point_source = ChartEditor.instance.chart.events
	
	header.text = timeline_point.get_script().get_global_name()
	
	for child in field_container.get_children():
		field_container.remove_child(child)
		child.queue_free()
	
	var current_header = ""
	for property in timeline_point.get_property_list():
		if !(property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE): 
			current_header = property.name
			if !current_header.ends_with(".gd"):
				continue
			
			var label = Label.new()
			label.text = current_header
			label.label_settings = LabelSettings.new()
			label.label_settings.font = header_variation
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			field_container.add_child(label)
			
			continue
		if !(property.usage & PROPERTY_USAGE_EDITOR): 
			continue
		
		_add_field(property.name.capitalize(), property.name, property.type, property.hint, property.hint_string)
	
	var child_count = field_container.get_children().size()
	var cutoff_children = field_container.get_children().slice(child_count - 4)
	for child in cutoff_children:
		field_container.remove_child(child)
	if field_container.get_children().size() == 0:
		hide()

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
	binding.resource = timeline_point
	binding.property_path = property_path
	input.add_child(binding)
	binding.set_incoming_value(timeline_point.get_indexed(property_path))
	row.add_child(input)
	field_container.add_child(row)

func _on_close_button_pressed() -> void:
	ChartEditor.remove_from_selection(timeline_point)
	
	ChartEditor.undo_redo.create_action("Remove Timeline Point From Inspector")
	ChartEditor.undo_redo.add_do_reference(timeline_point)
	
	var chart = ChartEditor.instance.chart
	var array = null
	if timeline_point is Note:
		array = chart.strum_lines
		for strum_line in array:
			for receptor in strum_line.receptors:
				if receptor.notes.find(timeline_point) >= 0:
					array = receptor.notes
	
	if timeline_point is Event:
		array = chart.events
	
	if array == null:
		return
	
	ChartEditor.undo_redo.add_do_method(func():
		array.erase(timeline_point)
		ChartLoader.instance.load_notes()
	)
	
	ChartEditor.undo_redo.add_undo_method(func():
		array.append(timeline_point)
		ChartLoader.instance.load_notes()
	)
	
	ChartEditor.undo_redo.commit_action()

func _on_copy_button_pressed() -> void:
	var copied_data = timeline_point.duplicate_deep(Resource.DEEP_DUPLICATE_INTERNAL)
	if copied_data is Event:
		copied_data.parent = null
	DisplayServer.clipboard_set(var_to_str(copied_data))

func _on_paste_button_pressed() -> void:
	var clipboard_object = str_to_var(DisplayServer.clipboard_get())
	
	if !clipboard_object is TimelinePoint:
		if !paste_button.disabled:
			paste_button.disabled = true
		return
	
	if clipboard_object.get_script().get_global_name() != timeline_point.get_script().get_global_name():
		return
	
	clipboard_object.time = timeline_point.time
	if timeline_point is Event:
		clipboard_object.lane = timeline_point.lane
	if timeline_point is Note:
		clipboard_object.length = timeline_point.length
	
	ChartEditor.undo_redo.create_action("Paste Properties")
	for property in timeline_point.get_property_list():
		if !(property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE): 
			continue
		if !(property.usage & PROPERTY_USAGE_EDITOR): 
			continue
		timeline_point.set(property.name, clipboard_object.get(property.name))
		
		ChartEditor.undo_redo.add_do_property(timeline_point, property.name, clipboard_object.get(property.name))
		ChartEditor.undo_redo.add_undo_property(timeline_point, property.name, timeline_point.get(property.name))
	ChartEditor.undo_redo.commit_action()
