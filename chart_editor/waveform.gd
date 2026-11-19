extends Control

var vocal_peaks: Dictionary[AudioStream, PackedFloat32Array] = {}
var _waveform_playbacks: Dictionary[AudioStream, AudioStreamPlayback] = {}
var _waveform_frames: Dictionary[AudioStream, int] = {}

const WAVEFORM_RES := 256
const WAVEFORM_COLOR := Color(0.5, 1.0, 0.5, 1.0)
const WAVEFORM_MIX_FRAMES := 16384

func _get_vocal_stream(strumline: StrumLine) -> AudioStream:
	var index := ChartEditor.instance.chart.strum_lines.find(strumline)
	if index < 0 or index >= ChartLoader.instance.vocal_layers.size():
		return null

	var stream_sync := ChartEditor.song_audio_player.stream as AudioStreamSynchronized
	var vocal_layer := ChartLoader.instance.vocal_layers[index]
	if stream_sync == null or vocal_layer < 0 or vocal_layer >= stream_sync.stream_count:
		return null
	return stream_sync.get_sync_stream(vocal_layer)

func _get_waveform(stream: AudioStream) -> PackedFloat32Array:
	if not vocal_peaks.has(stream):
		var peaks := PackedFloat32Array()
		peaks.resize(ceili(stream.get_length() * WAVEFORM_RES))
		vocal_peaks[stream] = peaks

		if not peaks.is_empty():
			var playback := stream.instantiate_playback()
			if playback != null:
				playback.start()
				_waveform_playbacks[stream] = playback
				_waveform_frames[stream] = 0

	return vocal_peaks[stream]

func _update_waveforms() -> void:
	for stream in _waveform_playbacks.keys():
		var playback := _waveform_playbacks[stream]
		var first := _waveform_frames[stream]
		var mix_rate := AudioServer.get_mix_rate()
		var total_frames := ceili(stream.get_length() * mix_rate)
		var frames := playback.mix_audio(1.0, mini(WAVEFORM_MIX_FRAMES, total_frames - first))
		var peaks := vocal_peaks[stream]
	
		for i in frames.size():
			var column := mini(int((first + i) * WAVEFORM_RES / mix_rate), peaks.size() - 1)
			var frame := frames[i]
			peaks[column] = maxf(peaks[column], maxf(absf(frame.x), absf(frame.y)))
		
		vocal_peaks[stream] = peaks
		_waveform_frames[stream] = first + frames.size()
		if frames.is_empty() or _waveform_frames[stream] >= total_frames:
			playback.stop()
			_waveform_playbacks.erase(stream)
			_waveform_frames.erase(stream)
		
		break

func _exit_tree() -> void:
	for playback in _waveform_playbacks.values():
		playback.stop()

func _process(delta: float) -> void:
	for strumline in get_parent().strum_line_container.strumlines:
		if not strumline.waveform or strumline.strumline == null:
			continue
		
		var stream := _get_vocal_stream(strumline.strumline)
		if stream != null:
			_get_waveform(stream)
	
	_update_waveforms()
	queue_redraw()

func _draw():
	RenderingServer.canvas_item_set_custom_rect(get_canvas_item(), false)
	
	if ChartEditor.instance.chart == null or ChartEditor.song_audio_player == null or get_parent().pixels_per_second <= 0.0:
		return
	
	for strumline in get_parent().strum_line_container.strumlines:
		if not strumline.waveform or strumline.strumline == null:
			continue
		
		var stream := _get_vocal_stream(strumline.strumline)
		if stream == null or not vocal_peaks.has(stream):
			continue
		var peaks := vocal_peaks[stream]
		if peaks.is_empty():
			continue
		
		var area = strumline.note_area
		var top_left = get_parent().global_to_timeline(area.global_position)
		var bottom_right = get_parent().global_to_timeline(area.global_position + area.size)
		bottom_right.y = minf(bottom_right.y, get_parent().time_to_y(stream.get_length()))
		var center_x = (top_left.x + bottom_right.x) * 0.5
		var half_width = (bottom_right.x - top_left.x) * 0.5
		var first := clampi(floori(get_parent().y_to_time(top_left.y) * WAVEFORM_RES), 0, peaks.size())
		var last := clampi(ceili(get_parent().y_to_time(bottom_right.y) * WAVEFORM_RES), 0, peaks.size())
		
		var column := first
		
		while column < last:
			var y := maxf(top_left.y, get_parent().time_to_y(float(column) / WAVEFORM_RES))
			var next := clampi(ceili(get_parent().y_to_time(y + 1.0) * WAVEFORM_RES), column + 1, last)
			var peak := 0.0
			for i in range(column, next):
				peak = maxf(peak, peaks[i])
			peak = clampf(peak, 0.0, 1.0)
			
			var width = peak * half_width
			var height = minf(bottom_right.y, get_parent().time_to_y(float(next) / WAVEFORM_RES)) - y
			var color = Color(WAVEFORM_COLOR * remap(peak, 0.0, 0.2, 0.6, 1.0), 1.0)
			draw_rect(Rect2(center_x - width, y, width * 2.0, height), color)
			column = next
