extends CanvasLayer

@onready var _health_display: Control = $Control/VBoxContainer/Bottom/Health_Display

var tween : Tween;

func _ready() -> void:
	PlayerInfo.max_health_changed.connect(update_max_health);
	PlayerInfo.health_changed.connect(update_health);

func update_max_health(amount : int) -> void:
	_health_display.set_max_health(amount);
func update_health(amount : int) -> void:
	_health_display.set_health(amount);

