extends State

@export var idle : State;

func get_id():
	return "spawn";

func enter() -> void:
	_actor._animation_player.play("start");
	_actor._animation_player.animation_finished.connect(func(_unused): _stateOverhead.update(), CONNECT_ONE_SHOT)

func update() -> State:
	return idle;
