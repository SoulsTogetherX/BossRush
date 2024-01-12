extends Line2D

@export var follow : Node;
@export var trailLength : int = 0;

func _ready() -> void:
	top_level = true;
	global_position = Vector2.ZERO;
	global_rotation = 0;

func _process(_delta: float) -> void:
	add_point(follow.global_position);
	while get_point_count() > trailLength:
		remove_point(0);
	
