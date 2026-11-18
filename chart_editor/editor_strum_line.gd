extends VBoxContainer
class_name EditorStrumLine

@onready var note_area: ColorRect = $NotePlacer

var _receptor_nodes: Array[TextureRect] = []
var _receptor_count: int = -1

var strumline: StrumLine

var muted: bool = false:
	set(value):
		muted = value
		
		var vocal_layer = ChartLoader.instance.vocal_layers[ChartEditor.instance.chart.strum_lines.find(strumline)]
		ChartEditor.song_audio_player.stream.set_sync_stream_volume(vocal_layer, -50 if muted else 0)

func load_strumline(p_strumline: StrumLine):
	strumline = p_strumline

func _process(_delta: float) -> void:
	if strumline == null:
		return

	var count := strumline.receptors.size()
	var note_size := ChartEditor.instance.settings.NOTE_SIZE
	note_area.custom_minimum_size.x = count * note_size

	if count != _receptor_count:
		for node in _receptor_nodes:
			note_area.remove_child(node)
			node.queue_free()
		_receptor_nodes.clear()

		for dir in count:
			var node := TextureRect.new()
			var texture := AtlasTexture.new()
			texture.atlas = EditorNote.NOTES
			var textures := EditorNote.get_note_vector_array(count)
			texture.region = Rect2(textures[dir % textures.size()] * note_size, 0, note_size, note_size)
			node.texture = texture
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE
			note_area.add_child(node)
			_receptor_nodes.append(node)
		_receptor_count = count

	var timeline := ChartEditor.instance.timeline
	var receptor_y := (note_area.get_global_transform().affine_inverse() * timeline.work_area.get_global_transform() * Vector2(0.0, timeline.receptor_y_pos)).y

	for dir in count:
		_receptor_nodes[dir].position = Vector2(dir * note_size, receptor_y - note_size / 2.0)
