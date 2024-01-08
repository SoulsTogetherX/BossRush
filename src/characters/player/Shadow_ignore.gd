extends Area2D

@onready var _shadow: LightOccluder2D = $Shadow

func _hide_shadow(_area : Area2D) -> void:
	_shadow.visible = false;

func _check_show_shader(_area : Area2D) -> void:
	if get_overlapping_areas().is_empty():
		_shadow.visible = true;
