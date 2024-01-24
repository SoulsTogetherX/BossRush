extends State

@export var over_offset : float = 100.0;
@export var over_player : State;

var _enact_position : Vector2;
var _fall_tween : Tween;

var _hold : bool;
var _end_pos : Vector2;

func get_id():
	return "slam_straight";

func enter() -> void:
	_actor.disable = true;
	_animationPlayer.play("slam");
	_enact_position = _actor.get_hold_position();
	
	_fall_tween = create_tween().set_parallel();
	_fall_tween.tween_method(fall_hand.bind(_actor.global_position), 0.0, 1.0, 0.25);
	_fall_tween.tween_property(_actor, "rotation_degrees", 0.0, 0.2);
	
	_hold = false;
	
func exit() -> void:
	_actor.disable = false;
	_actor.toggle_slambox(false);
	if _fall_tween:
		_fall_tween.kill();

func process_physics(_delta: float) -> State:
	if _hold:
		return;
	
	if _enact_position.distance_squared_to(_actor.global_position) < 10:
		_actor.toggle_slambox(true);
		_hold = true;
		get_tree().physics_frame.connect(_stateOverhead.update, CONNECT_ONE_SHOT | CONNECT_DEFERRED);
		return null;
	
	return null;

func fall_hand(interval : float, start : Vector2) -> void:
	_actor.global_position = start.lerp(_enact_position, interval);
	_actor._shadow.global_position = _actor.global_position + (Vector2.DOWN * over_offset * (1.0 - interval));

func update() -> State:
	return over_player;
