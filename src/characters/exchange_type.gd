class_name ExchangeType extends CharacterBody2D

@export var primary_attack : AttackExchangable;
@export var secondary_attack : AttackExchangable;
@export var health_handle : HealthExchangable;
@export var primary_movement : MovementExchangable;
@export var secondary_movement : MovementExchangable;

@onready var health_monitor : HealthMonitor = $HealthMonitor

func _ready() -> void:
	health_monitor.max_health = health_handle.max_health;
	health_monitor.update_health_no_signal(health_handle.max_health);
	health_monitor.damage_taken.connect(health_handle._on_damage.bind(self));

func _handle_movement(_actor : ExchangeType, _from : Vector2, move_dir : Vector2, primary : bool = true) -> bool:
	var move : MovementExchangable = primary_movement if primary else secondary_movement;
	
	return move.enact_move(_actor, _from, move_dir);

func _handle_attack(primary : bool = true) -> void:
	var attack : AttackExchangable = primary_attack if primary else secondary_attack;

func toggle_invincible(toggle : bool) -> void:
	health_monitor.toggle_invincible(toggle);
