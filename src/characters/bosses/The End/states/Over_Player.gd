extends State

@export var over_offset : float = 100.0;

var _height : float;

func get_id():
	return "over_hold";

func enter() -> void:
	_actor.change_move_type(_actor.STATE.STATIONARY);
	_animationPlayer.play("slam");
	
	_height = 0.0;
	
	var tw : Tween;
	tw = create_tween().set_parallel();
	tw.tween_property(_actor, "scale", Vector2.ONE, 0.5);
	tw.tween_property(_actor, "rotation_degrees", 15.0 * (-1 if _actor.right else 1), 0.5);

func process_physics(_delta: float) -> State:
	_height = lerpf(_height, over_offset, _actor.lerp_coefficent);
	
	_actor._shadow.global_position = _actor.global_position + Vector2.DOWN * _height;
	_actor.enact_position = _actor.get_hold_position() + Vector2.UP * over_offset;
	return null;

