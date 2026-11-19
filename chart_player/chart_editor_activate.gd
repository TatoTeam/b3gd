extends Node
class_name ChartPlayer

static var instance: ChartPlayer

@export var chart: Chart

@onready var ui = $UI
@onready var note_manager = $NoteManager
@onready var song_audio_player: SongAudioPlayer = $SongAudioPlayer
@onready var chart_loader: ChartLoader = $ChartLoader

const CHART_EDITOR_CANVAS := "uid://dk3bhqjhxhv5b"

var editor_canvas = null
var editor_active = false

func _init() -> void:
	instance = self

func _input(event: InputEvent) -> void:
	if not OS.has_feature("editor"):
		return
	
	if event.is_action_pressed("editor_activate"):
		if editor_canvas == null:
			add_editor()
		else:
			if editor_active:
				disable_editor()
			else:
				enable_editor()

func disable_editor() -> void:
	editor_active = false
	editor_canvas.process_mode = Node.PROCESS_MODE_DISABLED
	editor_canvas.hide()
	
	chart_loader.load_tracks()
	chart_loader.load_notes(true)
	chart_loader.load_events()
	
	note_manager.process_mode = Node.PROCESS_MODE_INHERIT
	ui.process_mode = Node.PROCESS_MODE_INHERIT
	ui.visible = true
	
	if song_audio_player.paused:
		song_audio_player.unpause()


func enable_editor() -> void:
	editor_active = true
	editor_canvas.process_mode = Node.PROCESS_MODE_INHERIT
	editor_canvas.show()
	chart_loader.load_chart()
	note_manager.process_mode = Node.PROCESS_MODE_DISABLED
	ui.process_mode = Node.PROCESS_MODE_DISABLED
	ui.visible = false


func add_editor() -> void:
	editor_active = true
	note_manager.process_mode = Node.PROCESS_MODE_DISABLED
	chart_loader.load_chart()
	
	editor_canvas = load(CHART_EDITOR_CANVAS).instantiate()
	editor_canvas.chart_editor._song_audio_player = song_audio_player
	editor_canvas.chart_editor.chart = chart
	add_child(editor_canvas)
	
	ui.process_mode = Node.PROCESS_MODE_DISABLED
	ui.visible = false
