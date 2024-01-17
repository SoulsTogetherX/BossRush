extends Weapon

func handle_attack(_exch : Exchangable) -> void:
	super(_exch);
	$hit_particle.emitting = true;
