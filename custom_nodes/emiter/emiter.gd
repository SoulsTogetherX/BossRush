class_name Emitter extends AudioStreamPlayer

@export var audios : Array[AudioStream];
@export var varation : float = 0.0;
var base_pitch : float;

func _ready() -> void:
	base_pitch = pitch_scale;

func play_random():
	if audios.size() > 0:
		stream = audios[randi() % audios.size()];
		pitch_scale = base_pitch + (randf() * varation);
		play();
