extends Area2D

func _on_body_entered(body: Node2D) -> void:
	DialogueManager.show_example_dialogue_balloon(load("res://Dialog/Test/test_1.dialogue"), "start");
