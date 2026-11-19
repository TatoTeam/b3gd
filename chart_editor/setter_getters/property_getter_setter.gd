extends Node
class_name PropertyGetterSetter

@export var node: Node
@export_multiline("monospace", "no_wrap") var property_path: String

var resource: Resource

func _process(_delta):
	var target = resource if resource != null else node
	var result = target.get_indexed(property_path)
	
	if get_outgoing_value() != result and can_set_incoming_value():
		set_incoming_value(result)

func send_outgoing_value(value: Variant):
	var target = resource if resource != null else node
	var result = target.get_indexed(property_path)
	ChartEditor.undo_redo.create_action("Edit Property: %s:%s" % [node.name, property_path])
	ChartEditor.undo_redo.add_do_method(target.set_indexed.bind(property_path, value))
	ChartEditor.undo_redo.add_undo_method(target.set_indexed.bind(property_path, result))
	
	ChartEditor.undo_redo.commit_action()

@warning_ignore("unused_parameter")
func set_incoming_value(value: Variant):
	return

func get_outgoing_value() -> Variant:
	return null

func can_set_incoming_value() -> bool:
	return true
