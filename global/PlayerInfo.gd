extends Node

var primary_attack : AttackExchangable = preload("res://assets/resources/instances/exchangable/player_base/Doggo Stab.tres");
var secondary_attack : AttackExchangable = null;
var health_handle : HealthExchangable = preload("res://assets/resources/instances/exchangable/player_base/Doggo Health.tres");
var primary_movement : MovementExchangable = preload("res://assets/resources/instances/exchangable/player_base/Doggo Walk.tres");
var secondary_movement : MovementExchangable = null;

var player : Player;
var weapon : Weapon;
var cam : CameraFollow2D;
var boss : Boss;
var saved_health : int;

var _fade_tween : Tween;
var lights_on : bool = false;

enum DIFFICULTY {EASY = 0, NORMAL = 1, BARKMODE = 2};
var hard_mode : DIFFICULTY = DIFFICULTY.NORMAL;

signal max_health_changed(amount : int);
signal health_changed(amount : int);

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;

func max_health_update() -> void:
	health_changed.emit(player.get_max_health());

func health_update(_amount : int = 0) -> void:
	health_changed.emit(player.get_health());

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
	if primary_attack:
		player.primary_attack = primary_attack.duplicate();
		weapon_settup(player.primary_attack);
		if primary_attack is SpawnAttack:
			primary_attack.summoned.connect(player.register_slime);
		
	if secondary_attack:
		player.secondary_attack = secondary_attack.duplicate();
		if secondary_attack is SpawnAttack:
			secondary_attack.summoned.connect(player.register_slime);
	
	if health_handle:
		player.health_handle = health_handle.duplicate();
	
	if primary_movement:
		player.primary_movement = primary_movement.duplicate();
	if secondary_movement:
		player.secondary_movement = secondary_movement.duplicate();
	
	max_health_update();
	health_update();
	
func replace(idx : int, with : Exchangable) -> void:
	if with is AttackExchangable:
		if idx == 0:
			primary_attack = with;
			player.primary_attack = primary_attack.duplicate();
			if primary_attack is SpawnAttack:
				primary_attack.summoned.connect(player.register_slime);
			
			weapon_settup(player.primary_attack);
		else:
			secondary_attack = with;
			player.secondary_attack = secondary_attack.duplicate();
			if secondary_attack is SpawnAttack:
				secondary_attack.summoned.connect(player.register_slime);
			
	elif with is HealthExchangable:
		if idx == 0:
			health_handle = with;
			health_handle.health = health_handle.max_health;
			player.health_handle = health_handle.duplicate();
			
			max_health_update();
			health_update();
	else:
		if idx == 0:
			primary_movement = with;
			player.primary_movement = primary_movement.duplicate();
		else:
			secondary_movement = with;
			player.secondary_movement = secondary_movement.duplicate();

func weapon_settup(exchan : AttackExchangable) -> void:
	if is_instance_valid(weapon) && weapon:
		weapon.queue_free();
	weapon = exchan._set_up_sprite(player, exchan.weapon_range);
