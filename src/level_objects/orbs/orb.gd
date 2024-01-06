extends Node2D

@export var exchange : Exchangable;

var _selected : bool = false;
var _tween : Tween;

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, Color.WHITE);
	draw_circle(Vector2.ZERO, 8, Color.BLACK);

func _on_click(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		
		
		print(_selected)

func _on_mouse_entered() -> void:
	if _tween:
		_tween.kill();
	_tween = create_tween();
	_tween.set_trans(Tween.TRANS_SINE);
	_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2);
	
	_selected = true;

func _on_mouse_exited() -> void:
	if _tween:
		_tween.kill();
	_tween = create_tween();
	_tween.set_trans(Tween.TRANS_SINE);
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2);
	
	_selected = false;
