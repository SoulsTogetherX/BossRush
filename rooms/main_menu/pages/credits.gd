extends Control

signal main;

func _on_main_pressed() -> void:
	main.emit();
