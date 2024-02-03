@tool
extends Boss

const HOLY_PROJECTILE_SCENE : PackedScene = preload("res://src/weapons/projectiles/The_End/Holy_Projectile.tscn");

@export var left_float : FloatObjectControl;
@export var right_float : FloatObjectControl;

@export var left_hand : Hand_TheEndBoss;
@export var right_hand : Hand_TheEndBoss;

var _slam_hand : Hand_TheEndBoss;
var _lazor_hand : Hand_TheEndBoss;

var _display_arrow : bool = true;
var _turn : int = 0;

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(false);
		return;
	super();
	
	var tw = create_tween().set_parallel().set_loops();
	tw.tween_property($Body.material, "shader_parameter/width", 4.0, 0.8);
	tw.tween_property(left_float.material, "shader_parameter/width", 4.0, 0.8);
	tw.tween_property(right_float.material, "shader_parameter/width", 4.0, 0.8);
	tw.tween_property(left_float.get_hallo().material, "shader_parameter/width", 4.0, 0.8);
	tw.tween_property(right_float.get_hallo().material, "shader_parameter/width", 4.0, 0.8);
	tw.tween_property(left_hand.material, "shader_parameter/width", 4.0, 0.8);
	tw.tween_property(right_hand.material, "shader_parameter/width", 4.0, 0.8);
	
	tw.chain().tween_property($Body.material, "shader_parameter/width", 1.0, 0.8);
	tw.tween_property(left_float.material, "shader_parameter/width", 1.0, 0.8);
	tw.tween_property(right_float.material, "shader_parameter/width", 1.0, 0.8);
	tw.tween_property(left_float.get_hallo().material, "shader_parameter/width", 1.0, 0.8);
	tw.tween_property(right_float.get_hallo().material, "shader_parameter/width", 1.0, 0.8);
	tw.tween_property(left_hand.material, "shader_parameter/width", 1.0, 0.8);
	tw.tween_property(right_hand.material, "shader_parameter/width", 1.0, 0.8);
	
	left_hand.set_boxes(_health_monitor, alignment).connect(_on_hit.bind(left_hand));
	right_hand.set_boxes(_health_monitor, alignment).connect(_on_hit.bind(right_hand));
	
	match PlayerInfo.hard_mode:
		PlayerInfo.DIFFICULTY.EASY:
			_add_to_sequence(pick_hand, 0.01);
			_add_to_sequence(start_slams.bind(0.7), 1.5);
			_add_to_sequence(start_slams.bind(0.7), 1.5);
			_add_to_sequence(start_slams.bind(0.7), 1.5);
			_add_to_sequence(start_slams.bind(0.7), 1.5);
			_add_to_sequence(start_slams.bind(0.7), 1.5);
			_add_to_sequence(start_slams.bind(0.7), 1.5);
			_add_to_sequence(idle_slam_hand, 0.01);
			_add_to_sequence(aim_lazor.bind(true, 2.7, 0.7, false), 2.0);
			_add_to_sequence(fire_lazor, 0.7);
			_add_to_sequence(clear_lazor, 0.2);
			_add_to_sequence(vunerable_eye, 1.5);
			_add_to_sequence(shield_eye, 0.01);
		PlayerInfo.DIFFICULTY.NORMAL:
			_phase_1_normal();
		PlayerInfo.DIFFICULTY.BARKMODE:
			_phase_1_hard();
	
	if PlayerInfo.flag == false:
		await get_tree().create_timer(6.0).timeout;
		PlayerInfo.flag = true;
	
	$AnimationPlayer.play("start");
	$AnimationPlayer.animation_finished.connect(_battle_start, CONNECT_ONE_SHOT);
	up_shield();

func _battle_start(_anim_name: StringName) -> void:
	DeathSounds.play_music(2);

