extends State

@export var idle : State;

func get_id():
	return "spawn";

func enter() -> void:
	_actor._animation_player.play("start");
	_actor._animation_player.animation_finished.connect(func(_unused): _stateOverhead.update(), CONNECT_ONE_SHOT)
	
	$"../../../hitbox/CollisionShape2D5".disabled = true;
	get_tree().create_timer(1.2).timeout.connect(set_collition, CONNECT_ONE_SHOT);

func set_collition() -> void:
	$"../../../hitbox/CollisionShape2D5".disabled = false;

func update() -> State:
	return idle;
