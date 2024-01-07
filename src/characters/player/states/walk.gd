extends State

@export var idle : State;

func get_id():
	return "walk";

func state_ready() -> void:
	pass;

func enter() -> void:
	print(get_id());

func exit() -> void:
	pass;

func process_input(_event: InputEvent) -> State:
	return null;

func process_physics(_delta: float) -> State:
	if !_actor._handle_movement(_actor, _actor.global_position, _actor.get_input(), !Input.is_action_pressed("move_switch")):
		_actor.velocity = Vector2.ZERO;
		return idle;
	return null;

func process_frame(_delta: float) -> State:
	return null;

func update() -> State:
	return null;

