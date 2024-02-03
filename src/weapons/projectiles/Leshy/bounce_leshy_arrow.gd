extends LeshyArrows

@export var velocity : Vector2;
@export var bounces : int = -1;

func _physics_process(delta: float) -> void:
	position += velocity * delta;

func on_collide_wall(_body : Node2D) -> void:
	if bounces == 0:
		set_physics_process(false);
		super(_body);
		return;
	
	var normal : Vector2 = $RayCast2D.get_collision_normal();
	if normal.is_zero_approx():
		set_physics_process(false);
		super(_body);
		return;
	
	velocity = velocity.bounce(normal);
	rotation = velocity.angle();
	bounces -= 1;
