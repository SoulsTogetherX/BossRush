extends Node

func play(type : int) -> void:
	match type:
		0:
			$Leshy.play();
		1:
			$Shaka.play();
		2:
			$TheEnd.play();
		
func play_music(type : int, volume : float = 1.0) -> void:
	set_music_volume(volume);
	
	$Silence.stop();
	$Music_Crash.play();
	match type:
		0:
			$Leshy_Music.play();
		1:
			$Shaka_Music.play();
		2:
			$TheEnd_Music.play();

func stop_music()  -> void:
	$Leshy_Music.stop();
	$Shaka_Music.stop();
	$TheEnd_Music.stop();

func slience()  -> void:
	stop_music();
	$Silence.play();

func stop_slience()  -> void:
	$Silence.stop();

func set_music_volume(volume : float = 1.0) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(volume));
