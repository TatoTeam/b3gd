extends Control

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	position.y = -get_parent().position.y
	draw_set_transform(Vector2(-get_parent().global_position.x, get_parent().position.y))
	
	var position_start = -get_parent().position.y
	var position_end = -get_parent().position.y + get_parent().get_parent().size.y
	var time_start = get_parent().y_to_time(position_start)
	var time_end = get_parent().y_to_time(position_end)
	
	for strumline in get_parent().strum_line_container.strumlines:
		if strumline.strumline == null:
			continue
		
		var area = strumline.note_area
		
		var snap = 4.0 / ChartEditor.instance.settings.snapping
		var grid_line = ChartEditor.instance.settings.snap_time(time_start)
		var snap_time = ChartEditor.song_audio_player.get_seconds_from_beat(ChartEditor.instance.settings.snap_beat(time_start) + snap) - grid_line
		while grid_line < time_end:
			var line = get_parent().time_to_y(grid_line)
			
			draw_line(Vector2(area.global_position.x, line), Vector2(area.global_position.x + area.size.x, line), Color(ChartEditor.get_quant_color(grid_line), 0.25), 4)
			grid_line = ChartEditor.instance.settings.snap_time(grid_line)
			var grid_line_beat = ChartEditor.song_audio_player.get_beat_from_seconds(grid_line)
			snap_time = ChartEditor.song_audio_player.get_seconds_from_beat(ChartEditor.instance.settings.snap_beat(grid_line_beat) + snap) - grid_line
			grid_line += snap_time
