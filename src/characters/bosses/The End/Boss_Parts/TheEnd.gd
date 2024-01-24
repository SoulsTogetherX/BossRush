@tool
extends Boss

@export var left_float : FloatObjectControl;
@export var right_float : FloatObjectControl;

@export var left_hand : Hand_TheEndBoss;
@export var right_hand : Hand_TheEndBoss;

var _slam_hand : Hand_TheEndBoss;
var _lazor_hand : Hand_TheEndBoss;

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
	
	_add_to_sequence(pick_hand, 0.01);
	_add_to_sequence(start_slams.bind(0.7), 1.5);
	_add_to_sequence(start_slams.bind(0.7), 1.5);
	_add_to_sequence(start_slams.bind(0.7), 1.5);
	_add_to_sequence(start_slams.bind(0.7), 1.5);
	_add_to_sequence(start_slams.bind(0.7), 1.5);
	_add_to_sequence(start_slams.bind(0.7), 1.5);
	_add_to_sequence(idle_slam_hand, 0.01);
	_add_to_sequence(aim_lazor.bind(true, 2.7, 0.7), 2.0);
	_add_to_sequence(fire_lazor, 0.7);
	_add_to_sequence(clear_lazor, 0.2);
	_add_to_sequence(vunerable_eye, 1.5);
	_add_to_sequence(shield_eye, 0.01);
	
	$AnimationPlayer.play("start");
	
	up_shield();

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

func slam_active_hand() -> void:
	if left_hand.is_in_states(["over_hold"]):
		left_hand.slam_hand();
	elif right_hand.is_in_states(["over_hold"]):
		right_hand.slam_hand();

func idle_slam_hand() -> void:
	_slam_hand.enact_idle();
func idle_hands() -> void:
	left_hand.enact_idle();
	right_hand.enact_idle();

func aim_lazor(selected_hand : bool = true, charge_time : float = 1.0, blast_time : float = 0.2) -> void:
	prints(charge_time, blast_time)
	
	if selected_hand:
		_lazor_hand = left_hand if left_hand == _slam_hand else right_hand;
	else:
		_lazor_hand = right_hand if left_hand == _slam_hand else left_hand;
	
	_lazor_hand.player_aim(charge_time, blast_time);

func fire_lazor() -> void:
	_lazor_hand.activate_lazor();
func clear_lazor() -> void:
	_lazor_hand.close_lazor();

func vunerable_eye() -> void:
	lower_shield();
func shield_eye() -> void:
	up_shield();
	_lazor_hand.enact_idle();

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

func _on_hit(_hitbox: HitBox, hand : Hand_TheEndBoss) -> void:
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
	
	get_parent().hurt_action();
	
	left_hand.hurt();
	right_hand.hurt();
	$AnimationPlayer.play("hurt");
	
	var tw : Tween = create_tween().set_parallel();
	tw.tween_method(set_white_out, 1.0, 0.0, 0.1);
	tw.tween_method(left_float.set_white_out, 1.0, 0.0, 0.1);
	tw.tween_method(left_hand.set_white_out, 1.0, 0.0, 0.1);
	tw.tween_method(right_float.set_white_out, 1.0, 0.0, 0.1);
	tw.tween_method(right_hand.set_white_out, 1.0, 0.0, 0.1);
	tw.tween_interval(1.0);
	
	await tw.finished;
	
	_lazor_hand.lerp_coefficent = 0.1;
	get_parent().return_rest();
	up_shield();
	
	tw = create_tween();
	tw.tween_interval(1.2);
	tw.tween_callback(duel_slam_attack.bind(1.5));
	tw.tween_callback(idle_hands).set_delay(3.0);
	
	tw.finished.connect(_next_sequence.bind(1), CONNECT_ONE_SHOT);

func set_outline(out : float) -> void:
	$Body.material.set_shader_parameter("width", out);
func set_white_out(out : float) -> void:
	$Body.material.set_shader_parameter("white_out", out);
