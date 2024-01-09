class_name Projectile extends Node2D

@onready var _hitbox : HitBox = $hitbox;

var _movement : Tween;

func set_alignment(allign : HurtBox.ALIGNMENT) -> void:
	_hitbox.alignment = allign;

func set_delta(delta : int) -> void:
	_hitbox.amount = delta;

func destroy() -> void:
	queue_free();

func on_collide(hurtbox : HurtBox) -> void:
	destroy();

func on_dissipate() -> void:
	destroy();
