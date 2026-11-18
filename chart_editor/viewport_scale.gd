extends SubViewportContainer

func _process(_delta: float) -> void:
	scale = Vector2.ONE / get_viewport_transform().get_scale()
	size = get_viewport_rect().size / scale
	position = Vector2.ZERO
