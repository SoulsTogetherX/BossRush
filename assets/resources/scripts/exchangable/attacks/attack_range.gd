class_name AttackRange extends AttackExchangable

@export var launch : LinearLaunch;
@export var offset : float = 0;

func _on_attack(from : Node2D, target : Vector2, alignment : HurtBox.ALIGNMENT) -> void:
	var pro := launch.fire_protectile(from.get_tree().current_scene, from.get_center(), offset, (target - from.get_center()).angle(), true);
	
	pro.set_alignment(alignment);
	pro.set_delta(delta);
	pro.activate();
