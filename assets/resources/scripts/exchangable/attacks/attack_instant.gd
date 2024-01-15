class_name AttackInstant extends AttackExchangable

@export var shape : Shape2D;

signal playSound(sound : int);

func _on_attack(from : Node2D, _target : Vector2, alignment : HurtBox.ALIGNMENT) -> void:
	var physics : PhysicsDirectSpaceState2D = from.get_world_2d().direct_space_state;
	var query = PhysicsShapeQueryParameters2D.new();
	query.set_shape(shape);
	query.collision_mask = 16;
	query.collide_with_areas = true;
	query.collide_with_bodies = false;
	query.transform = Transform2D(0, Vector2(1.,1.), 0, from.get_center());
	var results = physics.intersect_shape(query);
	if !results.is_empty():
		# Hit Boss
		playSound.emit(0);
		var closest : Node2D;
		var smallest : float = INF;
		for result in results:
			var dist : float = from.global_position.distance_squared_to(result.collider.global_position);
			if dist < smallest:
				smallest = dist;
				closest = result.collider;
			
		closest.damage(delta, alignment);
	
	query.collision_mask = 1;
	query.collide_with_areas = false;
	query.collide_with_bodies = true;
	if !physics.intersect_shape(query).is_empty():
		# Hit ground
		playSound.emit(1);
	
	# Hit air
	playSound.emit(2);
	
	if from.has_method("handle_kickback"):
		from.handle_kickback(_target);
