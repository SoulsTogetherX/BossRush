extends State

func get_id():
	return "dead";

func enter() -> void:
	_actor._animation_player.play("dead");
