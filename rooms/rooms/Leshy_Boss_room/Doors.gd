extends Node

func _close_doors_comparable(_amount : int) -> void:
	close_doors();

func open_doors() -> void:
	var tween : Tween = create_tween().set_parallel();
	tween.tween_property($Door_up, "modulate:a", 0.0, 0.8);
	tween.tween_property($Door_left, "modulate:a", 0.0, 0.8);
	tween.chain().tween_property($Door_up, "collision_layer", 0, 0.0);
	tween.tween_property($Door_left, "collision_layer", 0, 0.0);

func close_doors() -> void:
	$Door_left.collision_layer = 1;
	$Door_up.collision_layer = 1;
	var tween : Tween = create_tween().set_parallel();
	tween.tween_property($Door_left, "modulate:a", 1.0, 0.8);
	tween.tween_property($Door_up, "modulate:a", 1.0, 0.8);
