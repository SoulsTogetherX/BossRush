@tool
class_name Invincibility extends Resource

@export var i_frames : float;

var _invincible : bool = false;
var _invincibility_timer : SceneTreeTimer;

signal invincible_start;
signal invincible_end;

func reset() -> void:
	if is_instance_valid(_invincibility_timer) && _invincibility_timer:
		_invincibility_timer.timeout.disconnect(_end_invincibility_frames);

func is_invincible() -> bool:
	return _invincible;

func start(tree : SceneTree) -> void:
	if !_invincible:
		_start_invincibility_frames(tree);

func _start_invincibility_frames(tree : SceneTree) -> void:
	if i_frames > 0 && tree:
		_invincible = true;
		invincible_start.emit();
		tree.create_timer(i_frames).timeout.connect(_end_invincibility_frames);

func _end_invincibility_frames() -> void:
	invincible_end.emit();
	_invincible = false;
