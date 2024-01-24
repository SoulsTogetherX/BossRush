extends State

const SHOCK_WAVE : PackedScene = preload("res://src/characters/bosses/The End/Slam_wave/slam_wave.tscn");

@export var over_offset : float = 100.0;
@export var over_player : State;

var _enact_position : Vector2;
var _fall_tween : Tween;

var _hold : bool;
var _pause_time : float;

func get_id():
	return "slam";

func enter() -> void:
	_actor.toggle_trail(true);
	_actor.disable = true;
	_animationPlayer.play("slam");
	_enact_position = _actor.get_hold_position();
	_pause_time = _actor.get_hold_time();
	
	_fall_tween = create_tween().set_parallel();
	_fall_tween.tween_method(fall_hand.bind(_actor.global_position), 0.0, 1.0, _actor._slam_speed);
	_fall_tween.tween_property(_actor, "rotation_degrees", 0.0, 0.2);
	
	_hold = false;
	
func exit() -> void:
	_actor.toggle_trail(false);
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
		
		if _actor._slam_type == Hand_TheEndBoss.SLAM_TYPE.WAVE_SLAM:
			create_shock_wave();
		else:
			PlayerInfo.cam.shake_event(Vector3(0.1, 0.1, 0.0), Vector3(7.0, 7.0, 0.0));
			_actor._floor.apply_force(10, _actor.global_position.x);
		
		_animationPlayer.play("slam_bounce");
		if _pause_time == 0:
			get_tree().physics_frame.connect(_stateOverhead.update, CONNECT_ONE_SHOT | CONNECT_DEFERRED);
		else:
			get_tree().create_timer(_pause_time).timeout.connect(_stateOverhead.update, CONNECT_ONE_SHOT | CONNECT_DEFERRED);
		return null;
	
	if _actor._slam_type == Hand_TheEndBoss.SLAM_TYPE.PLAYER_SLAM:
		_enact_position = _enact_position.lerp(PlayerInfo.player.global_position, 0.01);
	
	return null;

func fall_hand(interval : float, start : Vector2) -> void:
	_actor.global_position = start.lerp(_enact_position, interval);
	_actor._shadow.global_position = _actor.global_position + (Vector2.DOWN * over_offset * (1.0 - interval));

func create_shock_wave() -> void:
	var wave : Node2D = SHOCK_WAVE.instantiate();
	wave.global_position = _enact_position;
	wave.wave_time = 0.5;
	wave.fade_time = 0.1;
	wave.radius = 180;
	
	get_tree().current_scene.add_child(wave);
	
	PlayerInfo.cam.shake_event(Vector3(0.5, 0.5, 0.5), Vector3(15.0, 15.0, 360.0));

func update() -> State:
	return over_player;
