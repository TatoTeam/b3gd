extends SubViewportContainer

func _process(_delta: float) -> void:
	var viewport_scale = get_viewport_transform().get_scale()
	var scale_mult = max(round(viewport_scale.x), 1.0)
	scale = Vector2.ONE / viewport_scale * scale_mult
	size = get_viewport_rect().size / scale
	position = Vector2.ZERO
