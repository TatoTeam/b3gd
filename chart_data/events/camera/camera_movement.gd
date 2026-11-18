@icon("uid://b2oiqeqfiemmm")
class_name EventCameraMovement extends EventTween

@export_range(0.0, 40.0, 1.0, "or_greater", "camera_targets") var target_idx: int = 0

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
	to_tween.property = "position"
	to_tween.value_node = parent.get_tree().get_first_node_in_group("CameraTargets").get_children()[target_idx]
	to_tween.value_property = "global_position"
