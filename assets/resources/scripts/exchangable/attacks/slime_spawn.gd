class_name SpawnAttack extends AttackExchangable

@export var spawn_entity : PackedScene;
@export var max_spawn : int = -1;

signal summoned(spawned : ExchangeType);

func reset() -> void:
	super();
	_spawned = 0;

var _spawned : int = 0;
func _dec_count() -> void:
	_spawned -= 1;

func _on_attack(from : Node2D, _start : Vector2, _target : Vector2, alignment : HurtBox.ALIGNMENT) -> void:
	var spawn_poses : Array[Vector2] = [];
	if from.has_method("get_spawn_pos"):
		spawn_poses = from.get_spawn_pos();
	
	var available : int = (spawn_poses.size() if max_spawn == -1 else min(max_spawn - _spawned, spawn_poses.size()));
	for idx in available:
		var pos : Vector2 = spawn_poses[idx];
		
		var entity : ExchangeType = spawn_entity.instantiate();
		entity.alignment = alignment;
		from.get_tree().current_scene.add_child(entity);
		entity.global_position = pos;
		
		entity.killed.connect(_dec_count, CONNECT_DEFERRED);
		summoned.emit(entity);
	_spawned += available;
