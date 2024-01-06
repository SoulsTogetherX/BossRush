## The base [State] for all [StateMachine] objects.[br]
## Extend from this class to make a custom [State][br]
## To use, add this as a child to a [StateMachine] object.
## @experimental
class_name State extends Node

## Easy access to the object, typically a [CharacterBody2D] or [CharacterBody3D], in which this
## [State] will affect.
@warning_ignore("unused_private_class_variable")
var _actor : Node;
## Easy access to the animationPlayer in which this [State] will affect.
@warning_ignore("unused_private_class_variable")
var _animationPlayer : AnimationPlayer;
## The main overhead. Access this to access all [StateMachine] objects.[br]This is useful in case
## you want to affect the [State] of other [StateMachine], within other [State] objects.
@warning_ignore("unused_private_class_variable")
var _stateOverhead : StateOverhead;
## The id of the [StateMachine] this [State] is in.
@warning_ignore("unused_private_class_variable")
var _machine_id : String;

var lock : bool = false;

## The id of the current [State]. This is an unique name identifier so this [State] may be found
## and utilized outside of the current [StateMachine].
func get_id():
	return "empty";

## The initialization of this [State]. This is called after [member _actor] emited signal
## [signal Node.ready];
func state_ready() -> void:
	pass;

## This method runs once when this [State] is entered. This is called after the [method exit] of
## the previous [State].
func enter() -> void:
	pass;

## This method runs once when this [State] is exited. This is called before the [method enter] of
## the next [State].
func exit() -> void:
	pass;

## A [method Node._unhandled_input] equivalent for [State] objects.[br]
## This function is only run when this [State] is the current [State] of the above [StateMachine].
func process_input(_event: InputEvent) -> State:
	return null;

## A [method Node._physics_process] equivalent for [State] objects.[br]
## This function is only run when this [State] is the current [State] of the above [StateMachine].
func process_physics(_delta: float) -> State:
	return null;

## A [method Node._process] equivalent for [State] objects.[br]
## This function is only run when this [State] is the current [State] of the above [StateMachine].
func process_frame(_delta: float) -> State:
	return null;


func update() -> State:
	return null;
