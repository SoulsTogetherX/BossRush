class_name Orb extends Node2D

@export var exchange : Exchangable;

@onready var title_display: Label = $TitleDisplay;
@onready var color: PointLight2D = $color;

var _selected : bool = false;
var _tween_decorate : Tween;
var _tween_move : Tween;

var reset_pos : Vector2;
var unselected : bool = false;
var disable : bool = true;
var disable_click : bool = false
var staged : bool = false;
var shake : bool = false:
	set(val):
		shake = val;
		_shake_ramp = 0.0;
		set_process(val);

signal stage(orb : Orb);
signal unstage(orb : Orb);
signal destroyed();

func _ready() -> void:
	z_index = 3;
	
	reset_pos = position;
	set_exchange(exchange);
	set_process(shake);
	
	$color.scale = Vector2(0.95, 0.95);
	var tween = create_tween().set_loops();
	tween.set_trans(Tween.TRANS_SINE);
	tween.set_ease(Tween.EASE_IN_OUT);
	tween.tween_property($color, "scale", Vector2(1.05, 1.05), 1.5);
	tween.tween_property($color, "scale", Vector2(0.95, 0.95), 1.5);
	
	$color.texture.gradient.colors = $color.texture.gradient.colors.duplicate();

func set_exchange(exchan : Exchangable) -> void:
	if exchan:
		if exchan is HealthExchangable:
			modulate = Color.LIME_GREEN;
		elif exchan is AttackExchangable:
			modulate = Color.RED;
		elif exchan is MovementExchangable:
			modulate = Color.DEEP_SKY_BLUE;
		
		$Sprite2D.frame = exchan.symbol;
		title_display.text = exchan.name;
	else:
		modulate = Color.WHITE;
		$Sprite2D.frame = 0;
		title_display.text = "Empty";
	
	$color.color = modulate;

func _draw() -> void:
	draw_circle(Vector2.ZERO, 14, Color.WHITE);
	draw_circle(Vector2.ZERO, 12, Color.BLACK);

func _on_click(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && !disable_click:
		if event.pressed:
			stage.emit(self);
			staged = true;
		elif event.is_released():
			if staged:
				unstage.emit(self);
				staged = false;

var _choice_idx : int = 0;
@onready var _choices : Array[AudioStreamPlayer] = [$Choice_1, $Choice_2, $Choice_3, $Choice_4];
func _on_mouse_entered() -> void:
	if disable:
		return;
	if _tween_decorate:
		_tween_decorate.kill();
	
	_tween_decorate = create_tween();
	_tween_decorate.set_trans(Tween.TRANS_SINE).set_parallel();
	_tween_decorate.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2);
	_tween_decorate.tween_property(title_display, "modulate:a", 1.0, 0.4);
	
	if unselected:
		_tween_decorate.tween_property(self, "modulate:a", 1.0, 0.4);
	_selected = true;
	
	if !_choices[_choice_idx].playing:
		_choices[_choice_idx].play_random();
		_choice_idx = (_choice_idx + 1) & 3;

func _on_mouse_exited() -> void:
	if disable:
		return;
	if _tween_decorate:
		_tween_decorate.kill();
	
	_tween_decorate = create_tween();
	_tween_decorate.set_trans(Tween.TRANS_SINE).set_parallel();
	_tween_decorate.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2);
	_tween_decorate.tween_property(title_display, "modulate:a", 0.0, 0.2);
	
	if unselected:
		_tween_decorate.tween_property(self, "modulate:a", 0.2, 0.4);
	_selected = false;
	
	if staged:
		unstage.emit(self);
		staged = false;

var _shake_ramp = 0.0;
func _process(_delta: float) -> void:
	position = reset_pos + Vector2(randf(), randf()) * _shake_ramp;
	_shake_ramp = min(_shake_ramp + 0.05, 5.0);

func reset(scale_ : bool, position_ : bool, title : bool, flow : bool) -> void:
	disable = false;
	if _tween_decorate:
		_tween_decorate.kill();
	
	_tween_decorate = create_tween();
	_tween_decorate.set_trans(Tween.TRANS_SINE).set_parallel();
	if scale_:
		_tween_decorate.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2);
	if position_:
		if _tween_move:
			_tween_move.kill();
		
		_tween_move = create_tween();
		_tween_move.set_trans(Tween.TRANS_SINE).set_parallel();
		_tween_move.tween_property(self, "position", reset_pos, 0.6);
	if title:
		_tween_decorate.tween_property(title_display, "modulate:a", 0.0, 0.2);
	if flow:
		_tween_decorate.chain().tween_callback(toggle_flow_particles.bind(true));
	_tween_decorate.chain().tween_property(self, "z_index", 3, 0.0);

func toggle_flow_particles(toggle : bool) -> void:
	$station_particle.emitting = toggle;

func destroy() -> void:
	$station_particle.emitting = false;
	$trail_particle.emitting = false;
	$break_particle.emitting = true;
	$break_particle.global_position = global_position;
	disable = true;
	disable_click = true;
	
	self_modulate.a = 0.0;
	
	$Sprite2D.visible = false;
	title_display.visible = false;
	
	var tween : Tween = create_tween();
	tween.tween_interval(2.0);
	
	await tween.finished;
	destroyed.emit();

func _tween_light(interval : float) -> void:
	$color.texture.gradient.colors[0].a = interval; 
