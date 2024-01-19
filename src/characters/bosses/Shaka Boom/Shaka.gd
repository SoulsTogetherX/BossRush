extends Boss

const CROSS_HAIR_TEXTURE : CompressedTexture2D = preload("res://assets/sprites/characters/bosses/shaka boom/cross_hairs.png");
const FIRE_CIRCLE : PackedScene = preload("res://src/characters/bosses/Shaka Boom/fire_circle/fire_circle.tscn");

const STANDARD_COMFORT_SOZE : float = 70;
var comfort : float = STANDARD_COMFORT_SOZE;

@export var tertiary_attack : AttackExchangable;
@export var quaternary_attack : AttackExchangable;
@export var fifth_attack : AttackExchangable;
@export var six_attack : AttackExchangable;

@export var slime_summon_area : CollisionShape2D;
@export var fly_nodes : Node;
@export var center_node : Sprite2D;
@export var arrow : Node2D;	
@export var door_hide : Node;
@export var door : Node;

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

enum FLOAT_PICK {OUTER, INNER, RANDOM, AWAY, TOWARDS};

var _current_node : Sprite2D;
var _waiting : bool = true;
var _float_tween : Tween;
var _cross_hairs : Array[Sprite2D];
var _fire_circle : Area2D;
var _turn : int = 0;

var _slime_count : int = 0;
var _fitst_scared : bool = true;
var _summoned_slimes : int;

var add_arrow : bool = false;

func _ready() -> void:
	_current_node = center_node;
	super();
	
	$float_timer.timeout.connect(create_after_image.bind(Color(0.5, 0.5, 1.0, 1.0), 0.3));
	
	if PlayerInfo.hard_mode == PlayerInfo.DIFFICULTY.EASY:
		$slime_timer.wait_time = 0.5;
		_add_to_sequence(summon_slimes_start_hard, INF);
		_add_to_sequence(summon_slimes_end, 0.25);
		_add_to_sequence(pick_float, 2.4);
		_add_to_sequence(idle, 0.5);
		_add_to_sequence(forward_atttack_start, 0.9);
		_add_to_sequence(forward_atttack_end, 0.01);
		_add_to_sequence(idle, 0.5);
		_add_to_sequence(pick_float, 2.4);
		_add_to_sequence(idle, 0.5);
		_add_to_sequence(forward_atttack_start, 0.9);
		_add_to_sequence(forward_atttack_end, 0.01);
		_add_to_sequence(pick_float.bind(FLOAT_PICK.INNER), 2.4);
		_add_to_sequence(idle, 2.2);
	
	var tw = create_tween().set_loops();
	tw.tween_property(_sprite.material, "shader_parameter/width", 1.0, 0.8);
	tw.tween_property(_sprite.material, "shader_parameter/width", 4.0, 0.8);
	
	primary_attack.summoned.connect(register_slime);
	up_shield();

func _normal_mode_stage_1() -> void:
	_slime_count = 4 + _health_monitor.health_missing() * 3;
	$slime_timer.wait_time = 0.25;
	_clear_sequence();
	_add_to_sequence(summon_slimes_start_hard, INF);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.RANDOM, 0.5), 2.4 * 0.5);
	
	_add_to_sequence(idle, 1.0);
	
	_add_to_sequence(forward_atttack_start, 0.7);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.5), 2.4 * 0.5);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.AWAY, 0.5), 2.4 * 0.5);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(idle, 1.0);
	
	_add_to_sequence(forward_atttack_start, 0.7);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.5), 2.4 * 0.5);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.AWAY, 0.5), 2.4 * 0.5);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(pick_float.bind(FLOAT_PICK.INNER, 0.25), 2.4 * 0.25);
	_add_to_sequence(idle, 1.0);
	_add_to_sequence(fourway_atttack_start, 4.0);
	_add_to_sequence(fourway_atttack_end, 0.01);
	
	_add_to_sequence(forward_atttack_start, 0.01);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.5), 2.4 * 0.5);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(idle, 1.0);

func _normal_mode_stage_2() -> void:
	_slime_count = _health_monitor.health_missing() * 3;
	$slime_timer.wait_time = 2;
	
	