func _phase_1_normal() -> void:
	_clear_sequence();
	_add_to_sequence(pick_hand, 0.01);
	
	_add_to_sequence(start_slams.bind(0.7), 1.2);
	_add_to_sequence(aim_lazor.bind(false, 2.7, 0.7, true), 0.001);
	_add_to_sequence(start_slams.bind(0.7), 1.2);
	_add_to_sequence(fire_lazor, 0.7);
	_add_to_sequence(start_slams.bind(0.7), 1.2);
	_add_to_sequence(clear_lazor, 0.001);
	
	_add_to_sequence(start_slams.bind(0.7), 1.2);
	_add_to_sequence(aim_lazor.bind(false, 2.7, 0.7, true), 0.001);
	_add_to_sequence(start_slams.bind(0.7), 1.2);
	_add_to_sequence(fire_lazor, 0.7);
	_add_to_sequence(start_slams.bind(0.7), 1.2);
	_add_to_sequence(clear_lazor, 0.001);
	
	_add_to_sequence(start_slams.bind(0.7), 1.2);
	_add_to_sequence(aim_lazor.bind(false, 2.7, 0.7), 0.001);
	_add_to_sequence(start_slams.bind(0.7), 1.2);
	_add_to_sequence(fire_lazor, 0.7);
	_add_to_sequence(start_slams.bind(0.7), 1.2);
	_add_to_sequence(clear_lazor, 0.001);
	
	_add_to_sequence(start_slams.bind(INF), 0.3);
	
	_add_to_sequence(idle_slam_hand, 0.01);
	_add_to_sequence(clear_lazor, 0.2);
	_add_to_sequence(vunerable_eye, 1.5);
	_add_to_sequence(shield_eye, 0.01);

func _phase_2_normal() -> void:
	_clear_sequence();
	_add_to_sequence(punch_fest_start, 8.0);
	
	_add_to_sequence(pick_hand, 0.001);
	_add_to_sequence(punch_fest_end.bind(true), 1.0);
	_add_to_sequence(aim_lazor.bind(true, 2.7, 0.7, false), 1.5);
	_add_to_sequence(punch_fest_end.bind(false), 0.001);
	_add_to_sequence(fire_lazor, 0.7);
	_add_to_sequence(clear_lazor, 0.2);
	
	_add_to_sequence(vunerable_eye, 1.5);
	_add_to_sequence(shield_eye, 0.01);

func _phase_1_hard() -> void:
	_clear_sequence();
	_add_to_sequence(pick_hand, 0.01);
	
	_add_to_sequence(start_slams.bind(0.7), 0.2);
	_add_to_sequence(aim_lazor.bind(false, 2.7, 0.7), 1.0);
	_add_to_sequence(start_slams.bind(0.7), 0.001);
	_add_to_sequence(fire_lazor, 0.7);
	_add_to_sequence(clear_lazor, 0.001);
	
	_add_to_sequence(start_slams.bind(0.7), 0.5);
	_add_to_sequence(aim_lazor.bind(false, 2.7, 0.7), 0.7);
	_add_to_sequence(start_slams.bind(0.7), 0.001);
	_add_to_sequence(fire_lazor, 0.7);
	_add_to_sequence(clear_lazor, 0.001);
	
	_add_to_sequence(start_slams.bind(0.7), 0.5);
	_add_to_sequence(aim_lazor.bind(false, 2.7, 0.7), 0.7);
	_add_to_sequence(start_slams.bind(0.7), 0.001);
	_add_to_sequence(fire_lazor, 0.7);
	_add_to_sequence(clear_lazor, 0.001);
	
	_add_to_sequence(idle_slam_hand, 0.01);
	_add_to_sequence(clear_lazor, 0.2);
	_add_to_sequence(vunerable_eye, 1.5);
	_add_to_sequence(shield_eye, 0.01);

func _releash_the_bees() -> void:
	get_parent().disable = true;
	left_float.change_move_type(FloatObjectControl.STATE.STATIONARY);
	right_float.change_move_type(FloatObjectControl.STATE.STATIONARY);
	left_hand.change_move_type(FloatObjectControl.STATE.STATIONARY);
	right_hand.change_move_type(FloatObjectControl.STATE.STATIONARY);
	
	var tw : Tween = create_tween().set_parallel();
	tw.tween_property(left_float, "rest_offset:x", -320, 0.3).set_delay(0.1);
	tw.tween_property(right_float, "rest_offset:x", 320, 0.3).set_delay(0.1);
	
	tw.tween_property(left_hand, "rest_offset:y", -150, 0.2);
	tw.tween_property(right_hand, "rest_offset:y", -150, 0.2);
	
	tw.tween_callback(create_projectile.bind(left_float)).set_delay(0.15);
	tw.tween_callback(create_projectile.bind(right_float)).set_delay(0.15);
	
	tw.tween_callback(create_projectile.bind(left_float)).set_delay(0.25);
	tw.tween_callback(create_projectile.bind(right_float)).set_delay(0.25);
	
	tw.tween_callback(create_projectile.bind(left_float)).set_delay(0.35);
	tw.tween_callback(create_projectile.bind(right_float)).set_delay(0.35);
	
	tw.tween_interval(2.5);
	
	tw.chain().tween_property(left_float, "rest_offset:x", -110, 0.1);
	tw.tween_property(right_float, "rest_offset:x", 110, 0.1);
	
	tw.tween_property(left_hand, "rest_offset:y", 0, 0.1);
	tw.tween_property(right_hand, "rest_offset:y", 0, 0.1);
	
	await tw.finished;
	
	get_parent().disable = false;
	left_float.change_move_type(FloatObjectControl.STATE.IDLE);
	right_float.change_move_type(FloatObjectControl.STATE.IDLE);
	left_hand.change_move_type(FloatObjectControl.STATE.IDLE);
	right_hand.change_move_type(FloatObjectControl.STATE.IDLE);

