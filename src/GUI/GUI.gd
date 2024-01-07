extends CanvasLayer

@onready var _health_display: Control = $Control/VBoxContainer/Bottom/Health_Display
@onready var _fade: ColorRect = $Control/fade

var tween : Tween;

func update_max_health(amount : int) -> void:
	_health_display.set_max_health(amount);
func update_health(amount : int) -> void:
	_health_display.set_health(amount);

func fade_in() -> void:
	if tween:
		tween.kill();
	
	tween = create_tween();
	tween.tween_property(_fade, "modulate:a", 1.0, 0.5);
func fade_out() -> void:
	if tween:
		tween.kill();
	
	tween = create_tween();
	tween.tween_property(_fade, "modulate:a", 0.0, 0.5);

