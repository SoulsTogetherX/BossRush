class_name OneTimeHit extends Node2D

@onready var _hitbox : HitBox = $hitbox;

func set_alignment(allign : HurtBox.ALIGNMENT) -> void:
	_hitbox.alignment = allign;

func set_delta(delta : int) -> void:
	_hitbox.amount = delta;

func set_radius(radius : float) -> void:
	$hitbox/CollisionShape2D.shape.radius = radius;

func activate() -> void:
	_hitbox.toggle_hitbox(true);
	await get_tree().process_frame;
	await get_tree().process_frame;
	call_deferred("queue_free");
