extends Node

var primary_attack : AttackExchangable = preload("res://assets/resources/instances/exchangable/player_base/Doggo Stab.tres");
var secondary_attack : AttackExchangable = null;
var health_handle : HealthExchangable = preload("res://assets/resources/instances/exchangable/player_base/Doggo Health.tres");
var primary_movement : MovementExchangable = preload("res://assets/resources/instances/exchangable/player_base/Doggo Walk.tres");
var secondary_movement : MovementExchangable = null;

var player : Player;
var weapon : Weapon;
var cam : CameraFollow2D;

var _fade_tween : Tween;

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;

func overwrite_player(toggle : bool) -> void:
	player.process_mode = Node.PROCESS_MODE_DISABLED if toggle else Node.PROCESS_MODE_INHERIT;
	if weapon:
		weapon.process_mode = player.process_mode;
		
		if _fade_tween:
			_fade_tween.kill();
		_fade_tween = create_tween().set_parallel();
		
		if toggle:
			_fade_tween.tween_property(weapon, "scale", Vector2(0.5, 0.5), 0.5);
			_fade_tween.tween_property(weapon, "modulate:a", 0.0, 0.5);
		else:
			_fade_tween.tween_property(weapon, "scale", Vector2(1.0, 1.0), 0.5);
			_fade_tween.tween_property(weapon, "modulate:a", 1.0, 0.5);

func assign_player_moves() -> void:
	player.primary_attack = primary_attack;
	if primary_attack:
		weapon = primary_attack._set_up_sprite(player, 30);
	player.secondary_attack = secondary_attack;
	
	player.health_handle = health_handle;
	
	player.primary_movement = primary_movement;
	player.secondary_movement = secondary_movement;
	
func replace(idx : int, with : Exchangable) -> void:
	if with is AttackExchangable:
		if idx == 0:
			primary_attack = with;
			player.primary_attack = with;
			
			if weapon:
				weapon.queue_free();
			weapon = primary_attack._set_up_sprite(player, 30);
		else:
			secondary_attack = with;
			player.secondary_attack = with;
	elif with is HealthExchangable:
		if idx == 0:
			health_handle = with;
			player.health_handle = with;
	else:
		if idx == 0:
			primary_movement = with;
			player.primary_movement = with;
		else:
			secondary_movement = with;
			player.secondary_movement = with;

func reset() -> void:
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
