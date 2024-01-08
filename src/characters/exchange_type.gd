class_name ExchangeType extends CharacterBody2D



@export var primary_attack : AttackExchangable;
@export var secondary_attack : AttackExchangable;

@export var health_handle : HealthExchangable:
	set(val):
		if !is_node_ready():
			await ready;
		
		if health_handle:
			_health_monitor.damage_taken.disconnect(_damage_callable);
		if val:
			_damage_callable = val._on_damage.bind(self);
			
			_health_monitor.max_health = val.max_health;
			_health_monitor.update_health_no_signal(val.max_health);
			_health_monitor.damage_taken.connect(_damage_callable);
		health_handle = val;

@export var primary_movement : MovementExchangable;
@export var secondary_movement : MovementExchangable;

@onready var _health_monitor : HealthMonitor = $HealthMonitor;
@onready var _animationPlayer: AnimationPlayer = $AnimationPlayer;

var _damage_callable: Callable;

signal damaged(amount : int);
signal killed;

func _ready() -> void:
	_health_monitor.damage_taken.connect(_signal_damaged);
	_health_monitor.killed.connect(_signal_killed);

var _lock : bool = false;
var _move_save : MovementExchangable
func _handle_movement(_actor : ExchangeType, _from : Vector2, move_dir : Vector2, primary : bool = true) -> bool:
	if !_lock:
		_move_save = primary_movement if (primary || !secondary_movement) else secondary_movement;
		
		if _move_save is BurstMovement && !_move_save.can_stop && !_move_save.on_cooldown:
			_lock = true;
			_move_save.end_bust.connect(_unlock, CONNECT_ONE_SHOT);
	
	if _move_save:
		return _move_save.enact_move(_actor, _from, move_dir);
	else:
		return false;

func _unlock() -> void:
	_lock = false;

#func _handle_attack(primary : bool = true) -> void:
	#var attack : AttackExchangable = primary_attack if primary else secondary_attack;

func toggle_invincible(toggle : bool) -> void:
	_health_monitor.toggle_invincible(toggle);

func _signal_damaged(_amount : int) -> void:
	damaged.emit(_health_monitor.health);

func _signal_killed() -> void:
	killed.emit();

func get_exchange(type : String) -> Array[Exchangable]:
	match type:
		"attack":
			return [primary_attack];
		"health":
			return [health_handle];
		"movement":
			return [primary_movement, secondary_movement];
	return [];

func get_animation_modifer_8(angle : float) -> String:
	var dir = wrapi(int(snapped(angle, PI/4) / (PI/4)), 0, 8);
	match dir:
		0:
				#left
			scale.x = scale.y;
			return "left";
		1:
				#left down
			scale.x = scale.y;
			return "down_left";
		2:
				#down
			scale.x = scale.y;
			return "down";
		3:
				#right down
			scale.x = -scale.y;
			return "down_left";
		4:
				#right
			scale.x = -scale.y;
			return "left";
		5:
				#right up
			scale.x = -scale.y;
			return "up_left";
		6:
				#up
			scale.x = -scale.y;
			return "up";
		7:
				#left up
			scale.x = scale.y;
			return "up_left";
	return "";

func get_animation_modifer_4(angle : float, sprite : Sprite2D) -> String:
	var dir = wrapi(int(snapped(angle, PI/2) / (PI/2)), 0, 4);
	match dir:
		0:
				#left
			sprite.flip_h = false;
			return "side";
		1:
				#down
			return "down";
		2:
				#right
			sprite.flip_h = true;
			return "side";
		3:
				#up
			return "up";
	return "";

func set_direction(animationType : String, angle : float) -> void:
	var animation : String = get_animation_modifer_4(angle, $main) + animationType;
	if _animationPlayer.current_animation != animation:
		var pos : float = _animationPlayer.current_animation_position;
		_animationPlayer.play(animation);
		_animationPlayer.seek(pos, true);
