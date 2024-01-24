extends Weapon

@onready var _particles : Array[GPUParticles2D] = [$hit_particle1, $hit_particle2, $hit_particle3, $hit_particle4];
var _particle_idx : int = 0;

func handle_kickback(dir : Vector2) -> void:
	_follow.velocity += (dir - _follow.get_center()).normalized() * 200;
	_follow.change_direction(_follow.velocity.angle());
	_follow.move_and_slide();

func handle_attack(_exch : Exchangable) -> void:
	super(_exch);
	var part : GPUParticles2D = _particles[_particle_idx];
	_particle_idx = (_particle_idx + 1) % 4;
	
	part.global_position = global_position + Vector2(40, 0).rotated(global_rotation);
	part.global_rotation = global_rotation;
	part.restart();
	part.emitting = true;
