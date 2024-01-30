@tool
class_name FloatObjectControl extends Node2D

@export_group("Sprite manipulation")
@export var right : bool = false:
	set(val):
		if get_node_or_null("Sprite2D") != null:
			$Sprite2D.flip_h = val;
		right = val;

@export_group("Standard positioning")
@export var disable : bool = false;

@export var rest_offset : Vector2 = Vector2.ZERO:
	set(val):
		rest_offset = val;
		enact_position = val;

@export var time_offset : float = 0.0:
	set(val):
		time_offset = val;
		_time = val;

@export_range(0.0, 1.0, 0.001) var lerp_coefficent : float = 0.1;

@export var act_on_local : bool = true;
var enact_position : Vector2 = Vector2.ZERO;

var _desired_position : Vector2 = Vector2.ZERO;

enum STATE {STATIONARY, IDLE};
@export var _state : STATE = STATE.IDLE;

var _time : float = 0.0;

var _fall : bool = false;
var _fall_speed : Vector2 = Vector2(0.1, 1);

# IDLE_VALUES
@export_group("idle")
@export var min_h_oscillator : float = 3.0;
@export var max_h_oscillator : float = 7.0

@export var min_v_oscillator : float = 8.0;
@export var max_v_oscillator : float = 12.0

@export var min_h_oscillation : float = 0.9;
@export var max_h_oscillation : float = 1.1;

@export var min_v_oscillation : float = 0.9;
@export var max_v_oscillation : float = 1.1;

var _h_oscillator : float;
var _h_oscillation : float;

var _v_oscillator : float;
var _v_oscillation : float;

func _ready() -> void:
	if get_tree().edited_scene_root != null && get_tree().edited_scene_root == self:
		set_physics_process(false);
		return;
	
	if get_parent() is FloatObjectControl:
		await get_parent().ready;
		if get_node_or_null("Sprite2D") != null:
			$Sprite2D.flip_h = get_parent().right;
	elif get_node_or_null("Sprite2D") != null:
		$Sprite2D.flip_h = right;
	top_level = true;
	change_move_type(_state);

func fall() -> void:
	_fall = true;

func _physics_process(delta: float) -> void:
	if _fall:
		rotation_degrees += 0.1 * (-1 if right else 1);
		
		position.x += _fall_speed.x * (-1 if right else 1);
		position.y += _fall_speed.y;
		return;
	if disable:
		return;
	
	_time += delta;
	
	move_position();
	update_desired_position();

func move_position() -> void:
	if get_parent() == null:
		return;
	
	if get_parent() is ExchangeType:
		global_position = global_position.lerp(_desired_position + (int(act_on_local) * get_parent().get_center()), lerp_coefficent);
	elif get_parent() is Node2D:
		global_position = global_position.lerp(_desired_position + (int(act_on_local) * get_parent().global_position), lerp_coefficent);

func update_desired_position() -> void:
	match _state:
		STATE.STATIONARY:
			_desired_position = enact_position
		STATE.IDLE:
			_desired_position = enact_position;
			_desired_position.x += cos(_time * _h_oscillation) * _h_oscillator * (-1 if right else 1);
			_desired_position.y += sin(_time * _v_oscillation) * _v_oscillator;

func change_move_type(new_state : STATE) -> void:
	_state = new_state;
	_time = time_offset;
	
	match _state:
		STATE.STATIONARY:
			pass;
		STATE.IDLE:
			_h_oscillator = (randf() * (max_h_oscillator - min_h_oscillator)) + min_h_oscillator;
			_v_oscillator = (randf() * (max_v_oscillator - min_v_oscillator)) + min_v_oscillator;
			
			_h_oscillation = (randf() * (max_h_oscillation - min_h_oscillation)) + min_h_oscillation;
			_v_oscillation = (randf() * (max_v_oscillation - min_v_oscillation)) + min_v_oscillation;
