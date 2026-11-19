@icon("uid://dry7kpcv8y0k1")
class_name EventBPMChange extends Event

@export_range(1.0, 300.0, 0.0, "or_greater") var bpm: float = 120

func init():
	SongAudioPlayer.instance.bpm_events.append(self)

func play(_speed: float = 1.0):
	pass
