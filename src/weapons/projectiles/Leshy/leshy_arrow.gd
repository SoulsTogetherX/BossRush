class_name LeshyArrows extends Projectile

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
	$hitbox.queue_free();
	$collide_detect.queue_free();
	await _sound();
	super(_hurtbox);

func on_collide_wall(_body : Node2D) -> void:
	$hitbox.queue_free();
	$collide_detect.queue_free()
	var hit_part = get_node_or_null("wall_hit_particles");
	
	if hit_part:
		hit_part.emitting = true;
		hit_part.finished.connect(hit_part.queue_free, CONNECT_ONE_SHOT);
		hit_part.reparent(get_tree().current_scene);
	await _sound();
	collided.emit();
	destroy();

func _sound() -> void:
	_movement.kill();
	
	$hitbox.visible = false;
	$sprite.visible = false;
	$PointLight2D.visible = false;
	
	$impact.play();
	await $impact.finished;
