extends AudioStreamPlayer
class_name SongAudioPlayer
static var instance: SongAudioPlayer

signal beat_hit(beat: int)

var bpm_events: Array[EventBPMChange] = []

var paused = false

var _song_position_raw: float:
	get():
		var mix_adj = (AudioServer.get_time_since_last_mix() - output_latency)
		var true_prog = get_playback_position() + (mix_adj * pitch_scale)
		return true_prog

var song_position_seconds = 0:
	set(value):
		var previous_beat = song_position_beats
		song_position_seconds = value
		var new_beat = song_position_beats
		if floor(previous_beat) != floor(new_beat):
			beat_hit.emit(floor(new_beat))
		
		if song_position_seconds >= 0 and playing:
			return
		
		if song_position_seconds < 0 and playing:
			stop()
		
		elif song_position_seconds >= 0 and !paused and !playing:
			if song_position_seconds > 0.08: # if its only a little off it just retimes it
				play(song_position_seconds)
				force_resync.call_deferred()
			else:
				play()

var song_length_seconds: float = 0:
	get():
		return stream.get_length()

var _paused_position = 0.0
var force_sync = false

var bpm_events_index:
	get():
		var result = 0
		for bpm_index_check in range(bpm_events.size()):
			if bpm_events[bpm_index_check].time < song_position_seconds:
				result = bpm_index_check
		return result

var bpm:
	get():
		return bpm_events[bpm_events_index].bpm

var bpm_start_second:
	get():
		return bpm_events[bpm_events_index].time

var song_position_beats:
	get():
		var beat_since_beat_start = (bpm / 60) * (song_position_seconds - bpm_start_second)
		return beat_since_beat_start + get_beat_carry(bpm_events_index)

@onready var output_latency = AudioServer.get_output_latency()
@onready var scrub_timer = Timer.new()

func get_beat_carry(bpm_index: int):
	var add_beat = 0
	var last_data = [0, 0]
	for i in range(bpm_index + 1):
		add_beat += (last_data[1] / 60.0) * (bpm_events[i].time - last_data[0])
		last_data = [bpm_events[i].time, bpm_events[i].bpm]
	return add_beat

func get_seconds_from_beat(beat: float):
	var bpm_event = {"event": bpm_events[0], "carry": get_beat_carry(0)}
	for i in range(bpm_events.size()):
		if get_beat_carry(i) <= beat:
			bpm_event.event = bpm_events[i]
			bpm_event.carry = get_beat_carry(i)
	return ((beat - bpm_event.carry) / (bpm_event.event.bpm / 60)) + bpm_event.event.time

func get_beat_from_seconds(seconds: float):
	var last_bpm_index = 0
	while last_bpm_index < bpm_events.size():
		if bpm_events[last_bpm_index].time >= seconds:
			break
		last_bpm_index += 1
	last_bpm_index = max(0, last_bpm_index - 1)
	var bpm_event = bpm_events[last_bpm_index]
	return get_beat_carry(last_bpm_index) + ((seconds - bpm_event.time) * (bpm_event.bpm / 60))

func _init() -> void:
	instance = self

func _ready() -> void:
	add_child(scrub_timer)

func _process(delta: float) -> void:
	if paused:
		song_position_seconds = _paused_position
		return
	
	if song_position_seconds < 0:
		var next_prog = song_position_seconds + (delta * int(!paused) * pitch_scale)
		song_position_seconds = min(next_prog, 0)
		return
	
	song_position_seconds = max(_song_position_raw, song_position_seconds + (delta * 0.9 * pitch_scale))

func force_resync():
	var mix_adj = (AudioServer.get_time_since_last_mix() - output_latency)
	var true_prog = get_playback_position() + (mix_adj * pitch_scale)
	song_position_seconds = max(true_prog, 0)

func pause():
	if paused:
		return
	paused = true
	if song_position_seconds >= 0:
		_paused_position = get_playback_position()
		stop()
	else:
		_paused_position = song_position_seconds

func unpause():
	if !paused:
		return
	paused = false
	song_position_seconds = _paused_position
	if _paused_position >= 0:
		play(song_position_seconds)
		force_resync.call_deferred()

func track_seek(new_position: float, paused_scrub_time:float = 0):
	_paused_position = new_position
	if _paused_position < 0:
		song_position_seconds = _paused_position
		return
	
	force_resync.call_deferred()
	if paused:
		if !scrub_timer.is_stopped():
			scrub_timer.timeout.emit()
			scrub_timer.stop()
		play(_paused_position)
		scrub_timer.start(paused_scrub_time)
		await scrub_timer.timeout
		if paused:
			stop()
	else:
		play(_paused_position)

func on_finished() -> void:
	force_sync = true

func on_event_pre_init() -> void:
	bpm_events = []
