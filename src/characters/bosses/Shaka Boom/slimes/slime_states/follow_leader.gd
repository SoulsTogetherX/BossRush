extends State

@export var move : State;
@export var idle : State;

@warning_ignore("unused_private_class_variable")
var _target : ExchangeType;

func get_id():
	return "follow_leader";

func enter() -> void:
	_actor._animation_player.play("idle");
	_actor._leader.killed.connect(_stateOverhead.update, CONNECT_ONE_SHOT | CONNECT_DEFERRED);

func exit() -> void:
	if _actor._leader.killed.is_connected(_stateOverhead.update):
		_actor._leader.killed.disconnect(_stateOverhead.update);

func process_physics(delta: float) -> State:
	if _actor._target.hitable() || _actor._target.get_minons().size() > 0:
		return move;
	
	var dir_vec : Vector2 = _actor._leader.get_center() - _actor.global_position;
	if dir_vec.length_squared() < _actor.follow_distance:
		return idle;
	
	_actor._handle_movement(delta, _actor, _actor.global_position, dir_vec.normalized());
	if !_actor.velocity.is_zero_approx():
		_actor._sprite.flip_h = (_actor.velocity.x >= 0);
	return null;

func update() -> State:
	return idle;
	
