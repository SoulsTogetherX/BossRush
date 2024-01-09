class_name Boss extends ExchangeType

class _Boss_Action:
	var call_fuc : Callable;
	var delay : float;
	
	func _init(foo : Callable, time : float) -> void:
		call_fuc = foo;
		delay = time;

@export var _movement_area : Area2D;

@onready var _sequence_timer: Timer = $sequence_timer;

var _sequence : Array[_Boss_Action] = [];
var _sequence_idx : int = 0;

func _add_to_sequence(call_fuc : Callable, time : float) -> void:
	_sequence.append(_Boss_Action.new(call_fuc, time));

func _next_sequence() -> void:
	if _sequence.is_empty():
		return;
	
	if _sequence_idx >= _sequence.size():
		_sequence_idx = 0;
	
	var action : _Boss_Action = _sequence[_sequence_idx];
	_call_at(action.call_fuc, action.delay);
	_sequence_idx += 1;

func _call_at(call_fuc : Callable, time : float) -> void:
	call_fuc.call();
	_sequence_timer.wait_time = time;
	_sequence_timer.start();

func _on_health_monitor_killed() -> void:
	queue_free();

func get_player() -> Vector2:
	return PlayerInfo.player.global_position;

func aim_at_player() -> float:
	return (PlayerInfo.player.global_position - global_position).angle();

func can_move_here(pos : Vector2) -> bool:
	var pp = PhysicsPointQueryParameters2D.new()
	pp.collide_with_areas = true 
	pp.position = pos;
	pp.collision_mask = 16;
	return !get_world_2d().direct_space_state.intersect_point(pp, 1).is_empty();

func die() -> void:
	_sequence_timer.stop();
