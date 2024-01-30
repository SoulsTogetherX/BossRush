extends Control

signal play;
signal settings;
signal credits;

func _on_play_pressed() -> void:
	play.emit();

func _on_settings_pressed() -> void:
	settings.emit();

func _on_credits_pressed() -> void:
	credits.emit();

func _on_quit_pressed() -> void:
	get_tree().quit();

func _difficulty_changed(index: int) -> void:
	PlayerInfo.hard_mode = index;