func create_projectile(follow : Node2D) -> void:
	var proj : HomingProjectile = HOLY_PROJECTILE_SCENE.instantiate();
	get_tree().current_scene.add_child(proj);
	proj.global_position = follow.global_position;
	proj.target = PlayerInfo.player;
	proj.set_alignment(HurtBox.ALIGNMENT.ENEMY);
	proj.set_delta(-1);
	
	var tw := proj.create_tween();
	tw.set_ease(Tween.EASE_IN);
	tw.set_trans(Tween.TRANS_CUBIC);
	tw.tween_property(proj, "rotation_inc", 2880, 1.0);
	tw.tween_interval(1.0);
	await tw.finished;
	
	proj.activate();
	proj.set_velocity(proj.global_position.angle_to_point(PlayerInfo.player.get_center()), 1000 + (randf() * 200));
	proj.start_homing(5.0, 7.0);

var max_punch_safegaurd : int = 0;
func punch_fest_start() -> void:
	max_punch_safegaurd = 0;
	left_hand.finished_action.connect(punch_fest.bind(left_hand));
	punch_fest(left_hand);
	
	await get_tree().create_timer(0.5).timeout;
	
	right_hand.finished_action.connect(punch_fest.bind(right_hand));
	punch_fest(right_hand);
func punch_fest(hand : Hand_TheEndBoss) -> void:
	if randf() < 0.7 && max_punch_safegaurd < 3:
		hand.move_over_player();
		hand.slam_hand_wait(0.5);
		
		max_punch_safegaurd += 1;
	else:
		start_punch(hand, 1.0);
		
		max_punch_safegaurd = 0;
func punch_fest_end(selected_hand : bool = false) -> void:
	var hand : Hand_TheEndBoss;
	if selected_hand:
		hand = left_hand if left_hand == _slam_hand else right_hand;
	else:
		hand = right_hand if left_hand == _slam_hand else left_hand;
	hand.finished_action.disconnect(punch_fest);
	hand.enact_idle();

func start_punch(hand : Hand_TheEndBoss, wait : float) -> void:
	if left_hand == hand:
		hand.to_random_punch_pos(false);
		get_tree().create_timer(wait).timeout.connect(hand.enact_punch.bind(false), CONNECT_ONE_SHOT);
		return;
	
	hand.to_random_punch_pos(true);
	get_tree().create_timer(wait).timeout.connect(hand.enact_punch.bind(true), CONNECT_ONE_SHOT);

func summon_arrow(follow : Node2D) -> void:
	var arrow = get_parent().arrow;
	
	arrow.follow = follow;
	arrow.toggle_arrow(true);
	var tw : Tween = arrow.create_tween();
	tw.tween_property(arrow, "modulate:a", 1.0, 0.5);

func hide_arrow() -> void:
	var arrow = get_parent().arrow;
	
	arrow.toggle_arrow(false);
	var tw : Tween = arrow.create_tween();
	tw.tween_property(arrow, "modulate:a", 0.0, 0.5);

func death_animation() -> void:
	$AnimationPlayer.play("die");
	left_float.fall();
	right_float.fall();
	left_hand.fall();
	right_hand.fall();
	
	PlayerInfo.flag = false;
	
	$die.play();
	
	var tw : Tween = create_tween().set_parallel();
	tw.tween_property($Body.material, "shader_parameter/modulate", Color(0.0, 0.0, 0.0, 1.0), 7.0);
	
	tw.tween_property(left_float.material, "shader_parameter/modulate", Color(0.0, 0.0, 0.0, 1.0), 7.0);
	tw.tween_property(right_float.material, "shader_parameter/modulate", Color(0.0, 0.0, 0.0, 1.0), 7.0);
	
	tw.tween_property(left_float.get_hallo().material, "shader_parameter/modulate", Color(0.0, 0.0, 0.0, 1.0), 7.0);
	tw.tween_property(right_float.get_hallo().material, "shader_parameter/modulate", Color(0.0, 0.0, 0.0, 1.0), 7.0);
	
	tw.tween_property(left_hand.material, "shader_parameter/modulate", Color(0.0, 0.0, 0.0, 1.0), 7.0);
	tw.tween_property(right_hand.material, "shader_parameter/modulate", Color(0.0, 0.0, 0.0, 1.0), 7.0);

