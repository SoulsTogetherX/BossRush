extends Control

@onready var _health_back: TextureRect = $Health_Back;
@onready var _health: TextureRect = $Health;

const HALF_HEARTH_WIDTH : int = 16;

func set_max_health(amount : int) -> void:
	_health_back.size.x = amount * HALF_HEARTH_WIDTH;

func set_health(amount : int) -> void:
	_health.size.x = amount * HALF_HEARTH_WIDTH;
