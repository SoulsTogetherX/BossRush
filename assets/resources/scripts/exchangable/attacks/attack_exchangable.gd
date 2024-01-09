class_name AttackExchangable extends Exchangable

@export var weapon_scene : PackedScene;
@export var weapon_range : float;
@export var delta : int = -1;
@export var cooldown : float = 0.0;

var _weapon : Weapon = null;
var _on_cooldown : bool = false;

signal cooldown_end;

func reset() -> void:
	_weapon = null;

func _set_up_sprite(actor : Node2D, distance : float) -> Weapon:
	if !weapon_scene:
		return;
	
	_weapon = weapon_scene.instantiate();
	_weapon.set_follow(actor, distance);
	actor.get_tree().current_scene.add_child.call_deferred(_weapon);
	_weapon.global_position = actor.global_position;
	
	return _weapon;

func _on_attack(_from : Node2D, _target : Vector2, _alignment : HurtBox.ALIGNMENT) -> void:
	pass;

func handle_attack(from : Node2D, target : Vector2, alignment : HurtBox.ALIGNMENT) -> void:
	if !_cooldown_check(from.get_tree()):
		return;
	_on_attack(from, target, alignment);
	if from == _weapon:
		_weapon.handle_attack(self);

func _cooldown_check(scene : SceneTree) -> bool:
	if _on_cooldown:
		return false;
	
	_on_cooldown = true;
	scene.create_timer(cooldown).timeout.connect(_on_cooldown_end);
	return true;

func _on_cooldown_end() -> void:
	_on_cooldown = false;
	cooldown_end.emit();
