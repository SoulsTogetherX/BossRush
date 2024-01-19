extends Line2D

@export var follow : Node;
@export var trailLength : int = 8;
@export var emitting : bool = true;

func _ready() -> void:
	top_level = true;
	global_position = Vector2.ZERO;
	global_rotation = 0;
	clear_points();

func _process(_delta: float) -> void:
	if emitting:
		add_point(follow.global_position);
		while get_point_count() > trailLength:
			remove_point(0);
	elif points.size() > 0:
		remove_point(0);

func clear_trail() -> void:
	clear_points();
