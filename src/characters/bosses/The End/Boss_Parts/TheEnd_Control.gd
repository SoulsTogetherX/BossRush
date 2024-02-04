@tool
extends FloatObjectControl

@export var ending_animator : Node;
@export var intro_animator : Node;

@export var shadow_left : Sprite2D;
@export var shadow_right : Sprite2D;
@export var _floor : Sprite2D;
@export var arrow : Node2D;

var _back_up : bool = false;
var _position_x_addition : float;
var _time_delta : float = 0.0;
var dead : bool = false;

func _ready() -> void:
	super();
	if !Engine.is_editor_hint():
		$TheEnd.set_shadows(shadow_left, shadow_right);
		$TheEnd.set_floor(_floor);
		
		if PlayerInfo.flag == false:
			intro_animator.start_intro();
			await intro_animator.intro_start_finished;
		else:
			intro_animator.visible = false;
		
		$wind.volume_db = linear_to_db(0.5);
		$wind.play();

func die() -> void:
	PlayerInfo.can_reload = false;
	dead = true;
	disable = true;
	ending_animator.global_position = global_position + Vector2.UP * 60;
	ending_animator.scale = Vector2.ZERO;
	
	$wind.play();
	
	var tw : Tween = create_tween().set_parallel();
	tw.tween_method(DeathSounds.set_music_volume, 1.0, 0.2, 5.0);
	tw.tween_method(func(interval : float): $wind.volume_db = linear_to_db(interval), 0.0, 0.5, 5.0);
	
	tw = create_tween().set_parallel();
	tw.set_trans(Tween.TRANS_QUAD);
	tw.tween_property(ending_animator, "global_position", (global_position * 0.1) + (Vector2.UP * 60), 1.5);
	tw.tween_property(ending_animator, "global_position", Vector2.ZERO, 1.5).set_delay(1.5);
	tw.tween_property(ending_animator, "scale", Vector2(2.0, 2.0), 0.6);
	
	tw.chain().tween_property(ending_animator, "disable_click", false, 0.001);
	tw.tween_property(ending_animator, "disable", false, 0.001);

func fade_wind(time : float) -> void:
	var tw : Tween = create_tween();
	tw.tween_method(func(interval : float): $wind.volume_db = linear_to_db(interval), 0.5, 0.2, time);

func stop_wind() -> void:
	$wind.stop();

func finish_dead() -> void:
	ending_animator.queue_free();
	$TheEnd.death_animation();

func return_rest() -> void:
	move_all_compoents(Vector2(1500 * (-1 if randf() < 0.5 else 1), -100));
	rest_offset = Vector2(0, -100);
	change_move_type(FloatObjectControl.STATE.IDLE);
	_back_up = false;
	disable = false;

func hurt_action() -> void:
	rest_offset.x = position.x;
	change_move_type(FloatObjectControl.STATE.STATIONARY);
	disable = true;
	_back_up = true;
	_position_x_addition = 150;
	_time_delta = 0.0;
	
	$TheEnd/hurt_action.start();

func _physics_process(delta: float) -> void:
	if _back_up:
		position.y += -1000 * delta;
		_time_delta += delta;
		position.x = rest_offset.x + (_position_x_addition * snappedf(randf() * int(delta > 0), 0.2));
		_position_x_addition = lerp(_position_x_addition, 0.0, 1 - pow(0.05, delta));
	super(delta);
func end_hurt_action() -> void:
	_back_up = false;

func move_all_compoents(pos : Vector2) -> void:
	var diff : Vector2 = pos - position;
	position += diff;
	$TheEnd.move_all_compoents(diff);
