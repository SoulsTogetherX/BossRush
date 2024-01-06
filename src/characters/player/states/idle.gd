extends State

@export var walk : State;

func get_id():
	return "idle";

func state_ready() -> void:
	pass;

func enter() -> void:
	print(get_id());

func exit() -> void:
	pass;

func process_input(_event: InputEvent) -> State:
	return null;

func process_physics(_delta: float) -> State:
	if _actor.get_input():
		return walk;
	return null;

func process_frame(_delta: float) -> State:
	return null;

func update() -> State:
	return null;