func focus_camera() -> void:
	PlayerInfo.cam.snap = false;
	PlayerInfo.cam.follow = self;
	PlayerInfo.cam.offset = Vector2(0, -64);

func unfocus_camera() -> void:
	PlayerInfo.cam.follow = PlayerInfo.player;
	PlayerInfo.cam.offset = Vector2.ZERO;
	
	await get_tree().create_timer(1.0).timeout;
	PlayerInfo.cam.snap = true;

func move_all_compoents(diff : Vector2) -> void:
	left_float.move_all_compoents(diff);
	right_float.move_all_compoents(diff);
	left_hand.position += diff;
	right_hand.position += diff;

func set_shadows(shadow_left : Sprite2D, shadow_right : Sprite2D) -> void:
	left_hand._shadow = shadow_left;
	right_hand._shadow = shadow_right;
func set_floor(floor_sprite : Sprite2D) -> void:
	left_hand._floor = floor_sprite;
	right_hand._floor = floor_sprite;
	
	if PlayerInfo.hard_mode == PlayerInfo.DIFFICULTY.NORMAL:
		floor_sprite.decay_factor = 0.2;
		floor_sprite.influence_factor = 0.03;
		floor_sprite.resist_factor = 0.1;
		floor_sprite.player_affect = 1500;
	elif PlayerInfo.hard_mode == PlayerInfo.DIFFICULTY.BARKMODE:
		floor_sprite.decay_factor = 0.3;
		floor_sprite.influence_factor = 0.05;
		floor_sprite.resist_factor = 0.15;
		floor_sprite.player_affect = 1700;

func pick_hand() -> void:
	if PlayerInfo.player.global_position.x < 0:
		_slam_hand = left_hand;
		return;
	_slam_hand = right_hand;

func start_slams(aim_time : float) -> void:
	$aim_time.wait_time = aim_time;
	$aim_time.timeout.connect(slam_active_hand, CONNECT_ONE_SHOT);
	$aim_time.start();
	
	aim_hands();

func aim_hands() -> void:
	if left_hand == _slam_hand:
		if !left_hand.is_in_states(["over_hold", "slam"]):
			left_hand.move_over_player();
			right_hand.enact_idle();
	else:
		if !right_hand.is_in_states(["over_hold", "slam"]):
			left_hand.enact_idle();
			right_hand.move_over_player();

func duel_slam_attack(aim_time : float) -> void:
	$aim_time.wait_time = aim_time;
	$aim_time.timeout.connect(slam_duel_hands, CONNECT_ONE_SHOT);
	$aim_time.start();
	
	left_hand.begin_wave_slam();
	right_hand.begin_wave_slam();

func slam_duel_hands() -> void:
	left_hand.slam_hand();
	right_hand.slam_hand();
	
	left_hand.slammed.connect($DualSlam.play, CONNECT_ONE_SHOT);

func slam_active_hand() -> void:
	if left_hand.is_in_states(["over_hold"]):
		left_hand.slam_hand();
	elif right_hand.is_in_states(["over_hold"]):
		right_hand.slam_hand();

func idle_slam_hand() -> void:
	$aim_time.stop();
	_slam_hand.enact_idle();
func idle_hands() -> void:
	left_hand.enact_idle();
	right_hand.enact_idle();

func aim_lazor(selected_hand : bool = true, charge_time : float = 1.0, blast_time : float = 0.2, color : bool = false) -> void:
	if selected_hand:
		_lazor_hand = left_hand if left_hand == _slam_hand else right_hand;
	else:
		_lazor_hand = right_hand if left_hand == _slam_hand else left_hand;
	
	_lazor_hand.player_aim(charge_time, blast_time, color);

func fire_lazor() -> void:
	_lazor_hand.activate_lazor();
func clear_lazor() -> void:
	_lazor_hand.close_lazor();

func vunerable_eye() -> void:
	lower_shield();
	if _display_arrow:
		summon_arrow(_lazor_hand);
func shield_eye() -> void:
	_display_arrow = true;
	up_shield();
	_lazor_hand.enact_idle();
	hide_arrow();

