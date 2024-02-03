class_name RewardManager extends Node

const ORB_SCENE : PackedScene = preload("res://src/level_objects/orbs/orb.tscn");

@export var orbs : Array[Orb] = [];

@onready var timer: Timer = $Timer;

var _player_orbs : Array[Orb] = [];
var _option_selected : Orb;

var radius : Vector2 = Vector2(40, 20);

var _selected : Orb;
var _tween : Tween;
var _angle : float;

func _ready() -> void:
	for orb : Orb in orbs:
		orb.stage.connect(_stage_orb);
	set_physics_process(false);

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack2"):
		if _selected:
			if _tween:
				_tween.kill();
			
			_selected.disable = false;
			_selected.reset(true, true, true, true);
			_selected = null;
			set_physics_process(false);
			set_process_input(false);
			PlayerInfo.overwrite_player(false);
			
			if _tween:
				_tween.kill();
			_tween = create_tween();
			_tween.set_ease(Tween.EASE_OUT);
			_tween.set_trans(Tween.TRANS_SINE)
			for orb_ : Orb in orbs:
				if orb_ != _selected:
					_tween.parallel().tween_property(orb_, "modulate:a", 1.0, 0.3);
					orb_.unselected = false;
			
			_destroy_options();
			$Cancel.play();

func _stage_orb(orb : Orb) -> void:
	if !$Hover.playing || $Hover.get_playback_position() > 0.8:
		$Hover.pitch_scale = (randf() * 0.2) + 0.4;
		$Hover.play_random();
	
	if _tween:
		_tween.kill();
	_tween = create_tween();
	_tween.set_ease(Tween.EASE_OUT);
	_tween.set_trans(Tween.TRANS_SINE)
	
	if _selected:
		_selected.disable = false;
		_selected.reset(true, true, true, true);
		_tween.parallel().tween_property(orb, "modulate:a", 1.0, 0.3);
		orb.unselected = false;
	else:
		PlayerInfo.overwrite_player(true);
		set_process_input(true);
	set_physics_process(false);
	
	orb.disable = true;
	_selected = orb;
	_selected.reset(false, false, true, true);
	
	for orb_ : Orb in orbs:
		if orb_ != _selected:
			_tween.parallel().tween_property(orb_, "modulate:a", 0.2, 0.3);
			orb_.unselected = true;
	
	_tween.parallel().tween_property(_selected, "scale", Vector2(0.6, 0.6), 0.3);
	_tween.tween_method(_approch_staged_orb.bind(_selected.position), 0.0, 1.0, 0.6);
	_tween.parallel().tween_callback(spawn_options).set_delay(0.3);
	_tween.tween_callback(set_physics_process.bind(true));
	_tween.tween_callback(set_physics_process.bind(true));
	_selected.toggle_flow_particles(false);

func _rotate_origin() -> Vector2:
	return PlayerInfo.player.position + Vector2(0, -20);

func _orbit_staged_orb() -> void:
	_selected.position = _selected.position.lerp(_rotate_origin() + (Vector2(cos(_angle), sin(_angle)) * radius), 0.1);

func _approch_staged_orb(interval : float, start : Vector2) -> void:
	var goto = MathFunctions.trangent_points_on_ellipse(start, _rotate_origin(), radius)[1];
	_angle = _rotate_origin().angle_to(_selected.position);
	_selected.position = _selected.position.lerp(start.lerp(goto, interval), 0.1);

func _physics_process(_delta: float) -> void:
	_orbit_staged_orb();
	_angle += 0.05;
	if _selected.position.y < _rotate_origin().y:
		_selected.z_index = -1;
	else:
		_selected.z_index = 1;

func spawn_options() -> void:
	_destroy_options();
	
	var exchange : Exchangable = _selected.exchange;
	var exchanges : Array[Exchangable];
	if exchange is AttackExchangable:
		exchanges = PlayerInfo.player.get_exchange("attack");
	elif exchange is MovementExchangable:
		exchanges = PlayerInfo.player.get_exchange("movement");
	else:
		exchanges = PlayerInfo.player.get_exchange("health");
	
	var orb : Orb;
	var start : Vector2 = PlayerInfo.player.get_center() + + Vector2(0, -20);
	if exchanges.size() == 1:
		orb = _create_orb(exchanges[0], start, Vector2(0, -80));
		orb.stage.connect(_holding);
		orb.unstage.connect(_let_go);
		orb.stop_cries();
		_player_orbs.append(orb);
	elif exchanges.size() == 2:
		orb = _create_orb(exchanges[0], start, Vector2(-25, -80));
		orb.stage.connect(_holding);
		orb.unstage.connect(_let_go);
		orb.stop_cries();
		_player_orbs.append(orb);
		
		orb = _create_orb(exchanges[1], start, Vector2( 25, -80));
		orb.stage.connect(_holding);
		orb.unstage.connect(_let_go);
		orb.stop_cries();
		_player_orbs.append(orb);

