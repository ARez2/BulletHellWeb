extends AudioStreamPlayer
class_name RandomizedAudioPlayer
export(float, 0, 1) var PitchRandomizeVal = 0.2

var DefaultPitch = 1.0

func _ready() -> void:
	DefaultPitch = pitch_scale

func play(from_pos : float = 0.0) -> void:
	pitch_scale = rand_range(DefaultPitch - PitchRandomizeVal, DefaultPitch + PitchRandomizeVal)
	.play(from_pos)
	playing = true