func lower_shield() -> void:
	$Body.material.set_shader_parameter("color", Color("#60ffff00"));
	left_float.material.set_shader_parameter("color", Color("#60ffff00"));
	right_float.material.set_shader_parameter("color", Color("#60ffff00"));
	left_float.get_hallo().material.set_shader_parameter("color", Color("#60ffff00"));
	right_float.get_hallo().material.set_shader_parameter("color", Color("#60ffff00"));
	left_hand.material.set_shader_parameter("color", Color("#60ffff00"));
	right_hand.material.set_shader_parameter("color", Color("#60ffff00"));
	
	left_hand.toggle_hurtbox(true);
	right_hand.toggle_hurtbox(true);
	change_hit_status.emit();
func up_shield() -> void:
	var tw : Tween = create_tween().set_parallel();
	tw.tween_property($Body.material, "shader_parameter/color", Color("#60ffff5a"), 0.2);
	tw.tween_property(left_float.material, "shader_parameter/color", Color("#60ffff5a"), 0.2);
	tw.tween_property(right_float.material, "shader_parameter/color", Color("#60ffff5a"), 0.2);
	tw.tween_property(left_float.get_hallo().material, "shader_parameter/color", Color("#60ffff5a"), 0.2);
	tw.tween_property(right_float.get_hallo().material, "shader_parameter/color", Color("#60ffff5a"), 0.2);
	tw.tween_property(left_hand.material, "shader_parameter/color", Color("#60ffff5a"), 0.2);
	tw.tween_property(right_hand.material, "shader_parameter/color", Color("#60ffff5a"), 0.2);
	
	left_hand.toggle_hurtbox(false);
	right_hand.toggle_hurtbox(false);
	change_hit_status.emit();
func hitable() -> bool:
	return false;

func get_minons() -> Array[Node2D]:
	return [left_hand, right_hand];

func _on_hit(_hitbox: HitBox, _hand : Hand_TheEndBoss) -> void:
	if _display_arrow:
		_display_arrow = false;
		hide_arrow();
	
	up_shield();
	
	_lazor_hand.toggle_hurtbox(false);
	$sequence_timer.stop();
	_lazor_hand.enact_idle();
	_lazor_hand.lerp_coefficent = 0.3;
	
	set_white_out(1.0);
	left_float.set_white_out(1.0);
	left_hand.set_white_out(1.0);
	right_float.set_white_out(1.0);
	right_hand.set_white_out(1.0);
	
	TimeManager.instant_time_scale(0.0, 0.3);
	PlayerInfo.cam.shake_event();
	
	get_tree().create_timer(0.1, true, false, true).timeout.connect($Hurt.play_random, CONNECT_ONE_SHOT);
	
	match PlayerInfo.hard_mode:
		PlayerInfo.DIFFICULTY.NORMAL:
			_turn += 1;
			if _turn & 1:
				_phase_2_normal();
			else:
				_phase_1_normal();
	
	$AnimationPlayer.play("hurt");
	
	var tw : Tween = create_tween().set_parallel();
	tw.tween_method(set_white_out, 1.0, 0.0, 0.1);
	tw.tween_method(left_float.set_white_out, 1.0, 0.0, 0.1);
	tw.tween_method(left_hand.set_white_out, 1.0, 0.0, 0.1);
	tw.tween_method(right_float.set_white_out, 1.0, 0.0, 0.1);
	tw.tween_method(right_hand.set_white_out, 1.0, 0.0, 0.1);
	tw.tween_interval(1.0);
	
	if get_parent().dead:
		left_hand.hurt(true);
		right_hand.hurt(true);
		return;
	
	left_hand.hurt();
	right_hand.hurt();
	get_parent().hurt_action();
	
	await tw.finished;
	
	_lazor_hand.lerp_coefficent = 0.1;
	get_parent().return_rest();
	
	tw = create_tween();
	if PlayerInfo.hard_mode != PlayerInfo.DIFFICULTY.EASY:
		tw.tween_interval(1.0);
		tw.tween_callback(_releash_the_bees);
		tw.tween_interval(2.7);
	else:
		tw.tween_interval(1.2);
	
	tw.tween_callback(duel_slam_attack.bind(1.5));
	tw.tween_callback(idle_hands).set_delay(3.0);
	
	tw.finished.connect(_next_sequence, CONNECT_ONE_SHOT);

func set_outline(out : float) -> void:
	$Body.material.set_shader_parameter("width", out);
func set_white_out(out : float) -> void:
	$Body.material.set_shader_parameter("white_out", out);