func _destroy_options() -> void:
	for orb : Orb in _player_orbs:
		orb.queue_free();
	_player_orbs.clear();

func _destroy_collectable() -> void:
	var tween : Tween = create_tween().set_parallel();
	for orb : Orb in orbs:
		orb.disable = true;
		orb.disable_click = true;
		tween.tween_property(orb, "modulate:a", 0.0, 0.5);
		tween.tween_property(orb, "scale", Vector2.ZERO, 0.7);
	
	await tween.finished;
	
	for orb : Orb in orbs:
		orb.queue_free();
	orbs.clear();

func _tween_light(interval : float, grad : GradientTexture2D) -> void:
	grad.colors[0].a = interval; 

func _create_orb(exchange : Exchangable, start : Vector2, offset : Vector2) -> Orb:
	var orb : Orb = ORB_SCENE.instantiate();
	orb.exchange = exchange;
	add_child(orb);
	orb.global_position = start;
	orb.scale = Vector2(0.1, 0.1);
	orb.reset_pos = start + offset;
	orb.z_index = -1;
	orb.reset(true, true, true, true);
	
	return orb;

func _holding(orb : Orb) -> void:
	$Absorb.play();
	timer.start();
	_option_selected = orb;
	orb.shake = true;
	PlayerInfo.cam.auto_follow = false;
	PlayerInfo.cam.zoom_into_event(Vector2(3.0, 3.0), Vector2(2.0, 2.0));
func _let_go(orb : Orb) -> void:
	if _option_selected == orb:
		$Absorb.stop();
		$Cancel.play();
		timer.stop();
		orb.shake = false;
		PlayerInfo.cam.auto_follow = true;
		PlayerInfo.cam.zoom_event(Vector2(0.2, 0.2), Vector2(1.0, 1.0));
		
		_option_selected = null;

func _selected_option() -> void:
	$Absorb.stop();
	$Get.play();
	set_process_input(false);
	_option_selected.shake = false;
	
	var idx : int = _player_orbs.find(_option_selected);
	_player_orbs.erase(_option_selected);
	_option_selected.destroy();
	
	for orb : Orb in _player_orbs:
		orb.disable = true;
		orb.disable_click = true;
	for orb : Orb in orbs:
		orb.disable = true;
		orb.disable_click = true;
	
	await _option_selected.destroyed;
	
	var tt : Tween = create_tween();
	tt.tween_property(_option_selected, "scale", Vector2(0,0), 5.0);
	
	await get_tree().create_timer(0.2).timeout;
	
	_selected.fade_cries(0.4);
	var tween : Tween = create_tween();
	set_physics_process(false);
	tween.tween_property(_selected, "scale", Vector2(0,0), 0.4);
	tween.parallel().tween_property(_selected, "global_position", PlayerInfo.player.get_center(), 0.2).set_delay(0.2);
	
	for orb in _player_orbs:
		orb.z_index = -1;
		tween.tween_property(orb, "scale", Vector2(0,0), 0.4);
		tween.parallel().tween_property(orb, "global_position", PlayerInfo.player.get_center(), 0.2).set_delay(0.2);
	
	PlayerInfo.replace(idx, _selected.exchange);
	
	await tween.finished;
	_destroy_options();
	_destroy_collectable();
	
	_selected = null;
	_option_selected = null;
	
	PlayerInfo.overwrite_player(false);
	PlayerInfo.cam.auto_follow = true;
	PlayerInfo.cam.zoom_event(Vector2(0.2, 0.2), Vector2(1.0, 1.0));

func _spawn_orbs(character : ExchangeType) -> void:
	var exs : Array[Exchangable] = character.get_skills();
	
	var angle : float = randf() * TAU;
	var inc : float = TAU / exs.size();
	var dist : float = (exs.size() - 1) * 20;
	
	for ex in exs:
		var orb : Orb = _create_orb(ex, character.get_center(), Vector2(cos(angle), sin(angle)) * dist + Vector2(0, -80));
		orbs.append(orb);
		orb.stage.connect(_stage_orb);
		angle += inc;