func _hard_mode_stage_1() -> void:
	comfort = STANDARD_COMFORT_SOZE;
	_slime_count = 10 + _health_monitor.health_missing() * 3;
	$slime_timer.wait_time = 0.05;
	_clear_sequence();
	_add_to_sequence(summon_slimes_start_hard, INF);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.RANDOM, 0.5), 2.4 * 0.5);
	_add_to_sequence(idle, 1.0);
	_add_to_sequence(forward_atttack_start, 0.7);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(pick_float.bind(FLOAT_PICK.RANDOM, 0.25), 2.4 * 0.25);
	_add_to_sequence(forward_atttack_start, 0.7);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(pick_float.bind(FLOAT_PICK.RANDOM, 0.25), 2.4 * 0.25);
	_add_to_sequence(forward_atttack_start, 0.7);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(pick_float.bind(FLOAT_PICK.RANDOM, 0.25), 2.4 * 0.25);
	_add_to_sequence(forward_atttack_start, 0.7);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(pick_float.bind(FLOAT_PICK.INNER, 0.25), 2.4 * 0.25);
	_add_to_sequence(idle, 0.5);
	_add_to_sequence(fourway_atttack_start, 7.8);
	_add_to_sequence(fourway_atttack_end, 0.01);
	
	_add_to_sequence(idle, 1.0);

func _hard_mode_stage_2() -> void:
	comfort = STANDARD_COMFORT_SOZE;
	_slime_count = 10 + _health_monitor.health_missing() * 3;
	$slime_timer.wait_time = 0.05;
	_clear_sequence();
	_add_to_sequence(summon_slimes_start_hard, INF);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.5), 2.4 * 0.5);
	_add_to_sequence(idle, 1.0);
	
	_add_to_sequence(forward_atttack_start.bind(true), 0.5);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.5), 2.4 * 0.5);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.5), 2.4 * 0.5);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.5), 2.4 * 0.5);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.5), 2.4 * 0.5);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(idle, 2.0);
	
	_add_to_sequence(forward_atttack_start.bind(true), 0.5);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.5), 2.4 * 0.5);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.5), 2.4 * 0.5);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.5), 2.4 * 0.5);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.5), 2.4 * 0.5);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(pick_float.bind(FLOAT_PICK.INNER, 0.25), 2.4 * 0.25);
	_add_to_sequence(idle, 0.5);
	_add_to_sequence(fourway_atttack_start, 4.0);
	_add_to_sequence(fourway_atttack_end, 0.01);
	
	_add_to_sequence(pick_float.bind(FLOAT_PICK.RANDOM, 0.25), 2.4 * 0.25);
	_add_to_sequence(forward_atttack_start, 0.7);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(pick_float.bind(FLOAT_PICK.RANDOM, 0.25), 2.4 * 0.25);
	_add_to_sequence(forward_atttack_start, 0.7);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(idle, 1.0);

func _hard_mode_stage_3() -> void:
	comfort = 110;
	_slime_count = 8 + _health_monitor.health_missing() * 2;
	$slime_timer.wait_time = 1.2;
	_clear_sequence();
	_add_to_sequence(idle, 1.0);
	_add_to_sequence(sides_ban, 0.01);
	
	_add_to_sequence(fire_surround, 1.4);
	_add_to_sequence(pick_float.bind(FLOAT_PICK.AWAY, 0.25), 2.4 * 0.25);
	_add_to_sequence(summon_slimes_start_hard, INF);
	_add_to_sequence(idle, 0.5);
	_add_to_sequence(end_fire_surround, 0.01);
	
	_add_to_sequence(forward_atttack_start, 0.7);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.25), 2.4 * 0.25);
	_add_to_sequence(forward_atttack_start, 0.7);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.25), 2.4 * 0.25);
	_add_to_sequence(forward_atttack_start, 0.7);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(pick_float.bind(FLOAT_PICK.TOWARDS, 0.25), 2.4 * 0.25);
	_add_to_sequence(forward_atttack_start, 0.7);
	_add_to_sequence(forward_atttack_end, 0.01);
	
	_add_to_sequence(pick_float.bind(FLOAT_PICK.INNER, 0.25), 2.4 * 0.25);
	_add_to_sequence(idle, 0.5);
	_add_to_sequence(fourway_atttack_start, 4.0);
	_add_to_sequence(fourway_atttack_end, 0.01);

var _death : bool = false;
func die() -> void:
	off_scene_shoot_end();
	_death = true;
	$slime_timer.stop();
	if !$attack_timer.is_stopped():
		forward_atttack_end();
	$scared_timer.stop();
	$float_timer.stop();
	
	_play_hurt();
	_animation_player.queue("dead");
	
	await get_tree().create_timer(1.33 + 0.6).timeout;
	
	door_hide.visible = true;
	door.open_doors();
	
	primary_attack.reset();
	secondary_attack.reset();
	tertiary_attack.reset();
	_reward_manager._spawn_orbs(self);

