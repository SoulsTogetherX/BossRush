## The holder and runner of all attached [State] objects.[br]
## To use, add [State] and [AnimateState] objects as children to this [Node],
## set the [member starting_state] as once of the children [State] objects,
## and then attach this [StateMachine] to a [StateOverhead] object.
## @experimental
class_name StateMachine extends Node

## The name of the current [StateMachine]. This is an unique name identifier so
## this [StateMachine] may be found and utilized in an externel setting.[br][br]
##
## [b]NOTE[/b]: If this id is the same as another [StateMachine]'s in the same
## [StateOverhead], the id may be changed to be unique. If left empty, the
## value will default to [code]"blank"[/code].
@export_placeholder("Machine ID") var _name_id : String;

## The first [State] this [StateMachine] will run on initialization.[br][br]
##
## [b]NOTE[/b]: A [StateMachine] is initialized by an attached [StateOverhead] object.
@export var starting_state  : State;
var _current_state          : State;
var _states                 : Array[State];
var _animate_interval_timer : Array[SafeOneshot];
var _current_animate_length : float;
var _current_mode           : Animation.LoopMode

signal state_changed;

## Initializes this [StateMachine] by giving each attached child [StateBase] a reference
## to the actor object it belongs to, then enters the default [member starting_state].
##
## This will also attach the [param actor] and [param animationPlayer] when needed.
func init(actor : Node, animationPlayer : AnimationPlayer, stateOverhead : StateOverhead) -> void:
	for child in get_children():
		if child is State:
			child._actor = actor;
			child._animationPlayer = animationPlayer;
			child._stateOverhead = stateOverhead;
			child._machine_id = _name_id;
			
			if child is AnimateState:
				_prebake_intervals(child);
			
			_states.append(child);
	
	assert(starting_state in _states, "ERROR - StateMachine:init - Cannot find starting_state in any of this node's children");
	
	for state in _states:
		state.state_ready();
	
	_change_state(starting_state);

## Calls [method State.process_input] on the running [State] in similar usage as
## [member Node._unhandled_input].
func process_input(event: InputEvent) -> void:
	var new_state = _current_state.process_input(event);
	if new_state:
		_change_state(new_state);

## Calls [method State.process_physics] on the running [State] in similar usage as
## [member Node._physics_process].
func process_physics(delta: float) -> void:
	var new_state = _current_state.process_physics(delta);
	if new_state:
		_change_state(new_state);

## Calls [method State.process_frame] on the running [State] in similar usage as
## [member Node._process].
func process_frame(delta: float) -> void:
	var new_state = _current_state.process_frame(delta);
	if new_state:
		_change_state(new_state);


func update() -> void:
	var new_state = _current_state.update();
	if new_state:
		_change_state(new_state);


func _animate_interval(interval : float) -> void:
	if not _current_state is AnimateState:
		return;
	
	var new_state = _current_state.on_interval(interval);
	if new_state:
		_change_state(new_state);

func _animate_interval_end() -> void:
	if not _current_state is AnimateState:
		return;
	
	var new_state = _current_state.on_end_animation();
	_disconnect_all_settup();
	if new_state:
		_change_state(new_state);
	else:
		match _current_mode:
			Animation.LoopMode.LOOP_LINEAR:
				_connect_all_settup()
			Animation.LoopMode.LOOP_PINGPONG:
				_connect_all_pinpong_settup();

func _change_state(new_state: State) -> void:
	if _current_state:
		_current_state.exit();
	
	_current_state = new_state;
	if _current_state is AnimateState:
		_current_animate_length = _current_state._animationPlayer.get_animation(_current_state.get_animation()).length;
		_connect_all_settup();
	_current_state.enter();
	
	state_changed.emit();
	_current_state._stateOverhead.state_changed.emit(get_id());

func _disconnect_all_settup() -> void:
	for timer in _animate_interval_timer:
		timer.kill();

func _connect_all_settup() -> void:
	for interval in _current_state._prebaked_intervals:
		_animate_interval_timer.append(SafeOneshot.new().init(get_tree(), interval));
		_animate_interval_timer.back().timeout.connect(_animate_interval.bind(interval));
	
	_animate_interval_timer.append(SafeOneshot.new().init(get_tree(), _current_animate_length));
	_animate_interval_timer.back().timeout.connect(_animate_interval_end);
	
	_current_state._animationPlayer.play(_current_state.get_animation());

func _connect_all_pinpong_settup() -> void:
	for interval in _current_state._prebaked_intervals:
		_animate_interval_timer.append(SafeOneshot.new().init(get_tree(), _current_animate_length - interval));
		_animate_interval_timer.back().timeout.connect(_animate_interval.bind(_current_animate_length - interval));
	
	_animate_interval_timer.append(SafeOneshot.new().init(get_tree(), _current_animate_length));
	_animate_interval_timer.back().timeout.connect(_animate_interval_end);
	
	_current_state._animationPlayer.play(_current_state.get_animation());

func _prebake_intervals(state : AnimateState) -> void:
	assert(state._animationPlayer.has_animation(state.get_animation()), "Error - StateMachine::_prebake_intervals(state : AnimateState) - Attempted to access animation name '" + state.get_animation() + "' not in AnimationPlayer.");
	var animation : Animation = state._animationPlayer.get_animation(state.get_animation());
	_current_animate_length = animation.length;
	_current_mode           = animation.loop_mode;
	
	var set_ : Array[float] = [];
	set_ = state.get_intervals().\
			filter(func(val : float): return 0 < val && val < _current_animate_length);
	set_.append_array(state.get_interval_percentage().\
			filter(func(val : float): return 0 < val && val < 1.).\
			map(func(val : float): return val * _current_animate_length));
	
	for val in set_:
		if not val in state._prebaked_intervals:
			state._prebaked_intervals.append(val);

## Changes the running [State] to an accessible one with the given name identifier.[br]
## First calls any exit logic on the current state, then the enter logic of the new
## state.[br][br]
##
## [b]NOTE[/b]: This function will [i]stop the program[/i] if the given name identifier
## cannot be found in the accessible children.
func change_state(new_state_name: String) -> void:
	var new_state = null;
	for state in _states:
		if state.get_id() == new_state_name:
			new_state = state;
			break;
	assert(new_state != null, "ERROR: given state_name cannot be found in state array.");
	if new_state.lock:
		return;
	
	if _current_state is AnimateState:
		_disconnect_all_settup();
	_change_state(new_state);

## Returns this [StateMachine] object's name identifier.
func get_id() -> String:
	return _name_id;

## Returns the ids of all attached [State] objects.
func get_state_ids() -> Array[String]:
	var ret : Array[String] = [];
	for state in _states:
		ret.append(state.get_state_id());
	return ret;

## Checks to see if this [StateMachine] has an attached [State] with the given id.
func has_state(state_id : String) -> bool:
	return state_id in get_state_ids();

func is_in_state(state_id : String) -> bool:
	return _current_state.get_id() == state_id;

func is_in_states(state_ids : Array[String]) -> bool:
	return _current_state.get_id() in state_ids;
