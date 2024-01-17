extends State

func get_id():
	return "dead";

func enter() -> void:
	_actor._animation_player.play("dead");
	
	var col : CollisionShape2D = get_node_or_null("../../../hitbox/CollisionShape2D5");
	if col:
		set_deferred("col", true);
		await get_tree().create_timer(0.7).timeout;
		set_deferred("col", false);
