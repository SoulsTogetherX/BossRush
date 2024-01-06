@tool
## @experimental
class_name StateOverhead extends Node

## Checks if this [StateOverhead] object affects a given object.[br][br]
##
## [b]Note[/b]: Changing this value during runtime does nothing.
@export var _usesActor : bool = false:
	set(val):
		if !Engine.is_editor_hint():
			return;
		_usesActor = val;
		notify_property_list_changed();
## Checks if this [StateOverhead] object will use an animationPlayer.[br][br]
##
## [b]Note[/b]: Changing this value during runtime does nothing.
var _usesAnimationPlayer : bool:
	set(val):
		if !Engine.is_editor_hint():
			return;
		_usesAnimationPlayer = val;
		notify_property_list_changed();
## The actor that will give assigned to every [State]. Typically a [CharacterBody2D] or [CharacterBody3D].[br][br]
##
## Shown in the editor window when [member _usesActor] is [code]true[/code].
var _actor;
var _animationPlayer;
var _state_machines : Dictionary;

signal state_changed(machine_id : String);

func _get_property_list():
	var properties = [];
	if _usesActor:
		properties.append({
			name  = "_actor",
			type  = TYPE_OBJECT,
			hint  = PROPERTY_HINT_NODE_TYPE,
			usage = PROPERTY_USAGE_DEFAULT,
		});
	properties.append({
		name  = "_usesAnimationPlayer",
		type  = TYPE_BOOL,
		usage = PROPERTY_USAGE_DEFAULT,
	});
	if _usesAnimationPlayer:
		properties.append({
			name  = "_animationPlayer",
			type  = TYPE_OBJECT,
			hint  = PROPERTY_HINT_NODE_TYPE,
			hint_string = "AnimationPlayer",
			usage = PROPERTY_USAGE_DEFAULT,
		});
	return properties;

func _property_can_revert(property: StringName) -> bool:
	match property:
		"_usesAnimationPlayer":
			return true;
	return false;

func _property_get_revert(property : StringName) -> Variant:
	match property:
		"_usesAnimationPlayer":
			return false;
	return null;

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process_unhandled_input(false);
		set_physics_process(false);
		set_process(false);
		return;
	
	if _usesActor && not _actor.is_inside_tree():
		await _actor.ready;
	
	if _usesAnimationPlayer && not _animationPlayer.is_inside_tree():
		await _animationPlayer.ready;
	
	for machine in get_children():
		if machine is StateMachine:
			if machine.get_id() == "":
				machine._name_id = "blank";
			
			if _state_machines.has(machine.get_id()):
				machine._name_id = _make_id_unique(machine.get_id());
				_state_machines[_make_id_unique(machine.get_id())] = machine;
			else:
				_state_machines[machine.get_id()] = machine;
			
			machine.init(_actor, _animationPlayer, self);

func _make_id_unique(id : String) -> String:
	id += "_";
	var idx = 0;
	while(_state_machines.has(id + str(idx))):
		idx += 1;
	return id + str(idx);

func _unhandled_input(event: InputEvent) -> void:
	for machine in _state_machines.values():
		if machine:
			machine.process_input(event);

func _physics_process(delta: float) -> void:
	for machine in _state_machines.values():
		if machine:
			machine.process_physics(delta);

func _process(delta: float) -> void:
	for machine in _state_machines.values():
		if machine:
			machine.process_frame(delta);

func update() -> void:
	for machine in _state_machines.values():
		if machine:
			machine.update();

func update_machine(machine_id: String) -> void:
	if _state_machines.has(machine_id):
		_state_machines[machine_id].update();

## Returns the defined acting object of this [StateOverhead] object.
func get_actor() -> Node:
	return _actor;

## Changes the running [StateBase] to an accessible one, within the [StateMachine] corresponding to
## the given index, with the given name identifier.[br][br]
##
## [b]NOTE[/b]: This function will [i]stop the program[/i] if the given name identifier cannot be
## found in the accessible children.
func change_state(machine_id: String, state_name: String) -> void:
	if _state_machines.has(machine_id):
		_state_machines[machine_id].change_state(state_name);

## Returns the ids of all attached [StateMachine] objects.
func get_machine_ids() -> Array[String]:
	return _state_machines.keys();

## Returns a Dictionary, with the ids of all attached [StateMachine] objects as the keys,
## and an [Array] of the ids of each corresponding [StateMachine]'s [StateBase] objects.
func get_state_ids() -> Dictionary:
	var ret = Dictionary();
	for machine_id in _state_machines.keys():
		ret[machine_id] = _state_machines[machine_id].get_state_ids();
	return ret;

## Checks to see if this [StateOverhead] has an attached [StateMachine] with the given id.
func has_machine(machine_id : String) -> bool:
	return _state_machines.has(machine_id);

## Checks to see if this [StateOverhead] has a [StateBase], with the given id, attached to
## one of the attached [StateMachine] objects.
func has_state(state_id : String) -> bool:
	for machine in _state_machines.values():
		if state_id in machine.get_state_ids():
			return true;
	return false;

## Returns the id of the first [StateMachine] with a [StateBase] with the given id.[br]
## Is there are no such [StateMachine] objects, this method will return an empty
## [String].
func find_state(state_id : String) -> String:
	for machine_id in _state_machines.keys():
		if state_id in _state_machines[machine_id].get_state_ids():
			return machine_id;
	return "";

## Checks to see if this [StateOverhead] has a [StateBase], with the given id, attached to
## a [StateMachine] object, with the given id.
func has_machine_state(machine_id : String, state_id : String) -> bool:
	return _state_machines.has(machine_id) && _state_machines[machine_id].has_state(state_id);

## Checks if the running [StateBase]'s name identifier is equal to a passed [String] object.
func is_in_state(machine_id : String, state_id : String) -> bool:
	if _state_machines.has(machine_id):
		return _state_machines[machine_id].is_in_state(state_id);
	return false;

## Checks if the running [StateBase]'s name identifier is withing a passed [Array] of [String] objects.
func is_in_states(machine_id : String, state_ids : Array[String]) -> bool:
	if _state_machines.has(machine_id):
		return _state_machines[machine_id].is_in_states(state_ids);
	return false;
