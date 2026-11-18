extends PropertyGetterSetterLabel


@export_enum("Seconds", "Beats") var type: int = 0

func set_incoming_value(value: Variant):
	var parent: Label = get_parent()
	value = float(value)
	
	if type == 0:
		var hours = value / 3600
		var minutes = value / 60
		var seconds = fmod(value, 60)
		var milliseconds = fmod(seconds, 1) * 100
		
		parent.text = "" if value >= 0 else "-"
		if floor(abs(hours)) > 0:
			parent.text += "%02d:" % [abs(hours)]
		parent.text += "%02d:%02d:%02d" % [abs(minutes), abs(seconds), abs(milliseconds)] 
	else:
		parent.text = "%0.3f" % ChartEditor.song_audio_player.get_beat_from_seconds(value)
