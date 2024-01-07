class_name Player extends ExchangeType

@onready var _state_overhead: StateOverhead = $StateOverhead;

func _ready() -> void:
	super();

func get_input() -> Vector2:
	return Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized();

func get_animation_modifer() -> String:
	var dir = wrapi(int(snapped(velocity.angle(), PI/4) / (PI/4)), 0, 8);
	match dir:
		0:
				#left
			scale.x = scale.y;
			return "left";
		1:
				#left down
			scale.x = scale.y;
			return "down_left";
		2:
				#down
			scale.x = scale.y;
			return "down";
		3:
				#right down
			scale.x = -scale.y;
			return "down_left";
		4:
				#right
			scale.x = -scale.y;
			return "left";
		5:
				#right up
			scale.x = -scale.y;
			return "up_left";
		6:
				#up
			scale.x = -scale.y;
			return "up";
		7:
				#left up
			scale.x = scale.y;
			return "up_left";
	return "";
