class_name ExchangeType extends CharacterBody2D

@export var _sprite : Sprite2D;

@export var alignment : HurtBox.ALIGNMENT;
@export var primary_attack : AttackExchangable;
@export var secondary_attack : AttackExchangable;

@export var health_handle : HealthExchangable:
	set(val):
		if !is_node_ready():
			await ready;
		
		if health_handle:
			_health_monitor.damage_taken.disconnect(_damage_callable);
			health_handle.toggle_hitable.disconnect($hurt_box.toggle_hurtbox);
		if val:
			_damage_callable = val._on_damage.bind(self);
			
			_health_monitor.max_health = val.max_health;
			_health_monitor.update_health_no_signal(val.health);
			
			_health_monitor.damage_taken.connect(_damage_callable);
			val.toggle_hitable.connect($hurt_box.toggle_hurtbox);
		health_handle = val;

@export var primary_movement : MovementExchangable:
	set(val):
		if !is_node_ready():
			await ready;
		
		if primary_movement && primary_movement is BurstMovement:
			primary_movement.toggle_hitable.disconnect($hurt_box.toggle_hurtbox);
		if val && val is BurstMovement:
			val.toggle_hitable.connect($hurt_box.toggle_hurtbox);
			val.reset();
		primary_movement = val;
@export var secondary_movement : MovementExchangable:
	set(val):
		if !is_node_ready():
			await ready;
		
		if secondary_movement && secondary_movement is BurstMovement:
			secondary_movement.toggle_hitable.disconnect($hurt_box.toggle_hurtbox);
		if val && val is BurstMovement:
			val.toggle_hitable.connect($hurt_box.toggle_hurtbox);
		secondary_movement = val;

@onready var _health_monitor : HealthMonitor = $HealthMonitor;
@onready var _center: Marker2D = $Center;

var _damage_callable: Callable;

signal damaged(amount : int);
signal killed;

func _ready() -> void:
	_health_monitor.damage_taken.connect(_signal_damaged);
	_health_monitor.killed.connect(_signal_killed);
	$hurt_box.alignment = alignment;
	_reset();

func _reset() -> void:
	if primary_attack:
		primary_attack.reset();
	if secondary_attack:
		secondary_attack.reset();
	
	if health_handle:
		health_handle.reset();
	
	if primary_movement:
		primary_movement.reset();
	if secondary_movement:
		secondary_movement.reset();

var _lock : bool = false;
var _move_save : MovementExchangable
func _handle_movement(delta : float, _actor : ExchangeType, _from : Vector2, move_dir : Vector2, primary : bool = true) -> bool:
	if !_lock:
		_move_save = primary_movement if (primary || !secondary_movement) else secondary_movement;
		
		if _move_save is HitMovement && !_move_save.can_stop && !_move_save.on_cooldown:
			_lock = true;
			_move_save.end_bust.connect(_unlock, CONNECT_ONE_SHOT);
	
	if _move_save:
		return _move_save.enact_move(delta, _actor, _from, move_dir);
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

func get_animation_modifer_4(angle : float) -> String:
	var dir = wrapi(int(snapped(angle, PI/2) / (PI/2)), 0, 4);
	match dir:
		0:
				#right
			return "right";
		1:
				#down
			return "down";
		2:
				#left
			return "left";
		3:
				#up
			return "up";
	return "";

func get_alignment() -> HurtBox.ALIGNMENT:
	return alignment;

func get_center() -> Vector2:
	return _center.global_position;

func get_center_local() -> Vector2:
	return _center.position;

func create_after_image(mod : Color = Color(1.0, 1.0, 1.0, 0.8), fade_time = 0.2) -> void:
	var sprite : Sprite2D = Sprite2D.new();
	add_child(sprite);
	sprite.top_level = true;
	sprite.global_transform = _sprite.global_transform;
	sprite.texture = _sprite.texture;
	sprite.flip_h = _sprite.flip_h;
	sprite.hframes = _sprite.hframes;
	sprite.frame = _sprite.frame;
	sprite.modulate = mod;
	if velocity.y <= 0:
		sprite.z_index = -1;
	
	var tw : Tween = create_tween();
	tw.tween_property(sprite, "modulate:a", 0.0, fade_time);
	tw.tween_callback(sprite.queue_free);
