extends State

func get_id():
	return "dead";

func enter() -> void:
	_actor._animation_player.play("dead");
	
	var col : CollisionShape2D = get_node_or_null("../../../hitbox/CollisionShape2D5");
	if col:
		set_deferred("col", true);
		get_tree().create_timer(0.7).timeout.connect(set_deferred.bind("col", false), CONNECT_ONE_SHOT);
