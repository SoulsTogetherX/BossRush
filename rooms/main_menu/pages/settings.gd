extends Control

signal main;

func _ready() -> void:
	$VBoxContainer/MasterContainer/VBoxContainer/Slider.value = db_to_linear(AudioServer.get_bus_volume_db(0));
	$VBoxContainer/MusicContainer/VBoxContainer/Slider.value = db_to_linear(AudioServer.get_bus_volume_db(1));
	$VBoxContainer/SoundContainer/VBoxContainer/Slider.value = db_to_linear(AudioServer.get_bus_volume_db(2));
	
func _on_main_pressed() -> void:
	main.emit();

func change_master(value : float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value));

func change_music(value : float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value));

func change_sound(value : float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value));
