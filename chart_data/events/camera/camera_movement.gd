@icon("uid://b2oiqeqfiemmm")
class_name EventCameraMovement extends EventTween

@export_range(0.0, 40.0, 1.0, "or_greater", "camera_targets") var target_idx: int = 0:
	set(value):
		target_idx = value
		if parent != null:
			init()
		else:
			print("parent is null bro")

static var position_tween: Tween

func init():
	if parent.get_tree().get_first_node_in_group("CameraTargets") == null:
		force_ignore = true
		return
	if parent.get_tree().get_first_node_in_group("SceneCamera") == null:
		force_ignore = true
		return
	
	tween_tracker.node = self
	tween_tracker.property = "position_tween"
	
	to_tween.node = parent.get_tree().get_first_node_in_group("SceneCamera")
	to_tween.property = "global_position"
	
	var choices = parent.get_tree().get_first_node_in_group("CameraTargets").get_children()
	to_tween.value_node = choices[clamp(target_idx, 0, choices.size() - 1)]
	to_tween.value_property = "global_position"
