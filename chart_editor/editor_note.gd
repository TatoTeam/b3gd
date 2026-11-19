extends Control
class_name EditorNote

const NOTES: CompressedTexture2D = preload("uid://bdkks2vfqiwwd")

static var note_texture_arrays = preload("res://b3gd/multikey.json").data

var note: Note
var receptor: Receptor
var note_placer: ColorRect
var direction: int
var _visual_state: Array = []

@onready var class_icon = $ClassIcon
@onready var head: TextureRect = $Note
@onready var head_color: TextureRect = $Note/Color
@onready var hold: TextureRect = $Hold
@onready var hold_color: TextureRect = $Hold/Color

static func get_note_vector_array(receptor_count: int) -> Array:
	return note_texture_arrays[str(min(receptor_count, note_texture_arrays.size()))]

func _ready() -> void:
	for rect: TextureRect in [head, head_color, hold, hold_color]:
		rect.texture = rect.texture.duplicate()
	
	class_icon.texture = EditorTimeline.instance.get_script_icon(note.get_script())
	
	ChartEditor.instance.selection_updated.connect(func():
		update_selection()
	)
	
	update_selection()

func update_selection():
	#modulate.a = 0.75 if ChartEditor.selection.has(note) else 1.0
	#print("pls", ChartEditor.selection.has(note))
	for node in [head, head_color, hold, hold_color]:
		node.set_instance_shader_parameter("selected", ChartEditor.selection.has(note))

func update_visuals(columns: int, pixels_per_second: float, timing_revision: int, preview: bool = false) -> void:
	var state := [direction, columns, note.time, note.length, pixels_per_second, timing_revision, preview]
	if state == _visual_state:
		return

	_visual_state = state

	var note_size := ChartEditor.instance.settings.NOTE_SIZE
	var textures := get_note_vector_array(columns)
	var column: int = textures[direction % textures.size()]
	var head_region := Rect2(column * note_size, note_size, note_size, note_size)
	var hold_region := Rect2(column * note_size, note_size * 2, note_size, note_size)

	(head.texture as AtlasTexture).region = head_region
	(head_color.texture as AtlasTexture).region = head_region
	(hold.texture as AtlasTexture).region = hold_region
	(hold_color.texture as AtlasTexture).region = hold_region

	var color: Color = ChartEditor.get_quant_color(note.time)
	head_color.modulate = color
	hold_color.modulate = color
	head_color.visible = not preview
	hold_color.visible = not preview

	color.a = 0.75 if preview else 1.0
	head.modulate = color if preview else Color.WHITE
	hold.modulate = color if preview else Color.WHITE

	hold.visible = note.length > 0.0
	hold.size = Vector2(note_size, maxf(0.0, note.length * pixels_per_second))
	hold_color.size = hold.size

# THIS IS SO GAYY
func _on_note_gui_input(event):
	if !note: 
		return
	
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_LEFT && event.shift_pressed:
			if ChartEditor.selection.has(note):
				ChartEditor.remove_from_selection(note)
			else:
				ChartEditor.add_to_selection(note)
			accept_event()
		elif event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			remove_note()
			accept_event()

func remove_note():
	if !receptor.notes.has(note): return
	
	note_placer.remove_note(direction, note.time)
