class_name Boss extends ExchangeType

class _Boss_Action:
	var call_fuc : Callable;
	var delay : float;
	
	func _init(foo : Callable, time : float) -> void:
		call_fuc = foo;
		delay = time;

@export var _reward_manager : RewardManager;

@onready var _sequence_timer: Timer = $sequence_timer;

var _sequence : Array[_Boss_Action] = [];
var _sequence_idx : int = 0;

signal before_swap;
signal after_swap;

func _ready() -> void:
	super();
	PlayerInfo.boss = self;

func _clear_sequence() -> void:
	_sequence.clear();
	_sequence_idx = 0;

func _add_to_sequence(call_fuc : Callable, time : float) -> void:
	_sequence.append(_Boss_Action.new(call_fuc, time));

func _next_sequence(skip : int = 0) -> void:
	if _sequence.is_empty():
		return;
	
	before_swap.emit();
	
	_sequence_idx += skip;
	var action : _Boss_Action = _sequence[_sequence_idx % _sequence.size()];
	_call_at(action.call_fuc, action.delay);
	_sequence_idx += 1;
	
	after_swap.emit();

func _reset_sequence() -> void:
	_sequence_idx = 0;
	_next_sequence();

func _call_at(call_fuc : Callable, time : float) -> void:
	_sequence_timer.stop()
	_sequence_timer.wait_time = time;
	_sequence_timer.start();
	
	call_fuc.call();

func _force_move(call_fuc : Callable, time : float, skip : int = 1) -> void:
	call_fuc.call();
	_sequence_timer.wait_time = time;
	_sequence_timer.start();
	
	_sequence_idx = (_sequence_idx + skip) % _sequence.size();

func _on_health_monitor_killed() -> void:
	queue_free();

func get_player() -> Vector2:
	return PlayerInfo.player.global_position;

func aim_at_player() -> float:
	return (PlayerInfo.player.global_position - global_position).angle();

func die() -> void:
	_sequence_timer.stop();
	_reward_manager._spawn_orbs(self);

func toggle_shield(_toggle : bool) -> void:
	pass;

func get_sequence_index() -> int:
	return _sequence_idx;

func get_minons() -> Array[Node2D]:
	return [];
