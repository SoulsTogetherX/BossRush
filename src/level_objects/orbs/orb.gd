class_name Orb extends Node2D

@export var exchange : Exchangable;

@onready var title_display: Label = $TitleDisplay;
@onready var color: PointLight2D = $color;

var _selected : bool = false;
var _tween : Tween;
var reset_pos : Vector2;
var disable : bool = false;

signal stage(orb : Orb);

func _ready() -> void:
	reset_pos = position;
	
	if exchange:
		if exchange is HealthExchangable:
			modulate = Color.LIME_GREEN;
		elif exchange is AttackExchangable:
			modulate = Color.CRIMSON;
		elif exchange is MovementExchangable:
			modulate = Color.CADET_BLUE;
		
		$Sprite2D.frame = exchange.symbol;
		title_display.text = exchange.name;
		
		$color.color = modulate;
		$color.scale = Vector2(0.95, 0.95);
		
		var tween = create_tween().set_loops();
		tween.set_trans(Tween.TRANS_SINE);
		tween.set_ease(Tween.EASE_IN_OUT);
		tween.tween_property($color, "scale", Vector2(1.05, 1.05), 1.5);
		tween.tween_property($color, "scale", Vector2(0.95, 0.95), 1.5);

func _draw() -> void:
	draw_circle(Vector2.ZERO, 14, Color.WHITE);
	draw_circle(Vector2.ZERO, 12, Color.BLACK);

func _on_click(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		stage.emit(self);

func _on_mouse_entered() -> void:
	if disable:
		return;
	
	if _tween:
		_tween.kill();
	_tween = create_tween();
	_tween.set_trans(Tween.TRANS_SINE).set_parallel();
	_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2);
	_tween.tween_property(title_display, "modulate:a", 1.0, 0.4);
	
	_selected = true;

func _on_mouse_exited() -> void:
	if disable:
		return;
	
	if _tween:
		_tween.kill();
	_tween = create_tween();
	_tween.set_trans(Tween.TRANS_SINE).set_parallel();
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2);
	_tween.tween_property(title_display, "modulate:a", 0.0, 0.2);
	
	_selected = false;

func reset(scale_ : bool, position_ : bool, title : bool, flow : bool) -> void:
	if _tween:
		_tween.kill();
	
	_tween = create_tween();
	_tween.set_trans(Tween.TRANS_SINE).set_parallel();
	if scale_:
		_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2);
	if position_:
		_tween.tween_property(self, "position", reset_pos, 0.6);
	if title:
		_tween.tween_property(title_display, "modulate:a", 0.0, 0.2);
	if flow:
		_tween.chain().tween_callback(toggle_flow_particles.bind(true));
	_tween.chain().tween_property(self, "z_index", 1, 0.0);

func toggle_flow_particles(toggle : bool) -> void:
	$station_particle.emitting = toggle;
