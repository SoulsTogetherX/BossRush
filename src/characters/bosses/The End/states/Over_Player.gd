extends State

@export var over_offset : float = 100.0;

var _height : float;
var _rise_tween : Tween;

func get_id():
	return "over_hold";

func enter() -> void:
	_actor.change_move_type(_actor.STATE.STATIONARY);
	_animationPlayer.stop();
	_animationPlayer.play("slam");
	
	_height = 0.0;
	
	_rise_tween = create_tween().set_parallel();
	_rise_tween.tween_property(_actor, "scale", Vector2.ONE, 0.5);
	_rise_tween.tween_property(_actor, "rotation_degrees", 15.0 * (-1 if _actor.right else 1), 0.5);

func exit() -> void:
	if _rise_tween:
		_rise_tween.kill();

func process_physics(_delta: float) -> State:
	_height = lerpf(_height, over_offset, _actor.lerp_coefficent);
	
	_actor._shadow.global_position = _actor.global_position + Vector2.DOWN * _height;
	_actor.enact_position = _actor.get_hold_position() + Vector2.UP * over_offset;
	return null;

