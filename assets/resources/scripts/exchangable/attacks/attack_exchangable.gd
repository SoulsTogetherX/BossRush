class_name AttackExchangable extends Exchangable

@export var weapon_scene : PackedScene;
@export var damage : int = 1;

var _weapon : Weapon = null;

func _set_up_sprite(actor : Node2D, distance : float) -> void:
	_weapon = weapon_scene.instantiate();
	_weapon.set_follow(actor, distance);
	actor.get_tree().current_scene.add_child.call_deferred(_weapon);
	_weapon.global_position = actor.global_position;

func _on_attack(_target : Vector2) -> void:
	pass;

func handle_attack(target : Vector2) -> void:
	_on_attack(target);
	if _weapon:
		_weapon.handle_attack();
