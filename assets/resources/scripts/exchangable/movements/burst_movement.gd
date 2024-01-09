@tool
class_name BurstMovement extends MovementExchangable

@export var speed : int = 500;
@export var duration : float = 0.2;
@export var cool_down : float = 0.0;

@export var becomes_invincible : bool = true;
@export var can_stop : bool = false;
@export var in_burst_control : bool = true:
	set(val):
		in_burst_control = val;
		notify_property_list_changed();
var burst_control_ratio : float = 0.1;

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = [];
	if in_burst_control:
		properties.append({
			"name": "burst_control_ratio",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	return properties;

var is_busting : bool = false;
var on_cooldown : bool = false;

var _timer1 : SceneTreeTimer;
var _timer2 : SceneTreeTimer;

signal end_bust;
signal end_cooldown;

func reset() -> void:
	super();
	is_busting = false;
	on_cooldown = false;
	
	if is_instance_valid(_timer1) && _timer1:
		_timer1.timeout.disconnect(_end_dash);
	if is_instance_valid(_timer2) && _timer2:
		_timer2.timeout.disconnect(_end_cooldown);
	_timer1 = null;
	_timer2 = null;

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
			_timer1 = _actor.get_tree().create_timer(duration);
			_timer1.timeout.connect(_end_dash.bind(_actor));
		return true;
	
	if in_burst_control:
		_actor.velocity = (_actor.velocity + (move_dir * speed * burst_control_ratio)).normalized() * speed;
	
	_actor.move_and_slide();
	return true;

func _end_dash(_actor : ExchangeType) -> void:
	is_busting = false;
	end_bust.emit()
	
	if cool_down > 0:
		on_cooldown = true;
		_timer2 = _actor.get_tree().create_timer(cool_down);
		_timer2.timeout.connect(_end_cooldown);

func _end_cooldown() -> void:
	on_cooldown = false;
	end_cooldown.emit();
