extends MarginContainer
class_name ChartEditor

static var instance: ChartEditor
static var undo_redo: UndoRedo:
	get():
		return instance._undo_redo

static var song_audio_player: SongAudioPlayer:
	get():
		return instance._song_audio_player

static var selection: Array[TimelinePoint] = []
static var clipboard: Array[TimelinePoint] = []

static var current_note_type: String

@export var chart: Chart
@export var settings: ChartEditorSettings

@onready var timeline: EditorTimeline = $UIContainer/WorkAreaScroll/Container/TimelineContainer/Timeline

signal selection_updated

var inst_muted: bool:
	set(value):
		inst_muted = value
		
		ChartEditor.song_audio_player.stream.set_sync_stream_volume(0, -999 if inst_muted else 0)

var _song_audio_player: SongAudioPlayer

var _undo_redo: UndoRedo


const QUANT_LIST := [4, 8, 12, 16, 24, 32, 48, 64]

static var QUANT_COLORS: Array[Color] = [
	Color.from_string("e01e00", Color.BLACK),
	Color.from_string("003fed", Color.BLACK),
	Color.from_string("8300e0", Color.BLACK),
	Color.from_string("4ab50d", Color.BLACK),
	Color.from_string("db1fd2", Color.BLACK),
	Color.from_string("e0bb00", Color.BLACK),
	Color.from_string("e67cb1", Color.BLACK),
	Color.from_string("48d9c3", Color.BLACK),
	Color.from_string("999999", Color.BLACK)
]

static func get_quant_id(note_time: float) -> int:
	return get_quant_id_from_beat(ChartEditor.song_audio_player.get_beat_from_seconds(note_time))

static func get_quant_id_from_beat(note_beat: float) -> int:
	var note_beat_sm: int = round(note_beat * 48.0)
	for i in QUANT_LIST.size():
		if note_beat_sm % (192 / QUANT_LIST[i]) == 0:
			return i
	return 8

static func get_quant_color(note_time: float) -> Color:
	return QUANT_COLORS[get_quant_id(note_time)]

static func get_quant_color_from_beat(note_beat: float) -> Color:
	return QUANT_COLORS[get_quant_id_from_beat(note_beat)]

static func select_only(selectable: TimelinePoint):
	undo_redo.create_action("Select Selectable Only")
	
	var old_selection_array := selection.duplicate()
	
	undo_redo.add_do_method(func():
		selection.clear()
		selection.append(selectable)
		if instance: instance.selection_updated.emit()
	)
	
	undo_redo.add_undo_method(func():
		selection.erase(selectable)
		selection = old_selection_array.duplicate()
		if instance: instance.selection_updated.emit()
	)
	
	undo_redo.commit_action()

static func add_to_selection(selectable: TimelinePoint):
	if selection.has(selectable): return
	undo_redo.create_action("Select Selectable")
	
	undo_redo.add_do_method(func():
		selection.append(selectable)
		if instance: instance.selection_updated.emit()
	)
	
	undo_redo.add_undo_method(func():
		selection.erase(selectable)
		if instance: instance.selection_updated.emit()
	)
	
	undo_redo.commit_action()

static func remove_from_selection(selectable: TimelinePoint):
	if !selection.has(selectable): return
	undo_redo.create_action("Deselect Selectable")
	
	undo_redo.add_do_method(func():
		selection.erase(selectable)
		if instance: instance.selection_updated.emit()
	)
	
	undo_redo.add_undo_method(func():
		selection.append(selectable)
		if instance: instance.selection_updated.emit()
	)
	
	undo_redo.commit_action()

static func clear_selection():
	undo_redo.create_action("Select Selectable Only")
	
	var old_selection_array := selection.duplicate()
	
	undo_redo.add_do_method(func():
		selection.clear()
		if instance: instance.selection_updated.emit()
	)
	
	undo_redo.add_undo_method(func():
		selection = old_selection_array.duplicate()
		if instance: instance.selection_updated.emit()
	)
	
	undo_redo.commit_action()

func remove_event(event: Event):
	ChartEditor.undo_redo.create_action("Remove Event")
	
	ChartEditor.undo_redo.add_do_reference(event)
	
	ChartEditor.undo_redo.add_do_method(func():
		ChartEditor.remove_from_selection(event)
		ChartEditor.instance.chart.events.erase(event)
	)
	
	ChartEditor.undo_redo.add_undo_method(func():
		ChartEditor.instance.chart.events.append(event)
	)
	
	ChartEditor.undo_redo.commit_action()

func _init():
	instance = self
	
	_undo_redo = UndoRedo.new()

func _ready():
	song_audio_player.pause()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			clear_selection()
