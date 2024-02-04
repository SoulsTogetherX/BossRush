extends State

var idle_tween : Tween;

func get_id():
	return "idle";

func enter() -> void:
	_animationPlayer.stop();
	_animationPlayer.play("idle");
	_actor._enact_idle();
	
	_start_tween();

func exit() -> void:
	if idle_tween:
		idle_tween.kill();

func process_physics(_delta: float) -> State:
	_actor._shadow.global_position = _actor._shadow.global_position.lerp(_actor.global_position, _actor.lerp_coefficent)
	return null;

func _start_tween() -> void:
	idle_tween = create_tween().set_parallel();
	idle_tween.tween_property(_actor, "scale", Vector2.ONE * 0.85, 0.5);
	idle_tween.tween_property(_actor, "rotation_degrees", 0.0, 0.5);
	idle_tween.tween_property(_actor, "z_index", -12, 0.001).set_delay(1.0);
	if _actor._shadow:
		idle_tween.tween_property(_actor._shadow, "modulate:a", 0.0, 0.5);
