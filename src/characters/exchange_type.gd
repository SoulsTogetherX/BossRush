class_name ExchangeType extends CharacterBody2D

@export var primary_attack : AttackExchangable;
@export var secondary_attack : AttackExchangable;
@export var health_handle : HealthExchangable;
@export var primary_movement : MovementExchangable;
@export var secondary_movement : MovementExchangable;

@onready var _health_monitor : HealthMonitor = $HealthMonitor
@onready var _animationPlayer: AnimationPlayer = $AnimationPlayer

signal damaged(amount : int);
signal killed;

func _ready() -> void:
	_health_monitor.max_health = health_handle.max_health;
	_health_monitor.update_health_no_signal(health_handle.max_health);
	_health_monitor.damage_taken.connect(health_handle._on_damage.bind(self));
	
	_health_monitor.damage_taken.connect(_signal_damaged);
	_health_monitor.killed.connect(_signal_killed);

func _handle_movement(_actor : ExchangeType, _from : Vector2, move_dir : Vector2, primary : bool = true) -> bool:
	var move : MovementExchangable = primary_movement if primary else secondary_movement;
	
	return move.enact_move(_actor, _from, move_dir);

func _handle_attack(primary : bool = true) -> void:
	var attack : AttackExchangable = primary_attack if primary else secondary_attack;

func toggle_invincible(toggle : bool) -> void:
	_health_monitor.toggle_invincible(toggle);

func _signal_damaged(amount : int) -> void:
	damaged.emit(_health_monitor.health);

func _signal_killed() -> void:
	killed.emit();

func get_exchange(type : String) -> Array[Exchangable]:
	match type:
		"attack":
			return [primary_attack, secondary_attack];
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
