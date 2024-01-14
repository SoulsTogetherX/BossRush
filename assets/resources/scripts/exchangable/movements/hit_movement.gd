@tool
class_name HitMovement extends MovementExchangable

@export var speed : int = 500;
@export var cool_down : float = 0.0;

@export var _incincible : Invincibility = null:
	set(val):
		if _incincible:
			_incincible.invincible_start.disconnect(_incincible_on);
			_incincible.invincible_end.disconnect(_incincible_off);
		if val:
			val.invincible_start.connect(_incincible_on);
			val.invincible_end.connect(_incincible_off);
		_incincible = val;
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
signal toggle_hitable(toggle : bool);

func enact_move(delta : float, actor : ExchangeType, _from : Vector2, move_dir : Vector2) -> bool:
	if on_cooldown:
		return false;
	
	if !is_busting && !on_cooldown:
		if move_dir.is_zero_approx():
			return false;
		
		is_busting = true;
		
		actor.velocity = move_dir * speed;
		actor.move_and_slide();
		
		if _incincible:
			_incincible.start(actor.get_tree());
		return true;
	
	if in_burst_control:
		actor.velocity = (actor.velocity + (move_dir * speed * burst_control_ratio)).normalized() * speed;
	
	var info : KinematicCollision2D = KinematicCollision2D.new();
	if actor.test_move(actor.get_global_transform(), actor.velocity * delta, info):
		if (info.get_collider().collision_layer & actor.collision_mask) > 0:
			_end_dash(actor);
	actor.move_and_slide();
	return true;


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

func _incincible_on() -> void:
	toggle_hitable.emit(false);
func _incincible_off() -> void:
	toggle_hitable.emit(true);
