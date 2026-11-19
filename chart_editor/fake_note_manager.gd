extends Node

@onready var song_audio_player = ChartEditor.song_audio_player
@onready var note_manager: NoteManager = NoteManager.instance
@onready var audio_stream_player = $AudioStreamPlayer

const NOTE_CLICK = preload("uid://nwgw3lpaxmje")

@export var strum_line_container: EditorStrumLineContainer

var hit_note_ids = []
var frames_born = 0

var polyphonic_playback: AudioStreamPlaybackPolyphonic

func _ready() -> void:
	init_hit_notes()
	
	ChartLoader.instance.notes_loaded.connect(func():
		init_hit_notes()
	)
	
	audio_stream_player.play()
	polyphonic_playback = audio_stream_player.get_stream_playback()

func init_hit_notes():
	hit_note_ids = []
	# This can probably be optimized more, lol
	for strum_line_id in range(note_manager.strum_lines.size()):
		hit_note_ids.append([])
		for receptor_id in note_manager.strum_lines[strum_line_id].receptors.size():
			hit_note_ids[-1].append(-1)
			for note_id in note_manager.strum_lines[strum_line_id].receptors[receptor_id].notes.size():
				var note_to_hit = note_manager.strum_lines[strum_line_id].receptors[receptor_id].notes[note_id]
				if note_to_hit.time <= song_audio_player.song_position_seconds:
					hit_note_ids[-1][-1] = note_id

func _process(_delta: float) -> void:
	frames_born += 1
	for strum_line_id in range(note_manager.strum_lines.size()):
		for receptor_id in note_manager.strum_lines[strum_line_id].receptors.size():
			
			handle_note(strum_line_id, receptor_id)

func handle_note(strum_line_id, receptor_id):
	var receptor = note_manager.strum_lines[strum_line_id].receptors[receptor_id]
	
	if receptor.notes.size() == 0:
		return
	
	var current_note_id = hit_note_ids[strum_line_id][receptor_id]
	
	if current_note_id >= 0 and !receptor.notes[current_note_id].time <= song_audio_player.song_position_seconds:
		hit_note_ids[strum_line_id][receptor_id] -= 1
		return

	if receptor.notes.size() <= current_note_id + 1:
		return

	var next_note = receptor.notes[current_note_id + 1]
	if next_note.time <= song_audio_player.song_position_seconds:
		hit_note_ids[strum_line_id][receptor_id] = current_note_id + 1
		note_manager.note_press.emit(strum_line_id, receptor_id, next_note, 0.0)
		if frames_born > 5 && strum_line_container.strumlines[strum_line_id].hitsounds:
			polyphonic_playback.play_stream(NOTE_CLICK)
