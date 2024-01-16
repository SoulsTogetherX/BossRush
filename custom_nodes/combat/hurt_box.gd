class_name HurtBox extends Area2D

enum ALIGNMENT {PLAYER, ENEMY};

@export var health_monitor : HealthMonitor;
@export var alignment : ALIGNMENT;
@export var queue_on : bool = false;

var _incincible_queue : int = 0;

signal hit(hitbox : HitBox);

func _init() -> void:
	collision_layer = 0;
	collision_mask = 2;

func _ready() -> void:
	area_entered.connect(_on_hit);

var _one_at_a_time : bool = false;
func _on_hit(hitbox : HitBox) -> void:
	if hitbox == null || health_monitor == null || !monitoring || _one_at_a_time:
		return;
	if hitbox.alignment == alignment:
		return;
	_one_at_a_time = true;
	set_deferred("_one_at_a_time", false);
	
	health_monitor.health_change(hitbox.amount);
	
	hitbox.hit.emit(self);
	hit.emit(hitbox);

func _hit_check(align : ALIGNMENT, amount : int) -> bool:
	if align == alignment || !monitoring || _one_at_a_time:
		return false;
	_one_at_a_time = true;
	set_deferred("_one_at_a_time", false);
	
	health_monitor.health_change(amount);
	hit.emit(null);
	
	return true;

func toggle_hurtbox(toggle : bool) -> void:
	if toggle:
		if !queue_on:
			set_deferred("monitoring", true);
		else:
			_incincible_queue -= 1;
			if _incincible_queue <= 0:
				set_deferred("monitoring", true);
				_incincible_queue = 0;
	else:
		if queue_on:
			_incincible_queue += 1;
		set_deferred("monitoring", false);
