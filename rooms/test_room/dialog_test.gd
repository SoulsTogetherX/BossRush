extends Area2D

var ignore : bool = false;

func _on_body_entered(body: Player) -> void:
	if !body || ignore:
		ignore = false;
		return;
	
	DialogueManager.show_example_dialogue_balloon(load("res://Dialog/Test/test_1.dialogue"), "start");
	
	PlayerInfo.player.process_mode = Node.PROCESS_MODE_DISABLED;
	PlayerInfo.weapon.process_mode = Node.PROCESS_MODE_DISABLED;
	
	await DialogueManager.dialogue_ended;
	
	PlayerInfo.player.process_mode = Node.PROCESS_MODE_INHERIT;
	PlayerInfo.weapon.process_mode = Node.PROCESS_MODE_INHERIT;
	
	ignore = true;
