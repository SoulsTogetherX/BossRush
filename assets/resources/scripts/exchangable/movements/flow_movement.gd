class_name FlowMovement extends MovementExchangable

@export var speed : int = 200;
@export_range(0.01, 1.0, 0.01, "hide_slider") var friction : float = 0.3;

func enact_move(_delta : float, _actor : ExchangeType, _from : Vector2, move_dir : Vector2) -> bool:
	if move_dir.is_zero_approx():
		return false;
	
	_actor.velocity = _actor.velocity.lerp(move_dir * speed, friction);
	_actor.move_and_slide();
	
	return true;
