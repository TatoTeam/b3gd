@icon("uid://drbn861q6bcpl")
class_name EventCameraZoom extends EventTween

@export var target_zoom: Vector2 = Vector2.ONE
@export var multiplicative: bool = false:
	set(value):
		multiplicative = value
		multiply = multiplicative

static var zoom_tween: Tween

func init():
	if parent.get_tree().get_first_node_in_group("SceneCamera") == null:
		force_ignore = true
		return
	tween_tracker.node = self
	tween_tracker.property = "zoom_tween"
	
	to_tween.node = parent.get_tree().get_first_node_in_group("SceneCamera")
	to_tween.property = "zoom"
	
	to_tween.value_node = self
	to_tween.value_property = "target_zoom"
	
	multiply = multiplicative
