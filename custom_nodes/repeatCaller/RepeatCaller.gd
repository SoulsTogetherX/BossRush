## A addition [Node] that calls a given method repeatedly over an
## interval or an indeterminate amount of time.
## @experimental
class_name RepeatCaller extends Node

## Signals a finished calling interval
signal timeout;

## Defines which frames the passed method will be called on.
enum RepeatProcessCallback {
	REPEAT_PROCESS_PHYSICS = 0, ## Physics process frames
	REPEAT_PROCESS_IDLE    = 1, ## Process frames
	};

var _timer_interval : Timer;
var _timer_delay : Timer;
var _stopped : bool = false;

## If this member is set to [code]true[/code], this [Node] will immediately
## start it's callbacks.
@export var autostart : bool  = false;
## If this member is set to [code]true[/code], this [Node] will not process
## until unpaused, even if [method start] is called.
@export var paused : bool  = false:
	get:
		return _timer_interval.paused;
	set(val):
		_timer_interval.paused = val;
		if val == true:
			stop();
			return;
		_update_processing();
## If this member is set to [code]true[/code], this [Node] will ignore
## [member Engine.time_scale].[br][br]
##
## [b]NOTE[/b]: not implemented yet.
@export var ignore_time_scale : bool  = false;
## The interval, in seconds, that this [Node] will call back the provided method.[br][br]
##
## [b]NOTE[/b]: If [member interval] is equal to [code]0[/code], this
## [Node] will continue until manually stopped. See [method stop].
@export var interval : float = 1.0:
	set(val):
		interval = max(0, val);
		if interval != 0:
			_timer_interval.wait_time = interval;
## The delay, in seconds, that this [Node] will wait between method calls.[br][br]
##
## [b]NOTE[/b]: If [member interval] is equal to [code]0[/code], this
## [Node] will not have any delay between function calls.
@export var delay : float = 0.0:
	set(val):
		delay = max(0, val);
		if delay != 0:
			_timer_delay.wait_time = delay;
		if !_timer_delay.is_stopped():
			_update_processing();
## Defines which frames the passed method will be called on.[br][br]
##
## See [enum RepeatProcessCallback].
@export var processType : RepeatProcessCallback = RepeatProcessCallback.REPEAT_PROCESS_PHYSICS:
	set(val):
		processType = val;
		_update_processing();
## The provided [Callable] that will be repeatedly called.[br]
## If not set, a dummy function will be called instead. The dummy function does nothing.
@export var call_func   : Callable = (func() -> void: return):
	set(val):
		if call_func == null:
			_timer_delay.timeout.disconnect(call_func);
		call_func = val;
		if val != null:
			_timer_delay.timeout.connect(call_func);
## The provided [Callable] that will be repeatedly when the interval has ended. See
## [member interval].[br]
## If not set, a dummy function will be called instead. The dummy function does nothing.[br][br]
##
## [b]NOTE[/b]: This can be used with [method Node.queue_free] to automatically clear this node
## after completion.
@export var end_func   : Callable = (func() -> void: return):
	set(val):
		if end_func == null:
			_timer_interval.timeout.disconnect(end_func);
		end_func = val;
		if val != null:
			_timer_interval.timeout.connect(end_func);

func _init() -> void:
	_timer_interval = Timer.new();
	_timer_interval.one_shot = true;
	_timer_interval.timeout.connect(_timeout);
	add_child(_timer_interval);
	_timer_interval.stop();
	
	_timer_delay = Timer.new();
	_timer_delay.one_shot = false;
	add_child(_timer_delay);
	_timer_delay.stop();

func _ready() -> void:
	if interval > 0:
		_timer_interval.wait_time = interval;
	else:
		_timer_interval.stop();
	if delay > 0:
		_timer_delay.wait_time = delay;
	
	if !autostart:
		stop();

func _timeout() -> void:
	timeout.emit();
	stop();

func _update_processing() -> void:
	_timer_interval.process_callback = (processType as Timer.TimerProcessCallback);
	
	if delay > 0:
		set_process(false);
		set_physics_process(false);
		_timer_delay.process_callback = (processType as Timer.TimerProcessCallback);
		_timer_delay.start();
		return;
	
	_timer_delay.stop();
	if processType == RepeatProcessCallback.REPEAT_PROCESS_PHYSICS:
		set_process(false);
		set_physics_process(true);
	else:
		set_process(true);
		set_physics_process(false);

func _process(_delta: float) -> void:
	call_func.call();

func _physics_process(_delta: float) -> void:
	call_func.call();

## Starts the callback. When called, this also resets the interval.[br][br]
##
## [b]NOTE[/b]: This method will not start a paused timer where it was paused.
func start() -> void:
	if paused:
		return;
	_update_processing();
	
	if interval > 0:
		_timer_interval.start();
	if delay > 0:
		_timer_delay.start();
	_stopped = false;

## Stops the callback.
func stop() -> void:
	if _stopped:
		return;
	
	set_process(false);
	set_physics_process(false);
	_timer_interval.stop();
	_timer_delay.stop();
	_stopped = true;

## Returns if the callback is stopped.
func is_stopped() -> bool:
	return _stopped;

## Returns if the [member interval] is greater than [code]0[/code],
## then it returns the remaining time of the [member interval].[br]
## Else, returns [code]-1[/code],
func time_left() -> float:
	if interval > 0:
		return _timer_interval.time_left;
	else:
		return -1;

## Returns if the [member delay] is greater than [code]0[/code],
## then it returns the remaining time of the [member delay].[br]
## Else, returns [code]-1[/code],
func time_left_delay() -> float:
	if delay > 0:
		return _timer_delay.time_left;
	else:
		return -1;
