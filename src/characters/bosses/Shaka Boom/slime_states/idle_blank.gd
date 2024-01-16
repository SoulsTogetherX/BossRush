extends State

func get_id():
	return "idle";

func enter() -> void:
	_actor._animation_player.play("idle");
