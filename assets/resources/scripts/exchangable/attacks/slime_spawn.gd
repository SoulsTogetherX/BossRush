class_name SpawnAttack extends AttackExchangable

@export var spawn_entity : PackedScene;

signal summoned(spawned : ExchangeType);

func _on_attack(from : Node2D, _target : Vector2, alignment : HurtBox.ALIGNMENT) -> void:
	var spawn_poses : Array[Vector2] = [];
	if from.has_method("get_spawn_pos"):
		spawn_poses = from.get_spawn_pos();
	else:
		pass;
	
	for pos in spawn_poses:
		var entity : ExchangeType = spawn_entity.instantiate();
		entity.alignment = alignment;
		from.get_tree().current_scene.add_child(entity);
		entity.global_position = pos;
		
		summoned.emit(entity);
