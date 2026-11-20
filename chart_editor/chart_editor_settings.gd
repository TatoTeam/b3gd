extends Resource
class_name ChartEditorSettings

const NOTE_SIZE := 64

@export var editor_zoom: float = 4.0
@export var snapping: float = 8.0
@export var receptor_offset: float = 0.3

@export var note_type_settings: Dictionary[String, Note] = {}

func snap_time(time: float) -> float:
	if ChartEditor.song_audio_player == null:
		return time
	
	var beat: float = ChartEditor.song_audio_player.get_beat_from_seconds(time)
	beat = snappedf(beat, 4.0 / ChartEditor.instance.settings.snapping)
	return ChartEditor.song_audio_player.get_seconds_from_beat(beat)

func snap_beat(beat: float) -> float:
	if ChartEditor.song_audio_player == null:
		return -1 # you have bigger problems if the song is gone man
	
	beat = snappedf(beat, 4.0 / ChartEditor.instance.settings.snapping)
	return beat

func snap_beat_return_seconds(beat: float) -> float:
	if ChartEditor.song_audio_player == null:
		return -1
	
	beat = snappedf(beat, 4.0 / ChartEditor.instance.settings.snapping)
	return ChartEditor.song_audio_player.get_seconds_from_beat(beat)
