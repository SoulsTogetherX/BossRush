extends State

@export var move : State;

var _knock_back : Vector2;
var _knockback_tween : Tween;

func get_id():
	return "knock_back";

func process_physics(_delta: float) -> State:
	_actor.velocity = _knock_back;
	_actor.move_and_slide();
	
	return null;

func update() -> State:
	_knock_back = Vector2.ZERO;
	if _actor.alignment == HurtBox.ALIGNMENT.ENEMY:
		return move;
	return move;

func set_knock_back(at : Node2D, from : Node2D, dead : bool) -> void:
	if _knockback_tween:
		_knockback_tween.kill();
	_knockback_tween = create_tween().set_parallel();
	
	_knockback_tween.tween_property(_actor._sprite, "modulate", Color.RED, 0.15);
	_knockback_tween.tween_property(_actor._sprite, "modulate", Color.WHITE, 0.05).set_delay(0.15);
	
	_knockback_tween.tween_property(_actor._sprite, "scale", Vector2(0.5, 0.5), 0.1);
	_knockback_tween.tween_property(_actor._sprite, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.1);
	
	if !dead:
		_stateOverhead.change_state("main", get_id());
		
		var target_pos : Vector2 = from.global_position if at == null else at.global_position;
		var dir : Vector2 = (_actor.global_position - target_pos).normalized();
		_knock_back = dir * 100;
		_knockback_tween.chain().tween_callback(_stateOverhead.update);
