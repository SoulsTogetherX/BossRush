@tool 
class_name Hand_TheEndBoss extends FloatObjectControl

@onready var _state_overhead: StateOverhead = $state_overhead;
@onready var lazor: Node2D = $Lazor;

signal lazor_action_finished;
signal finished_action;
signal slammed;

var _grow_tween : Tween;
var _shadow : Sprite2D;
var _slam_speed : float;
@warning_ignore("unused_private_class_variable")
var _floor : Sprite2D;

enum SLAM_TYPE {PLAYER_SLAM, WAVE_SLAM};
var _slam_type : SLAM_TYPE = SLAM_TYPE.PLAYER_SLAM;

func _ready() -> void:
	super();
	if !Engine.is_editor_hint():
		lazor.action_finished.connect(lazor_action_finished_emit);
		toggle_trail(false);
		$Sprite2D/Pupil.target = PlayerInfo.player;
	if right:
		$Hit_Box_Slam.scale.x *= -1;
		$Slam_right.scale.x *= -1;
		$Slam_left.scale.x *= -1;
		
		$Sprite2D/Pupil.flip_h = true;

func fall() -> void:
	_fall = true;
	_fall_speed.y = randf() + 1.0;
	_shadow.visible = false;

func set_boxes(health_monitor : HealthMonitor, alignment : HurtBox.ALIGNMENT) -> Signal:
	$hurt_box.health_monitor = health_monitor;
	$hurt_box.alignment = alignment;
	$Hit_Box_Slam.alignment = alignment;
	$Hit_Box_Punch.alignment = alignment;
	$Lazor/Hit_Box_Lazor.alignment = alignment;
	
	toggle_slambox(false);
	
	return $hurt_box.hit;
func toggle_hurtbox(toggle : bool) -> void:
	$hurt_box.toggle_hurtbox(toggle);
func toggle_slambox(toggle : bool) -> void:
	$Hit_Box_Slam.toggle_hitbox(toggle);
func hitable() -> bool:
	return $hurt_box.monitorable;

func set_lerp_co(start : float, end : float = -1, time : float = -1) -> void:
	if _grow_tween:
		_grow_tween.kill();
	
	lerp_coefficent = start;
	if end > 0 && time > 0:
		_grow_tween = create_tween();
		_grow_tween.set_ease(Tween.EASE_IN);
		_grow_tween.set_trans(Tween.TRANS_EXPO);
		_grow_tween.tween_property(self, "lerp_coefficent", end, time);

func is_in_states(states : Array[String]) -> bool:
	return _state_overhead.is_in_states("main", states);

var stop_punch : bool = false;
func to_random_punch_pos(left : bool = false) -> void:
	$AnimationPlayer.play("idle");
	set_lerp_co(0.1);
	z_index = 1;
	act_on_local = false;
	stop_punch = false;
	
	enact_position = Vector2(0, -200);
	
	var tw : Tween = create_tween().set_parallel();
	tw.tween_property(self, "rotation_degrees", 0.0, 0.5);
	tw.tween_property(self, "scale", Vector2.ONE, 0.5);
	tw.tween_method(tween_shadow, 0.0, 1.0, 0.5);
	
	await get_tree().create_timer(0.5).timeout;
	if stop_punch:
		return;
	
	enact_position = Vector2(360 * (-1 if left else 1), (randf() * 240) - 15);
	
	change_move_type(STATE.STATIONARY);
	_state_overhead.change_state("main", "stationary");
func enact_punch(left : bool = false, time : float = 0.5) -> void:
	$AnimationPlayer.play("punch");
	z_index = 1;
	
	var tw : Tween = create_tween();
	tw.tween_method(tween_shadow, 0.0, 1.0, time);
	await tw.finished;
	if stop_punch:
		return;
	
	$Hit_Box_Punch.toggle_hitbox(true);
	set_lerp_co(0.5);
	
	tw = create_tween().set_parallel();
	tw.tween_property(self, "enact_position:x", 360 * (1 if left else -1), 0.2);
	tw.tween_method(tween_shadow, 0.0, 1.0, 0.2);
	tw.chain().tween_interval(0.3);
	tw.tween_method(tween_shadow, 0.0, 1.0, 0.3);
	
	await tw.finished;
	$Hit_Box_Punch.toggle_hitbox(false);
	if stop_punch:
		return;
	
	await get_tree().create_timer(0.3).timeout;
	if stop_punch:
		return;
	finished_action.emit();

func tween_shadow(_interval : float) -> void:
	_shadow.global_position = _shadow.global_position.lerp(global_position, 0.2);

func move_to_random_firing_position() -> void:
	var x : float = randf() * 300;
	if !right: x *= -1;
	_move_to_firing_position(x);