func _on_hit(_hitbox: HitBox) -> void:
	if _waiting:
		_waiting = false;
		door_hide.visible = false;
		door.close_doors();
		if PlayerInfo.hard_mode == PlayerInfo.DIFFICULTY.BARKMODE:
			$HealthMonitor.update_health_no_signal($HealthMonitor.max_health);
			off_scene_shoot_start();
		else:
			add_arrow = true;
	elif add_arrow:
		hide_arrow();
		add_arrow = false;
	
	$hurt.play_random();
	$Confetti_hit.global_rotation = (get_center() - PlayerInfo.player.global_position).angle();
	$Confetti_hit_opp.global_rotation = $Confetti_hit.global_rotation + PI;
	
	$scared_timer.stop();
	$sequence_timer.stop();
	_stun();
	up_shield();
	if PlayerInfo.hard_mode == PlayerInfo.DIFFICULTY.BARKMODE:
		match _turn % 3:
			0:
				_hard_mode_stage_1();
			1:
				_hard_mode_stage_2();
			2:
				_hard_mode_stage_3();
		_turn += 1;
	elif PlayerInfo.hard_mode == PlayerInfo.DIFFICULTY.NORMAL:
		if (_turn & 1) == 0:
			_normal_mode_stage_1();
		else:
			_normal_mode_stage_2();
		_turn += 1;
	else:
		_slime_count += 3;

func _stun() -> void:
	if !_death:
		_play_hurt();
		get_tree().create_timer(0.5).timeout.connect(mad_hit_start, CONNECT_ONE_SHOT);

func _play_hurt() -> void:
	TimeManager.instant_time_scale();
	PlayerInfo.cam.shake_event();
	if (randf() < 0.5):
		_animation_player.play("hurt_left");
	else:
		_animation_player.play("hurt_right");
	$hurt_background.play();

func idle() -> void:
	if _animation_player.current_animation != "idle":
		_animation_player.play("idle");

func pick_float(pick : FLOAT_PICK = FLOAT_PICK.OUTER, speed_up : float = 1.0) -> void:
	match pick:
		FLOAT_PICK.INNER:
			if _current_node == center_node:
				return;
			_current_node = center_node;
		FLOAT_PICK.OUTER:
			var nodes : Array = fly_nodes.get_children();
			nodes.erase(_current_node);
			_current_node = nodes.pick_random();
		FLOAT_PICK.RANDOM:
			var nodes : Array = fly_nodes.get_children();
			nodes.append(center_node);
			nodes.erase(_current_node);
			
			_current_node = nodes.pick_random();
		FLOAT_PICK.AWAY:
			var nodes : Array = fly_nodes.get_children();
			nodes.erase(_current_node);
			var new_node : Sprite2D;
			var distance : float = -INF;
			for node in nodes:
				var dist : float = node.global_position.distance_squared_to(PlayerInfo.player.global_position);
				if dist > distance:
					new_node = node;
					distance = dist
			
			_current_node = new_node;
		FLOAT_PICK.TOWARDS:
			var nodes : Array = fly_nodes.get_children();
			nodes.append(center_node);
			nodes.erase(_current_node);
			var new_node : Sprite2D;
			var distance : float = INF;
			for node in nodes:
				var dist : float = node.global_position.distance_squared_to(PlayerInfo.player.global_position);
				if dist < distance:
					new_node = node;
					distance = dist
			
			_current_node = new_node;
		
	_float_over(_current_node.global_position, speed_up);

