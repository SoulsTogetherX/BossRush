extends State

@export var move : State;

func get_id():
	return "idle";

func enter() -> void:
	_actor._animation_player.play("idle_real");

func process_physics(_delta: float) -> State:
	if _actor.alignment == HurtBox.ALIGNMENT.ENEMY:
		return move;
	elif PlayerInfo.boss.hitable() || PlayerInfo.boss.get_minons().size() > 0:
		return move;
	return null;