func align_player_firing_position() -> void:
	_move_to_firing_position(PlayerInfo.player.global_position.x);

func fire_at_position(x : float) -> void:
	_move_to_firing_position(clampf(x, -300, 300));

func _move_to_firing_position(x : float) -> void:
	set_lerp_co(0.1);
	z_index = -11;
	act_on_local = false;
	
	enact_position = Vector2(x, -85);
	
	change_move_type(STATE.STATIONARY);
	_state_overhead.change_state("main", "stationary");

var _replace_tween : Tween;
func player_aim(charge_time : float, blast_time, color : bool) -> void:
	z_index = -11;
	set_lerp_co(0.1);
	change_move_type(STATE.STATIONARY);
	_state_overhead.change_state("main", "aim_lazor");
	
	_replace_tween = create_tween();
	if color:
		_replace_tween.tween_property(material, "shader_parameter/replace_with", Color(1, 0, 0), charge_time);
	else:
		_replace_tween.tween_property(material, "shader_parameter/replace_with", Color(1, 1, 0), charge_time);
	_replace_tween.tween_property(material, "shader_parameter/replace_with", Color.WHITE, blast_time);
	
	lazor.change_color(color);
	lazor.charge(true);

func _clear_conects() -> void:
	for cons in $await_punch.timeout.get_connections():
		cons["signal"].disconnect(cons["callable"]);
	$await_punch.stop();

func enact_idle() -> void:
	_clear_conects();
	stop_punch = true;
	_state_overhead.change_state("main", "idle");
func _enact_idle() -> void:
	set_lerp_co(0.03, 0.1, 1.0);
	act_on_local = true;
	
	enact_position = Vector2(250, 0);
	if !right: enact_position.x *= -1;
	
	change_move_type(STATE.IDLE);

func move_over_player() -> void:
	_slam_speed = 0.25;
	_slam_type = SLAM_TYPE.PLAYER_SLAM;
	slam_base();
func begin_wave_slam() -> void:
	_slam_speed = 0.1;
	_slam_type = SLAM_TYPE.WAVE_SLAM;
	slam_base();
func slam_base() -> void:
	set_lerp_co(0.1);
	z_index = 1;
	act_on_local = false;
	
	change_move_type(STATE.STATIONARY);
	_state_overhead.change_state("main", "over_hold");

func slam_hand_wait(time : float = 0.5) -> void:
	_clear_conects();
	$await_punch.wait_time = time;
	$await_punch.start();
	$await_punch.timeout.connect(slam_hand, CONNECT_ONE_SHOT);

func slam_hand() -> void:
	z_index = 1;
	_state_overhead.change_state("main", "slam");

func activate_lazor() -> void:
	lazor.activate_lazor(0.1);
	
	change_move_type(STATE.STATIONARY);
	_state_overhead.change_state("main", "stationary");
	lazor.charge(false);
func close_lazor() -> void:
	lazor.close_lazor(0.1);
func lazor_action_finished_emit() -> void:
	lazor_action_finished.emit();
	finished_action.emit();

func shink_shadow_height(max_height : float, time : float) -> void:
	var tw : Tween = create_tween();
	tw.tween_method(_shink_shadow_height.bind(max_height), -1.0, 1.0, time);

func _shink_shadow_height(interval : float, max_height : float) -> void:
	_shadow.global_position = global_position + Vector2.DOWN * max_height * ((interval * interval) - 1);

func get_hold_position() -> Vector2:
	match _slam_type:
		SLAM_TYPE.PLAYER_SLAM:
			if !PlayerInfo.player:
				return Vector2.ZERO;
			return PlayerInfo.player.global_position;
		SLAM_TYPE.WAVE_SLAM:
			return Vector2(200 * (-1 if right else 1), PlayerInfo.player.global_position.y);
	return Vector2.ZERO;
func get_hold_time() -> float:
	match _slam_type:
		SLAM_TYPE.PLAYER_SLAM:
			return 0.25;
		SLAM_TYPE.WAVE_SLAM:
			return 1.0;
	return 0.0;

func hurt(dead : bool = false) -> void:
	if _replace_tween:
		_replace_tween.kill();
	material.set_shader_parameter("replace_with", Color.WHITE);
	lazor.charge(false);
	
	if dead:
		$AnimationPlayer.play("hurt_stun");
	else:
		$AnimationPlayer.play("hurt");
		$AnimationPlayer.queue("idle");

func set_outline(out : float) -> void:
	material.set_shader_parameter("width", out);
func set_white_out(out : float) -> void:
	material.set_shader_parameter("white_out", out);

func toggle_trail(toggle : bool) -> void:
	$trail.emitting = toggle;