var float_height : float = 10;
func _float_over(pos : Vector2, speed_up : float = 1.0) -> void:
	$float_timer.start();
	
	pos += Vector2(0, 71);
	
	_animation_player.play("float_start");
	if _float_tween:
		_float_tween.finished.emit();
		_float_tween.kill();
	
	_float_tween = create_tween();
	_float_tween.tween_property(self, "global_position", global_position + (Vector2.UP * float_height), 0.5 * speed_up);
	_float_tween.tween_property(self, "global_position", pos + (Vector2.UP * float_height), 1.0 * speed_up).set_delay(0.2 * speed_up);
	_float_tween.tween_property(self, "global_position", pos, 0.5 * speed_up).set_delay(0.2 * speed_up);
	_float_tween.tween_callback(_play_float_end);
	_float_tween.tween_callback($float_timer.stop);
	_float_tween.tween_property($land_particles, "emitting", true, 0.001).set_delay(0.2 * speed_up);
	
	const up : Vector2 = Vector2(0, -28);
	const down : Vector2 = Vector2(0, -36);
	const stand : Vector2 = Vector2(0, -32);
	
	var sprite : Sprite2D = _sprite;
	var tween = create_tween();
	tween.tween_property(sprite, "position", up, 0.2 * speed_up).set_delay(0.7 * speed_up);
	tween.tween_property(sprite, "position", down, 0.2 * speed_up);
	tween.tween_property(sprite, "position", up, 0.2 * speed_up);
	tween.tween_property(sprite, "position", down, 0.2 * speed_up);
	tween.tween_property(sprite, "position", up, 0.2 * speed_up);
	tween.tween_property(sprite, "position", down, 0.2 * speed_up);
	tween.tween_property(sprite, "position", stand, 0.5 * speed_up);

func _play_float_end() -> void:
	_animation_player.play("float_end");
	if !$scared_timer.is_stopped():
		_animation_player.queue("scared_start");
	else:
		_animation_player.queue("idle");

func forward_atttack_start(angle : bool = false) -> void:
	if !$scared_timer.is_stopped():
		return;
	$attack_timer.wait_time = 0.05;
	
	if angle:
		var cross_hairs : int = 4;
		var angle_offset : float = TAU / cross_hairs;
		for i in cross_hairs:
			spawn_crosshair(Vector2.RIGHT.rotated(i * angle_offset) * 0.1, true);
	else:
		spawn_crosshair();
		
	get_tree().create_timer(0.3).timeout.connect($attack_timer.start, CONNECT_ONE_SHOT);
	if !$attack_timer.timeout.is_connected(forward_atttack):
		$attack_timer.timeout.connect(forward_atttack);
func forward_atttack() -> void:
	tertiary_attack.force_handle_attack(self, get_center(), PlayerInfo.player.global_position, get_alignment());
	if $scared_timer.is_stopped():
		$attack_timer.start();
	else:
		forward_atttack_end();
func forward_atttack_end() -> void:
	if $attack_timer.timeout.is_connected(forward_atttack):
		$attack_timer.timeout.disconnect(forward_atttack);
	clear_crosshairs();
	$attack_timer.stop();

func fourway_atttack_start() -> void:
	if !$scared_timer.is_stopped():
		return;
	$attack_timer.wait_time = 0.3;
	if !$attack_timer.timeout.is_connected(fourway_atttack):
		$attack_timer.timeout.connect(fourway_atttack);
	$attack_timer.start();
func fourway_atttack() -> void:
	quaternary_attack.force_handle_attack(self, get_center(), PlayerInfo.player.global_position, get_alignment());
	if $scared_timer.is_stopped():
		$attack_timer.start();
	else:
		fourway_atttack_end();
func fourway_atttack_end() -> void:
	if $attack_timer.timeout.is_connected(fourway_atttack):
		$attack_timer.timeout.disconnect(fourway_atttack);
	$attack_timer.stop();

func off_scene_shoot_start() -> void:
	$off_scene_shoot.start();
var _shoot_side : Side;
func off_scene_shoot() -> void:
	_shoot_side = (randi() % 4) as Side;
	match _shoot_side:
		SIDE_LEFT:
			var launch_pos : Vector2 =  Vector2(-540, ((randf() * 480) - 240));
			fifth_attack.force_handle_attack(self, launch_pos, launch_pos + Vector2.RIGHT, get_alignment());
		SIDE_TOP:
			var launch_pos : Vector2 =  Vector2(((randf() * 630) - 315), -450);
			fifth_attack.force_handle_attack(self, launch_pos, launch_pos + Vector2.DOWN, get_alignment());
		SIDE_RIGHT:
			var launch_pos : Vector2 =  Vector2(540, ((randf() * 480) - 240));
			fifth_attack.force_handle_attack(self, launch_pos, launch_pos + Vector2.LEFT, get_alignment());
		SIDE_BOTTOM:
			var launch_pos : Vector2 =  Vector2(((randf() * 630) - 315), 470);
			fifth_attack.force_handle_attack(self, launch_pos, launch_pos + Vector2.UP, get_alignment());
func off_scene_shoot_end() -> void:
	$off_scene_shoot.stop();

