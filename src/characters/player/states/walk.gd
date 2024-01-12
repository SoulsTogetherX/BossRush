extends State

@export var idle : State;

@onready var main : Sprite2D = $"../../../main";

var last_move : Vector2 = Vector2(0,0);

func get_id():
	return "walk";

func state_ready() -> void:
	pass;

func enter() -> void:
	pass;

func exit() -> void:
	pass;

func process_input(_event: InputEvent) -> State:
	return null;

func process_physics(_delta: float) -> State:
	var input : Vector2 = _actor.get_input();
	
	if !_actor._handle_movement(_actor, _actor.global_position, input, !Input.is_action_pressed("move_switch")):
		_actor.set_direction("idle_", last_move.angle());
		_actor.velocity = Vector2.ZERO;
		return idle;
	if input != Vector2.ZERO:
		last_move = input;
	
	if Input.is_action_pressed("move_switch"):
		if _actor.secondary_movement:
			_actor.set_direction(_actor.secondary_movement.animation + "_", _actor.velocity.angle());
		elif _actor.primary_movement:
			_actor.set_direction(_actor.primary_movement.animation + "_", _actor.velocity.angle());
	else:
		if _actor.primary_movement:
			_actor.set_direction(_actor.primary_movement.animation + "_", _actor.velocity.angle());
		elif _actor.secondary_movement:
			_actor.set_direction(_actor.secondary_movement.animation + "_", _actor.velocity.angle());
	
	return null;

func process_frame(_delta: float) -> State:
	return null;

func update() -> State:
	return null;

