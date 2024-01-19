class_name AttackRange extends AttackExchangable

@export var launch : LinearLaunch;
@export var offset : float = 0;

signal projectile_launched(pro : Projectile);
signal projectile_destroyed(pro : Projectile);

func _on_attack(from : Node2D, start : Vector2, target : Vector2, alignment : HurtBox.ALIGNMENT) -> void:
	var pro := launch.fire_protectile(from.get_tree().current_scene, start, offset, (target - start).angle(), true);
	
	pro.set_alignment(alignment);
	pro.set_delta(delta);
	pro.activate();
	
	projectile_launched.emit(pro);
	pro.destroyed.connect(_signal_projectil_destroyed, CONNECT_ONE_SHOT);

func _signal_projectil_destroyed(pro : Projectile) -> void:
	projectile_destroyed.emit(pro);
