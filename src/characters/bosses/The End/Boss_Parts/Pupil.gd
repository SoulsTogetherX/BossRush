extends Sprite2D

@export var distance_allowed : float = 10;
@export var looking : bool = true:
	set(val):
		if !val:
			position = Vector2.ZERO;
		set_physics_process(val);
		looking = val;
@export var target : Node2D;

func _physics_process(_delta: float) -> void:
	position = (target.global_position - global_position).normalized() * distance_allowed;
