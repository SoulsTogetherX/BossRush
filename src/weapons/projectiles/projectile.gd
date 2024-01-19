class_name Projectile extends Node2D

@onready var _hitbox : HitBox = $hitbox;

@warning_ignore("unused_private_class_variable")
var _movement : Tween;

signal destroyed(pro : Projectile);
signal collided(pro : Projectile);
signal dissipated(pro : Projectile);

func set_alignment(allign : HurtBox.ALIGNMENT) -> void:
	_hitbox.alignment = allign;

func set_delta(delta : int) -> void:
	_hitbox.amount = delta;

func destroy() -> void:
	destroyed.emit(self);
	queue_free();

func on_collide(_hurtbox : HurtBox) -> void:
	collided.emit(self);
	destroy();

func on_dissipate() -> void:
	dissipated.emit(self);
	destroy();

func activate() -> void:
	_hitbox.toggle_hitbox(true);
