## @experimental
class_name SafeOneshot extends RefCounted

enum SAFE_ONESHOT_STATE {RUNNING, KILLED}

var state : SAFE_ONESHOT_STATE = SAFE_ONESHOT_STATE.RUNNING;

signal timeout;
signal killed_timeout;

signal killed;
signal revived;

func init(
		tree : SceneTree,
		time_sec : float,
		process_always : bool = true,
		process_in_physics : bool = false,
		ignore_time_scale : bool = false
		) -> SafeOneshot:
	tree.create_timer(time_sec, process_always, process_in_physics, ignore_time_scale).timeout.connect(_fin);
	return self;

func _fin() -> void:
	if state == SAFE_ONESHOT_STATE.RUNNING:
		timeout.emit();
	else:
		killed_timeout.emit();

func kill() -> void:
	state = SAFE_ONESHOT_STATE.KILLED;
	killed.emit();

func revive() -> void:
	state = SAFE_ONESHOT_STATE.RUNNING;
	revived.emit();
