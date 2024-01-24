extends State

@export var idle : State;
@export var follow_leader : State;

var _target : ExchangeType;

func get_id():
	return "walk";

func enter() -> void:
	_actor._animation_player.play("idle");
	_stateOverhead.update();

func exit() -> void:
	if _target && is_instance_valid(_target):
		if _target.killed.is_connected(_stateOverhead.update):
			_target.killed.disconnect(_stateOverhead.update);
		if _target.change_hit_status.is_connected(_stateOverhead.update):
			_target.change_hit_status.disconnect(_stateOverhead.update);

func process_physics(delta: float) -> State:
	if !is_instance_valid(_target):
		return idle;
	
	_actor._handle_movement(delta, _actor, _actor.global_position, (_target.get_center() - _actor.global_position).normalized());
	if !_actor.velocity.is_zero_approx():
		_actor._sprite.flip_h = (_actor.velocity.x >= 0);
	return null;

func update() -> State:
	if _target && is_instance_valid(_target):
		if _target.killed.is_connected(_stateOverhead.update):
			_target.killed.disconnect(_stateOverhead.update);
		if _target.change_hit_status.is_connected(_stateOverhead.update):
			_target.change_hit_status.disconnect(_stateOverhead.update);
	
	var targets : Array[Node2D] = _actor._target.get_minons();
	if _actor._target.hitable():
		targets.append(_actor._target);
	if targets.is_empty():
		return follow_leader;
	
	var distance_min : float = INF;
	for t in targets:
		var dist : float = t.global_position.distance_squared_to(_actor.global_position);
		if dist < distance_min:
			distance_min = dist;
			_target = t;
	_target.killed.connect(_stateOverhead.update, CONNECT_ONE_SHOT | CONNECT_DEFERRED);
	_target.change_hit_status.connect(_stateOverhead.update, CONNECT_ONE_SHOT | CONNECT_DEFERRED);
	return null;
