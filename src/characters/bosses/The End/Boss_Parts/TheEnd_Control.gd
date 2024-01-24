@tool
extends FloatObjectControl

@export var shadow_left : Sprite2D;
@export var shadow_right : Sprite2D;
@export var floor : Sprite2D;

var _back_up : bool = false;
var _position_x_addition : float;
var _time_delta : float = 0.0;


func _ready() -> void:
	super();
	$TheEnd.set_shadows(shadow_left, shadow_right);
	$TheEnd.set_floor(floor);

func die() -> void:
	queue_free();

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
	get_child(0).move_all_compoents(diff);
