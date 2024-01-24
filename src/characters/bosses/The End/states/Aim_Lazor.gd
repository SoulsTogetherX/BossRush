extends State

func get_id():
	return "aim_lazor";

func enter() -> void:
	_actor.z_index = -11;
	_actor.act_on_local = false;
	_animationPlayer.play("idle");
	
	var tw : Tween = create_tween();
	tw.tween_property(_actor, "rotation_degrees", 0.0, 0.2);

func process_physics(_delta: float) -> State:
	_actor.enact_position = Vector2(clampf(PlayerInfo.player.global_position.x, -300, 300), -85);
	_actor._shadow.global_position = _actor._shadow.global_position.lerp(_actor.global_position, _actor.lerp_coefficent * 0.8)
	return null;
