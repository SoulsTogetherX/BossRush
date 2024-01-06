class_name BustMovement extends MovementExchangable

@export var speed : int = 500;
@export var duration : float = 0.2;
@export var cool_down : float = 0.0;

@export var becomes_invincible : bool = true;

var is_busting : bool = false;
var on_cooldown : bool = false;

signal end_bust;
signal end_cooldown;

func enact_move(_actor : ExchangeType, _from : Vector2, move_dir : Vector2) -> bool:
	if on_cooldown:
		return false;
	
	if !is_busting && !on_cooldown:
		if move_dir.is_zero_approx():
			return false;
		
		is_busting = true;
		
		_actor.velocity = move_dir * speed;
		_actor.move_and_slide();
		
		if duration > 0:
			_actor.get_tree().create_timer(duration).timeout.connect(_end_dash.bind(_actor));
		return true;
	
	_actor.move_and_slide();
	return true;

func _end_dash(_actor : ExchangeType) -> void:
	is_busting = false;
	_actor.velocity = Vector2.ZERO;
	end_bust.emit()
	
	if cool_down > 0:
		on_cooldown = true;
		_actor.get_tree().create_timer(cool_down).timeout.connect(_end_cooldown);

func _end_cooldown() -> void:
	on_cooldown = false;
	end_cooldown.emit();
