@tool
extends HomingProjectile

@export var rotation_inc : float = 0.1;

var _homing : bool = false;

func _physics_process(delta: float) -> void:
	rotation_degrees += rotation_inc * delta;
	if _homing:
		super(delta);
	else:
		global_position += _current_velocity * delta;

func start_homing(time : float,clear_time : float) -> void:
	if _homing:
		return;
	_homing = true;
	await get_tree().create_timer(time).timeout;
	_homing = false;
	
	get_tree().create_timer(clear_time).timeout.connect(queue_free);
