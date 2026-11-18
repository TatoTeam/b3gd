@icon("uid://u533g6m2i1ea")
class_name EventTweenCustom extends EventTween

@export var tween_node_path: String
@export var tween_property: String
@export var tween_value: Variant
@export var tween_multiply: bool:
	set(value):
		tween_multiply = value
		multiply = tween_multiply

var current_tween

func init():
	var tween_node = parent.get_tree().current_scene.get_node(tween_node_path)
	
	tween_tracker.node = self
	tween_tracker.property = "current_tween"
	
	to_tween.node = tween_node
	to_tween.property = tween_property
	to_tween.value_node = self
	to_tween.value_property = "tween_value"
	multiply = tween_multiply
