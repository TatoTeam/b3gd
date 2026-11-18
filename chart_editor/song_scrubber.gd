extends VScrollBar


func _unhandled_input(event):
	if event.is_action_pressed("editor_time_down") || event.is_action_pressed("editor_time_up"):
		var time := 4.0 / ChartEditor.instance.settings.snapping
		
		if event.is_action_pressed("editor_time_up"):
			time *= -1
		
		var seek_time := ChartEditor.instance.settings.snap_beat(ChartEditor.song_audio_player.song_position_beats + time)
		var next_seek_time := ChartEditor.instance.settings.snap_beat_return_seconds(seek_time + abs(time))
		seek_time = ChartEditor.song_audio_player.get_seconds_from_beat(seek_time)
		
		ChartEditor.song_audio_player.track_seek(seek_time, next_seek_time - seek_time)
		
	if event.is_action_pressed("editor_pause"):
		if ChartEditor.song_audio_player.paused:
			ChartEditor.song_audio_player.unpause()
		else:
			ChartEditor.song_audio_player.pause()
			

func _process(_delta: float) -> void:
	set_value_no_signal(ChartEditor.song_audio_player.song_position_seconds)
	max_value = ChartEditor.song_audio_player.song_length_seconds

func _on_value_changed(new_value: float) -> void:
	var seek_time := ChartEditor.instance.settings.snap_time(new_value)
	ChartEditor.song_audio_player.track_seek(seek_time, 0.5)
