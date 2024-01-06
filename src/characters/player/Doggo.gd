class_name Player extends ExchangeType

@onready var _state_overhead: StateOverhead = $StateOverhead;

func _ready() -> void:
	super();

func get_input() -> Vector2:
	return Vector2(Input.get_axis("right", "left"), Input.get_axis("up", "down")).normalized();

