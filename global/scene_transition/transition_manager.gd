extends CanvasLayer

@onready var fade: ColorRect = $fade;

var _tween : Tween;

signal start_transition;
signal load_transition;
signal end_transition;

func fade_in() -> void:
	if _tween:
		_tween.kill();
	_tween = create_tween();
	
	_tween.tween_callback(_emit_signal.bind(start_transition));
	_tween.tween_property(fade, "modulate:a", 1.0, 0.2);
	_tween.tween_callback(_emit_signal.bind(load_transition));

func fade_out() -> void:
	if _tween:
		_tween.kill();
	_tween = create_tween();
	
	_tween.tween_property(fade, "modulate:a", 0.0, 0.2);
	_tween.tween_callback(_emit_signal.bind(end_transition));

func _emit_signal(sig : Signal) -> void:
	sig.emit();
