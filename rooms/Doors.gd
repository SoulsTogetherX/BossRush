extends Node

@export var enter : Node2D;
@export var exit : Node2D;
@export var extra : Node2D;

func _close_doors_comparable(_amount : int) -> void:
	close_doors();

func open_doors() -> void:
	var tween : Tween = create_tween().set_parallel();
	tween.tween_property(exit, "modulate:a", 0.0, 0.8);
	tween.tween_property(enter, "modulate:a", 0.0, 0.8);
	tween.chain().tween_property(exit, "collision_layer", 0, 0.0);
	tween.tween_property(enter, "collision_layer", 0, 0.0);
	
	if extra:
		extra.z_index = 1;
		print("0")

func close_doors() -> void:
	enter.collision_layer = 1;
	exit.collision_layer = 1;
	var tween : Tween = create_tween().set_parallel();
	tween.tween_property(enter, "modulate:a", 1.0, 0.8);
	tween.tween_property(exit, "modulate:a", 1.0, 0.8);
	
	if extra:
		extra.z_index = -1;
		print("1")
