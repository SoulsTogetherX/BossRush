extends Weapon

func handle_kickback(dir : Vector2) -> void:
	_follow.velocity += (dir - _follow.get_center()).normalized() * 200;
	_follow.change_direction(_follow.velocity.angle());
	_follow.move_and_slide();

func handle_attack(_exch : Exchangable) -> void:
	super(_exch);
	$hit_particle.emitting = true;
