class_name Projectile extends OneTimeHit

var _movement : Tween;

func _ready() -> void:
	pass;

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

func activate() -> void:
	_hitbox.toggle_hitbox(true);
