class_name Projectile extends Node2D

@onready var _hitbox : HitBox = $hitbox;

@warning_ignore("unused_private_class_variable")
var _movement : Tween;

func set_alignment(allign : HurtBox.ALIGNMENT) -> void:
	_hitbox.alignment = allign;
	match allign:
		HurtBox.ALIGNMENT.PLAYER:
			$sprite.material.set_shader_parameter("color", Color.YELLOW);
			$trail.default_color = Color.YELLOW;
		HurtBox.ALIGNMENT.ENEMY:
			$sprite.material.set_shader_parameter("color", Color.LIGHT_CORAL);
			$trail.default_color = Color.LIGHT_CORAL;

func set_delta(delta : int) -> void:
	_hitbox.amount = delta;

func destroy() -> void:
	queue_free();

func on_collide(_hurtbox : HurtBox) -> void:
	destroy();

func on_dissipate() -> void:
	destroy();

func activate() -> void:
	_hitbox.toggle_hitbox(true);
