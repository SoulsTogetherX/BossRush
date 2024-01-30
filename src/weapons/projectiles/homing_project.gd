@tool
class_name HomingProjectile extends Projectile

@export var drag_factor  : float = 0.07;
@export var target : Node2D = null;
@export var speed : float = 0.0;
var _angle : float = 0.0;
@export var angle : float = 0.0:
	get:
		return _angle;
	set(val):
		_angle = val;
		_angle_degrees = rad_to_deg(val);
var _angle_degrees : float = 0.0;
@export var angle_degrees : float = 0.0:
	get:
		return _angle_degrees;
	set(val):
		_angle_degrees = val;
		_angle = deg_to_rad(val);
@export var rotate_with : bool = true;

var _current_velocity : Vector2 = Vector2.ZERO;

func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false);
		return;
	_current_velocity = Vector2.RIGHT.rotated(angle).normalized() * speed;

func set_velocity(angle_set : float, spd : float) -> void:
	angle = angle_set;
	speed = spd;
	
	_current_velocity = Vector2.RIGHT.rotated(angle).normalized() * spd;

func _move_to(delta : float) -> void:
	var direction : Vector2;
	if target == null:
		direction = Vector2.RIGHT.rotated(angle).normalized();
	else:
		direction = global_position.direction_to(target.global_position).normalized();
	var desired_velocity : Vector2 = direction * speed;
	
	var change = (desired_velocity - _current_velocity) * drag_factor;
	
	_current_velocity += change;
	angle = (global_position + _current_velocity).angle();
	if rotate_with:
		rotation = angle;
	
	position += _current_velocity * delta;

func _physics_process(delta : float) -> void:
	_move_to(delta);
