class_name HurtBox extends Area2D

enum ALIGNMENT {PLAYER, ENEMY};

@export var health_monitor : HealthMonitor;
@export var alignment : ALIGNMENT;

signal hit(hitbox : HitBox);

func _init() -> void:
	collision_layer = 0;
	collision_mask = 2;

func _ready() -> void:
	area_entered.connect(_on_hit);

func _on_hit(hitbox : HitBox) -> void:
	if hitbox == null || health_monitor == null:
		return;
	if hitbox.alignment == alignment:
		return;
	
	health_monitor.health_change(hitbox.amount);
	
	hitbox.hit.emit(self);
	hit.emit(hitbox);
