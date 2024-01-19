extends Projectile

@onready var glow: Sprite2D = $glow

func _process(_delta: float) -> void:
	glow.scale = Vector2(10.0, 10.0) * (1.2 - (randf() * 0.4));

func on_collide(_hurtbox : HurtBox) -> void:
	$hit_particles.emitting = true;
	$hit_particles.finished.connect($hit_particles.queue_free, CONNECT_ONE_SHOT);
	$hit_particles.reparent(get_tree().current_scene);
	
	super(_hurtbox);
