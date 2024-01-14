@tool
class_name BurstMovement extends HitMovement

@export var duration : float = 0.2;

func enact_move(_delta : float, actor : ExchangeType, _from : Vector2, move_dir : Vector2) -> bool:
	if on_cooldown:
		return false;
	
	if !is_busting && !on_cooldown:
		if move_dir.is_zero_approx():
			return false;
		
		is_busting = true;
		
		actor.velocity = move_dir * speed;
		actor.move_and_slide();
		
		if _incincible:
			_incincible.start(actor.get_tree())
		if duration > 0:
			_timer1 = actor.get_tree().create_timer(duration);
			_timer1.timeout.connect(_end_dash.bind(actor));
		return true;
	
	if in_burst_control:
		actor.velocity = (actor.velocity + (move_dir * speed * burst_control_ratio)).normalized() * speed;
	
	actor.move_and_slide();
	return true;
