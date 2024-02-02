extends Orb

@export var ending_animator : Node;

@onready var timer: Timer = $Timer;

func _ready() -> void:
	z_index = 1;
	
	reset_pos = Vector2.ZERO;
	set_exchange(exchange);
	set_process(shake);
	
	$color.scale = Vector2(0.95, 0.95);
	var tween = create_tween().set_loops();
	tween.set_trans(Tween.TRANS_SINE);
	tween.set_ease(Tween.EASE_IN_OUT);
	tween.tween_property($color, "scale", Vector2(1.05, 1.05), 1.5);
	tween.tween_property($color, "scale", Vector2(0.95, 0.95), 1.5);
	
	$color.texture.gradient.colors = $color.texture.gradient.colors.duplicate();
	
	disable = false;

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
			_holding();
		elif event.is_released():
			if staged:
				unstage.emit(self);
				staged = false;
				_let_go();

func _holding() -> void:
	$Absorb.play();
	timer.start();
	shake = true;
	PlayerInfo.cam.auto_follow = false;
	PlayerInfo.cam.zoom_into_event(Vector2(3.0, 3.0), Vector2(1.5, 1.5));
func _let_go() -> void:
	$Absorb.stop();
	$Cancel.play();
	timer.stop();
	shake = false;
	PlayerInfo.cam.auto_follow = true;
	PlayerInfo.cam.zoom_event(Vector2(0.2, 0.2), Vector2(1.0, 1.0));

func collect() -> void:
	disable = true;
	DeathSounds.stop_music();
	
	PlayerInfo.force_idle = true;
	var tw : Tween = create_tween().set_parallel();
	tw.tween_property(self, "global_position", PlayerInfo.player.global_position, 2.0);
	tw.tween_property(self, "scale", Vector2.ZERO, 2.0);
	tw.tween_property(self, "z_index", -1, 0.01).set_delay(1.0);
	tw.tween_callback(TimeManager.instant_time_scale.bind(0.5, 0.3)).set_delay(0.2);
	tw.chain().tween_callback(ending_animator.play_end);
	tw.tween_property(self, "modulate:a", 0.0, 0.4);

func _on_mouse_entered() -> void:
	if disable:
		return;
	if _tween_decorate:
		_tween_decorate.kill();
	
	_tween_decorate = create_tween();
	_tween_decorate.set_trans(Tween.TRANS_SINE).set_parallel();
	_tween_decorate.tween_property(self, "scale", Vector2(2.4, 2.4), 0.2);
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
	_tween_decorate.tween_property(self, "scale", Vector2(2.0, 2.0), 0.2);
	_tween_decorate.tween_property(title_display, "modulate:a", 0.0, 0.2);
	
	if unselected:
		_tween_decorate.tween_property(self, "modulate:a", 0.2, 0.4);
	_selected = false;
	
	if staged:
		unstage.emit(self);
		staged = false;
		_let_go();

func _process(_delta: float) -> void:
	position = reset_pos + Vector2(randf(), randf()) * _shake_ramp;
	_shake_ramp = min(_shake_ramp + 0.05, 5.0);
