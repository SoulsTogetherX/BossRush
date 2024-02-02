extends TextureButton

signal clicked;

var _animation_tween : Tween;
var _pos : Vector2;

func _ready() -> void:
	mouse_entered.connect(hover);
	mouse_exited.connect(unhover);
	pressed.connect(click);
	
	_pos = position;

func hover() -> void:
	if _animation_tween:
		_animation_tween.kill();
	_animation_tween = create_tween().set_parallel();
	
	_animation_tween.tween_property(self, "scale", Vector2.ONE * 1.8, 0.2);
	_animation_tween.tween_property(self, "position", _pos + (size * 0.1), 0.2);

func unhover() -> void:
	if _animation_tween:
		_animation_tween.kill();
	_animation_tween = create_tween().set_parallel();
	
	_animation_tween.tween_property(self, "scale", Vector2.ONE * 2, 0.2);
	_animation_tween.tween_property(self, "position", _pos, 0.2);

func click() -> void:
	var tw := create_tween().set_parallel();
	tw.set_trans(Tween.TRANS_ELASTIC);
	
	tw.tween_property(self, "scale", Vector2.ONE * 2.1, 0.1);
	tw.tween_property(self, "position", _pos - (size * 0.05), 0.1);
	
	tw.chain().tween_property(self, "scale", Vector2.ONE * 2, 0.1);
	tw.tween_property(self, "position", _pos, 0.1);
	
	await tw.finished;
	
	clicked.emit();
