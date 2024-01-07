class_name ExchangeType extends CharacterBody2D

@export var primary_attack : AttackExchangable;
@export var secondary_attack : AttackExchangable;
@export var health_handle : HealthExchangable;
@export var primary_movement : MovementExchangable;
@export var secondary_movement : MovementExchangable;

@onready var health_monitor : HealthMonitor = $HealthMonitor

signal damaged(amount : int);
signal killed;

func _ready() -> void:
	health_monitor.max_health = health_handle.max_health;
	health_monitor.update_health_no_signal(health_handle.max_health);
	health_monitor.damage_taken.connect(health_handle._on_damage.bind(self));
	
	health_monitor.damage_taken.connect(_signal_damaged);
	health_monitor.killed.connect(_signal_killed);

func _handle_movement(_actor : ExchangeType, _from : Vector2, move_dir : Vector2, primary : bool = true) -> bool:
	var move : MovementExchangable = primary_movement if primary else secondary_movement;
	
	return move.enact_move(_actor, _from, move_dir);

func _handle_attack(primary : bool = true) -> void:
	var attack : AttackExchangable = primary_attack if primary else secondary_attack;

func toggle_invincible(toggle : bool) -> void:
	health_monitor.toggle_invincible(toggle);

func _signal_damaged(amount : int) -> void:
	damaged.emit(health_monitor.health);

func _signal_killed() -> void:
	killed.emit();
