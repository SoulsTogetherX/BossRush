class_name Emitter extends AudioStreamPlayer

@export var audios : Array[AudioStream];

func play_random():
	if audios.size() > 0:
		stream = audios[randi() % audios.size()];
		play();
