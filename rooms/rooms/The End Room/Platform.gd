@tool
extends FloatObjectControl

@export var desired_angle : float = 0.0;
@export var decay_factor : float = 0.0;
@export var influence_factor : float = 0.0;
@export var resist_factor : float = 0.0;

var angle_force : float = 0.0;

var _player : Player;

func _ready() -> void:
	super();
	if !Engine.is_editor_hint():
		_player = PlayerInfo.player;

func apply_force(force : float, at_global_x : float) -> void:
	angle_force = force * ((at_global_x - global_position.x) * 0.1) * influence_factor;

func _physics_process(delta: float) -> void:
	super(delta);
	
	global_rotation = lerp(global_rotation, desired_angle, resist_factor);
	global_rotation += angle_force * delta;
	
	angle_force = lerp(angle_force, 0.0, decay_factor);
	
	var velocity = Vector2.RIGHT.rotated(global_rotation) * (global_rotation - desired_angle) * 1000 * delta;
	if !velocity.is_zero_approx():
		_player.move_and_collide(velocity);
