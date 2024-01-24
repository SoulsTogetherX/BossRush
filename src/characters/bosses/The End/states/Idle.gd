extends State

func get_id():
	return "idle";

func state_ready() -> void:
	pass;

func enter() -> void:
	_animationPlayer.play("idle");
	_actor._enact_idle();
	
	var tw : Tween;
	tw = create_tween().set_parallel();
	tw.tween_property(_actor, "scale", Vector2.ONE * 0.85, 0.5);
	tw.tween_property(_actor, "rotation_degrees", 0.0, 0.5);

func process_physics(_delta: float) -> State:
	_actor._shadow.global_position = _actor._shadow.global_position.lerp(_actor.global_position, _actor.lerp_coefficent)
	return null;
