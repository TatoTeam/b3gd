extends Node

@export var thing_to_animate: Node
@export var strumline: int

@export_group("Animation Names")
@export var idle_anim_order: Array[String] = ["idle"]
@export var note_directions: Array[String] = ["left", "down", "up", "right"]
@export var miss_sound: AudioStreamPlayer

@export_subgroup("Prefixes")
@export var sing_prefix = "sing_"
@export var miss_prefix = "miss_"
@export var added_suffix: String = ""

@export_group("Playback")
@export var playback_speed: float = 1.0

@export_subgroup("Idle")
@export var ignore_idle: bool = false
@export var only_idle_when_finished: bool = true
@export var idle_divisor = 1

@export_subgroup("Sing")
@export var ignore_sing: bool = false
@export var sing_length = 1.0
@export var hold_speed: float = 0.0

@export_subgroup("Miss")
@export var ignore_miss: bool = false

enum AnimationType {
	ANIMATION_NONE,
	ANIMATION_IDLE,
	ANIMATION_SING,
	ANIMATION_MISS,
	ANIMATION_EXTERNAL # changed from somewhere else
}

var idle_anim_idx = 0
var time_since_last_sing = 0.0

var current_anim = {"type": AnimationType.ANIMATION_NONE, "id": 0}
var anim_changed = null

func _ready() -> void:
	var song_audio_player = SongAudioPlayer.instance
	if song_audio_player == null:
		return
	
	song_audio_player.beat_hit.connect(beat_hit)
	var note_manager = NoteManager.instance
	
	note_manager.note_press.connect(note_press)
	note_manager.note_miss.connect(note_miss)
	
	if thing_to_animate is AnimationPlayer:
		thing_to_animate.current_animation_changed.connect(animation_player_animation_changed)
	else:
		thing_to_animate.animation_changed.connect(animated_sprite_animation_changed)

func _process(delta: float) -> void:
	if anim_changed != null:
		anim_changed = null
	
	if time_since_last_sing > sing_length and thing_to_animate.speed_scale != playback_speed:
		thing_to_animate.speed_scale = playback_speed
	
	time_since_last_sing += delta

func beat_hit(beat: int) -> void:
	if time_since_last_sing < sing_length or ignore_idle:
		return
	
	if current_anim.type == AnimationType.ANIMATION_EXTERNAL:
		return
	
	if thing_to_animate.is_playing():
		if current_anim.type == AnimationType.ANIMATION_IDLE:
			if only_idle_when_finished:
				return
		else:
			return
	
	if beat % idle_divisor != 0:
		return
	
	idle_anim_idx = (idle_anim_idx + 1) % idle_anim_order.size()
	
	play_animation(AnimationType.ANIMATION_NONE)
	play_animation(AnimationType.ANIMATION_IDLE, idle_anim_idx, added_suffix)
	
	current_anim.type = AnimationType.ANIMATION_IDLE
	current_anim.id = idle_anim_idx

func note_press(strum_line_id: int, receptor_id: int, note: Note, _hold_delta: float) -> void:
	if strumline != strum_line_id or ignore_sing: return
	if note == null or note is NoteIgnore: return
	
	time_since_last_sing = sing_length if note.hold_pressed else 0.0
	
	var suffix = added_suffix
	if note is NoteSuffix:
		suffix = note.suffix
	
	if current_anim.type == AnimationType.ANIMATION_SING and note.hold_pressed:
		thing_to_animate.speed_scale = hold_speed * playback_speed
	else:
		play_animation(AnimationType.ANIMATION_NONE)
		play_animation(AnimationType.ANIMATION_SING, receptor_id, suffix)

func note_miss(strum_line_id: int, receptor_id: int, _note: Note) -> void:
	if strumline != strum_line_id or ignore_miss: 
		return
	
	if miss_sound != null:
		miss_sound.play()
	
	play_animation(AnimationType.ANIMATION_MISS, receptor_id)


func play_animation(type: AnimationType, id:int = 0, suffix: String = ""):
	current_anim.type = type
	current_anim.id = id
	anim_changed = current_anim
	var animation_name = ""
	match type:
		AnimationType.ANIMATION_NONE:
			if thing_to_animate is AnimationPlayer:
				thing_to_animate.stop(true)
			else:
				thing_to_animate.stop()
		
		AnimationType.ANIMATION_IDLE:
			animation_name = idle_anim_order[id]
		
		AnimationType.ANIMATION_SING:
			id = id % note_directions.size()
			animation_name = sing_prefix + note_directions[id]
		
		AnimationType.ANIMATION_MISS:
			id = id % note_directions.size()
			animation_name = miss_prefix + note_directions[id]
		
		AnimationType.ANIMATION_EXTERNAL:
			printerr("Trying to play an external animation here kinda just does nothing")
	
	if animation_name == "":
		return
	
	var suffix_valid = true
	if thing_to_animate is AnimatedSprite2D:
		suffix_valid = thing_to_animate.sprite_frames.get_animation_names().has(animation_name + suffix)
	elif thing_to_animate is AnimationPlayer:
		suffix_valid = thing_to_animate.get_animation_list().has(animation_name + suffix)
	
	thing_to_animate.speed_scale = playback_speed
	
	if suffix_valid:
		thing_to_animate.play(animation_name + suffix)
	else:
		thing_to_animate.play(animation_name)

func animated_sprite_animation_changed():
	if anim_changed == null:
		current_anim.type = AnimationType.ANIMATION_EXTERNAL

func animation_player_animation_changed(anim_name):
	if anim_changed == null and anim_name != "":
		current_anim.type = AnimationType.ANIMATION_EXTERNAL
