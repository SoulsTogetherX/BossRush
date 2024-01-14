extends Projectile

func set_alignment(allign : HurtBox.ALIGNMENT) -> void:
	super(allign);
	match allign:
		HurtBox.ALIGNMENT.PLAYER:
			$sprite.material.set_shader_parameter("color", Color.YELLOW);
			$trail.default_color = Color.YELLOW;
		HurtBox.ALIGNMENT.ENEMY:
			$sprite.material.set_shader_parameter("color", Color.LIGHT_CORAL);
			$trail.default_color = Color.LIGHT_CORAL;

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
