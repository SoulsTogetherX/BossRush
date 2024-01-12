extends Area2D

var ignore : bool = false;

func _on_body_entered(body: Player) -> void:
	if !body || ignore:
		ignore = false;
		return;
	
	var ballon = load("res://Dialog/TextBalloon/balloon.tscn").instantiate();
	get_tree().current_scene.add_child(ballon);
	ballon.start(load("res://Dialog/Test/test_1.dialogue"), "start");
	
	PlayerInfo.player.process_mode = Node.PROCESS_MODE_DISABLED;
	PlayerInfo.weapon.process_mode = Node.PROCESS_MODE_DISABLED;
	
	await DialogueManager.dialogue_ended;
	
	PlayerInfo.player.process_mode = Node.PROCESS_MODE_INHERIT;
	PlayerInfo.weapon.process_mode = Node.PROCESS_MODE_INHERIT;
	
	ignore = true;