func sides_ban() -> void:
	var pos : float = -330;
	for i in 33:
		var launch_pos : Vector2 =  Vector2(pos, -430);
		six_attack.force_handle_attack(self, launch_pos, launch_pos + Vector2.DOWN, get_alignment());
		
		launch_pos =  Vector2(pos, 430);
		six_attack.force_handle_attack(self, launch_pos, launch_pos + Vector2.UP, get_alignment());
		
		pos += 20;
	
	pos = -220;
	for i in 25:
		var launch_pos : Vector2 =  Vector2(-500, pos);
		six_attack.force_handle_attack(self, launch_pos, launch_pos + Vector2.RIGHT, get_alignment());
		
		launch_pos = Vector2(500, pos);
		six_attack.force_handle_attack(self, launch_pos, launch_pos + Vector2.LEFT, get_alignment());
		
		pos += 20;

func spawn_crosshair(offset : Vector2 = Vector2.ZERO, angle : bool = false) -> void:
	var cross_hair = Sprite2D.new();
	cross_hair.texture = CROSS_HAIR_TEXTURE;
	cross_hair.modulate = Color(1.0, 1.0, 1.0, 0.5);
	PlayerInfo.player.add_child(cross_hair);
	
	if angle:
		cross_hair.position = offset.normalized() * 1000;
	else:
		cross_hair.position = (PlayerInfo.player.get_center() + offset - global_position).normalized() * 1000;
	var tw : Tween = cross_hair.create_tween().set_parallel();
	tw.tween_property(cross_hair, "modulate", Color.WHITE, 0.7);
	tw.tween_property(cross_hair, "rotation_degrees", -360, 1.4);
	tw.set_trans(Tween.TRANS_ELASTIC);
	tw.set_ease(Tween.EASE_OUT);
	tw.tween_property(cross_hair, "position", PlayerInfo.player.get_center_local() + offset, 0.5);
	
	_cross_hairs.append(cross_hair);

func clear_crosshairs() -> void:
	for cross in _cross_hairs:
		cross.queue_free();
	_cross_hairs.clear();

func remove_crosshair(cross_hair : Sprite2D) -> void:
	_cross_hairs.erase(cross_hair);
	cross_hair.queue_free();

func summon_slimes_start() -> void:
	up_shield();
	_summoned_slimes = 0;
	$slime_timer.start();
	_animation_player.play("summoning_start");
func summon_slimes() -> void:
	primary_attack.handle_attack(self, get_center(), PlayerInfo.player.global_position, get_alignment());
func summon_slimes_end() -> void:
	$slime_timer.stop();
	_animation_player.play("summoning_end");
	
func get_spawn_pos() -> Array[Vector2]:
	var shape : Rect2 = slime_summon_area.shape.get_rect();
	var pos : Vector2;
	while true:
		pos = Vector2(shape.size.x * randf(), shape.size.y * randf()) + shape.position;
		if can_slime_here(pos):
			break;
	
	return [pos];
func can_slime_here(pos : Vector2) -> bool:
	if pos.distance_squared_to(PlayerInfo.player.global_position) < comfort * comfort:
		return false;
	if pos.distance_squared_to(global_position) < 50 * 50:
		return false;
	
	var pp = PhysicsPointQueryParameters2D.new();
	pp.position = pos;
	pp.collision_mask = 256;
	return get_world_2d().direct_space_state.intersect_point(pp, 1).is_empty();

var _slime_summoned : Array[ExchangeType] = [];
func register_slime(slime : ExchangeType) -> void:
	_slime_summoned.append(slime);
	slime.killed.connect(slime_killed.bind(slime));
	_summoned_slimes += 1;
	if _summoned_slimes >= _slime_count && !_fitst_scared:
		_sequence_timer.stop();
		$slime_timer.stop();
		get_tree().create_timer($slime_timer.wait_time).timeout.connect(_next_sequence, CONNECT_ONE_SHOT);
func slime_killed(slime : ExchangeType) -> void:
	_slime_summoned.erase(slime);
	if _slime_summoned.size() == 0 && $slime_timer.is_stopped():
		if !_waiting:
			await after_swap;
		if !$float_timer.is_stopped() || !$attack_timer.is_stopped():
			_sequence_timer.timeout.connect(scared_start, CONNECT_ONE_SHOT);
		else:
			scared_start();
func summon_slimes_start_hard() -> void:
	if _slime_summoned.size() < _slime_count * 0.75:
		summon_slimes_start();
	else:
		_next_sequence(1);
