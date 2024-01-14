class_name AttackExchangable extends Exchangable

@export var weapon_scene : PackedScene;
@export var weapon_range : float;
@export var delta : int = -1;
@export var cooldown : float = 0.0;

var _weapon : Weapon = null;
var _on_cooldown : bool = false;

signal cooldown_end;

var _cooldown_timer : SceneTreeTimer;

func reset() -> void:
	super();
	_weapon = null;
	_on_cooldown = false;
	if is_instance_valid(_cooldown_timer) && _cooldown_timer && _cooldown_timer.timeout.is_connected(_on_cooldown_end): 
		_cooldown_timer.timeout.disconnect(_on_cooldown_end);

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
	force_handle_attack(from, target, alignment);

func force_handle_attack(from : Node2D, target : Vector2, alignment : HurtBox.ALIGNMENT) -> void:
	if self is AttackInstant && from == _weapon:
		self.playSound.connect(_weapon.play_sound, CONNECT_ONE_SHOT);
	
	if from == _weapon:
		await _weapon.handle_attack(self);
	_on_attack(from, target, alignment);

func _cooldown_check(scene : SceneTree) -> bool:
	if _on_cooldown:
		return false;
	
	_on_cooldown = true;
	_cooldown_timer = scene.create_timer(cooldown);
	_cooldown_timer.timeout.connect(_on_cooldown_end)
	return true;

func _on_cooldown_end() -> void:
	_on_cooldown = false;
	cooldown_end.emit();
