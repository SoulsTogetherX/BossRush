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
	if $hit_particles:
		$hit_particles.emitting = true;
		$hit_particles.finished.connect($hit_particles.queue_free, CONNECT_ONE_SHOT);
		$hit_particles.reparent(get_tree().current_scene);
	await _sound();
	super(_hurtbox);

func on_collide_wall(_body : Node2D) -> void:
	if $wall_hit_particles:
		$wall_hit_particles.emitting = true;
		$wall_hit_particles.finished.connect($wall_hit_particles.queue_free, CONNECT_ONE_SHOT);
		$wall_hit_particles.reparent(get_tree().current_scene);
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