func summon_slimes_start_check() -> void:
	if _slime_summoned.size() < 5:
		summon_slimes_start();
	else:
		_next_sequence(1);
func get_minons() -> Array[ExchangeType]:
	return _slime_summoned.duplicate();

func scared_start() -> void:
	if !$float_timer.is_stopped():
		await after_swap;
	
	_reset_all();
	$sequence_timer.stop();
	
	if _fitst_scared:
		$scared_timer.wait_time = INF;
		_fitst_scared = false;
	else:
		$scared_timer.wait_time = 3.0 - (1.0 * float(PlayerInfo.hard_mode != PlayerInfo.DIFFICULTY.EASY));
	
	if add_arrow:
		summon_arrow();
	
	$scared_timer.start();
	lower_shield();
	_animation_player.play("scared_start");
	_animation_player.queue("scared");
func end_scared() -> void:
	_reset_all();
	_reset_sequence();
	up_shield();
	if add_arrow:
		hide_arrow();
	elif PlayerInfo.hard_mode != PlayerInfo.DIFFICULTY.BARKMODE:
		add_arrow = true;

func mad_hit_start() -> void:
	_animation_player.play("angry");
	
	if PlayerInfo.hard_mode == PlayerInfo.DIFFICULTY.BARKMODE:
		forward_atttack_start();
	
	await get_tree().create_timer(1.6).timeout;
	PlayerInfo.cam.shake_event(Vector3(0.7, 0.7, 0), Vector3(10., 10., 0), Vector3(0.9, 0.9, 0));
	
	var launch : LinearLaunch = secondary_attack.launch;
	var add : float = 80.0 * float(PlayerInfo.hard_mode == PlayerInfo.DIFFICULTY.BARKMODE);
	if _current_node == center_node:
		launch.fire_range = 300 + add;
		launch.speed = 200 + add;
	else:
		launch.fire_range = 600 + add;
		launch.speed = 350 + add;
	secondary_attack.handle_attack(self, get_center(), PlayerInfo.player.global_position, get_alignment());
	
	await get_tree().create_timer(0.2).timeout;
	burn_ground();
	get_tree().create_timer(1.8).timeout.connect(mad_hit_end, CONNECT_ONE_SHOT);
func mad_hit_end() -> void:
	_reset_all();
	_reset_sequence();

func fire_surround() -> void:
	var cross_hairs : int = 10;
	var angle_offset : float = TAU / cross_hairs;
	for i in cross_hairs:
		spawn_crosshair(Vector2.RIGHT.rotated(i * angle_offset) * 80, true);
	get_tree().create_timer(1.4).timeout.connect(start_fire_surround);
func start_fire_surround() -> void:
	clear_crosshairs();
	_fire_circle = FIRE_CIRCLE.instantiate();
	get_tree().current_scene.add_child(_fire_circle);
	_fire_circle.global_position = PlayerInfo.player.global_position;
func end_fire_surround() -> void:
	if is_instance_valid(_fire_circle):
		_fire_circle.releash();
	_fire_circle = null;

func burn_ground() -> void:
	_current_node.visible = true;
	_current_node.rotation = TAU * randf();

func lower_shield() -> void:
	_sprite.material.set_shader_parameter("color", Color("#60ffff00"));
	super();
func up_shield() -> void:
	var tw : Tween = create_tween();
	tw.tween_property(_sprite.material, "shader_parameter/color", Color("#60ffff5a"), 0.2);
	super();

func summon_arrow() -> void:
	arrow.toggle_arrow(true);
	var tw : Tween = arrow.create_tween();
	tw.tween_property(arrow, "modulate:a", 1.0, 0.5);

func hide_arrow() -> void:
	arrow.toggle_arrow(false);
	var tw : Tween = arrow.create_tween();
	tw.tween_property(arrow, "modulate:a", 0.0, 0.5);

func _reset_all() -> void:
	$slime_timer.stop();
	if !$attack_timer.is_stopped():
		forward_atttack_end();
		fourway_atttack_end();
	$scared_timer.stop();
	$float_timer.stop();
	if _fire_circle:
		end_fire_surround();

func get_skills() -> Array[Exchangable]:
	return [health_handle, preload("res://assets/resources/instances/exchangable/Shaka/Fireforward_reward.tres"), preload("res://assets/resources/instances/exchangable/Shaka/FireWave_reward.tres"), preload("res://assets/resources/instances/exchangable/Shaka/SlimeSpawn_reward.tres")]
