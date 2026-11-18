extends Node
class_name ChartPlayer

@export var chart: Chart

@onready var ui = $UI
@onready var note_manager = $NoteManager
@onready var song_audio_player: SongAudioPlayer = $SongAudioPlayer
@onready var chart_loader: ChartLoader = $ChartLoader

const CHART_EDITOR_CANVAS := "uid://dk3bhqjhxhv5b"

var editor_canvas = null

func _input(event: InputEvent) -> void:
	if not OS.has_feature("editor"):
		return
	
	if event.is_action_pressed("editor_activate"):
		if editor_canvas == null:
			add_editor()
		else:
			erase_editor()

func erase_editor() -> void:
	editor_canvas.queue_free()
	editor_canvas = null
	
	chart_loader.load_tracks()
	chart_loader.load_notes(true)
	chart_loader.load_events()
	
	
	note_manager.process_mode = Node.PROCESS_MODE_INHERIT
	ui.process_mode = Node.PROCESS_MODE_INHERIT
	ui.visible = true
	
	if song_audio_player.paused:
		song_audio_player.unpause()

func add_editor() -> void:
	note_manager.process_mode = Node.PROCESS_MODE_DISABLED
	chart_loader.load_chart()
	
	editor_canvas = load(CHART_EDITOR_CANVAS).instantiate()
	editor_canvas.chart_editor._song_audio_player = song_audio_player
	editor_canvas.chart_editor.chart = chart
	add_child(editor_canvas)
	
	ui.process_mode = Node.PROCESS_MODE_DISABLED
	ui.visible = false
