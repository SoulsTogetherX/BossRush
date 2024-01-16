extends State

@export var idle : State;

func get_id():
	return "walk";

func enter() -> void:
	_actor._animation_player.play("idle");

func process_physics(delta: float) -> State:
	var target : ExchangeType;
	var targets : Array[ExchangeType] = _actor._target.get_minons();
	if _actor._target is Player || _actor._target.hitable():
		targets.append(_actor._target);
	if targets.is_empty():
		return null;
	
	var distance_min : float = INF;
	for t in targets:
		var dist : float = t.global_position.distance_squared_to(_actor.global_position);
		if dist < distance_min:
			distance_min = dist;
			target = t;
	
	_actor._handle_movement(delta, _actor, _actor.global_position, (target.get_center() - _actor.global_position).normalized());
	if !_actor.velocity.is_zero_approx():
		_actor._sprite.flip_h = (_actor.velocity.x >= 0);
	return null;
