class_name AttackInstant extends AttackExchangable

@export var shape : Shape2D;
@export var attack_num : int = 1;

signal playSound(sound : int);

func _sort_distances(a : Array, b : Array) -> bool:
	if a[0] < b[0]:
		return true;
	return false;

func _on_attack(from : Node2D, _target : Vector2, alignment : HurtBox.ALIGNMENT) -> void:
	if attack_num <= 0:
		return;
	
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
		
		var sorted : Array[Array] = [];
		for result in results:
			sorted.append([from.global_position.distance_squared_to(result.collider.global_position), result]);
		sorted.sort_custom(_sort_distances);
		
		var ret : Array[Node2D] = [];
		for idx in min(sorted.size(), attack_num):
			ret.append(results[idx].collider);
			ret.back().damage(delta, alignment);
	
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
