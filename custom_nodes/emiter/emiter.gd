class_name Emitter extends AudioStreamPlayer2D

@export var _particles : CPUParticles2D = null;
@export var audios : Array[AudioStream];

func play_random():
	if _particles != null:
		_particles.emitting = true;
	
	if audios.size() > 0:
		stream = audios[randi() % audios.size()];
		play();
