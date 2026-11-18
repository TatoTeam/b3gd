extends Control

func _draw() -> void:
	var end_time = ChartEditor.song_audio_player.song_length_seconds
	var strum_line_count = ChartEditor.instance.chart.strum_lines.size()
	
	for strum_line in ChartEditor.instance.chart.strum_lines:
		var strum_line_idx = ChartEditor.instance.chart.strum_lines.find(strum_line)
		var receptor_count = strum_line.receptors.size()
		
		for receptor in strum_line.receptors:
			var receptor_idx = strum_line.receptors.find(receptor)
			for note in receptor.notes:
				var note_x = (strum_line_idx / float(strum_line_count))
				note_x += ((receptor_idx + 0.5) / float(receptor_count)) / float(strum_line_count)
				note_x *= size.x
				
				var width = ((1.0 / float(receptor_count)) / float(strum_line_count)) * size.x
				
				var note_position = (note.time / end_time) * size.y
				var note_end_position = ((note.time + note.length) / end_time) * size.y
				note_end_position = max(note_end_position, note_position + (width * 0.5))
				
				var color: Color = ChartEditor.get_quant_color(note.time)
				color = color.lerp(Color.WHITE, 0.4)
				
				#draw_circle(Vector2(note_x, note_position), 1.0, Color(Color.WHITE, 0.5))
				draw_line(Vector2(note_x, note_position), Vector2(note_x, note_end_position), Color(color, 0.5), width)

func _process(_delta: float) -> void:
	queue_redraw()
