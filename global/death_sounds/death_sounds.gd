extends Node

func play(type : int) -> void:
	match type:
		0:
			$Leshy.play();
		1:
			$Shaka.play();
		2:
			$TheEnd.play();
		
func play_music(type : int) -> void:
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
