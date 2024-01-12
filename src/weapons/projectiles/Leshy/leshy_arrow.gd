extends Projectile

func on_collide(_hurtbox : HurtBox) -> void:
	await _sound();
	destroy();

func on_collide_wall(_body : Node2D) -> void:
	await _sound();
	destroy();

func _sound() -> void:
	_movement.kill();
	
	$hitbox.visible = false;
	$sprite.visible = false;
	$PointLight2D.visible = false;
	
	$impact.play();
	await $impact.finished;
