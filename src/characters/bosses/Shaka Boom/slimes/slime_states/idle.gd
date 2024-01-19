extends State

@export var move : State;
@export var follow_leader : State;

func get_id():
	return "idle";

func enter() -> void:
	_actor._animation_player.play("idle_real");

func process_physics(_delta: float) -> State:
	if _actor._target.hitable() || _actor._target.get_minons().size() > 0:
		return move;
	if _actor._leader && is_instance_valid(_actor._leader) && (_actor._leader.get_center() - _actor.global_position).length_squared() >= _actor.follow_distance:
		return follow_leader;
	return null;
