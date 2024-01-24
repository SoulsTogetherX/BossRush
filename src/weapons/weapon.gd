class_name Weapon extends Node2D

@export var sounds : Array[AudioStreamPlayer];
@export var delay : float = 0.0;

@onready var _center : Marker2D = $Center;
@onready var _animation : AnimationPlayer = $AnimationPlayer;

var _follow : ExchangeType:
	set(val):
		set_physics_process(val != null && val.has_method("get_weapon_info"));
		_follow = val;

var _follow_distance : float;

func set_follow(follow : ExchangeType, distance : float) -> void:
	_follow = follow;
	_follow_distance = distance;

var _no_attack : bool = false;
func handle_attack(_exch : Exchangable) -> void:
	if _no_attack:
		return;
	
	if delay > 0:
		_no_attack = true;
		await get_tree().create_timer(delay).timeout;
		_no_attack = false;
	_animation.stop();
	_animation.play("attack");

func _physics_process(_delta: float) -> void:
	var desired_info : Array[float] = _follow.get_weapon_info();
	var desired_position = _follow.global_position + Vector2(0, -8) + (Vector2(cos(desired_info[0]), sin(desired_info[0])) * min(_follow_distance, desired_info[1]));
	
	global_rotation = lerp_angle(global_rotation, desired_info[0], 0.3);
	global_position = global_position.lerp(desired_position, 0.3);

func get_center() -> Vector2:
	if _center:
		return _center.global_position;
	else:
		return Vector2.ZERO;

func handle_kickback(_dir : Vector2) -> void:
	pass;

func handle_hit_particles(_targets : Array[Node2D]) -> void:
	pass;

func play_sound(sound : int) -> void:
	if sound == 0:
		sounds[1].play();
		return;
	
	if sound < sounds.size():
		sounds[sound].play();

