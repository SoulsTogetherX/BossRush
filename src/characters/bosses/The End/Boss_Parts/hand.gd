@tool 
class_name Hand_TheEndBoss extends FloatObjectControl

@onready var _state_overhead: StateOverhead = $state_overhead;
@onready var lazor: Node2D = $Lazor;

signal lazor_action_finished;

var _grow_tween : Tween;
var _shadow : Sprite2D;
var _slam_speed : float;
var _floor : Sprite2D;

enum SLAM_TYPE {PLAYER_SLAM, WAVE_SLAM};
var _slam_type : SLAM_TYPE = SLAM_TYPE.PLAYER_SLAM;

func _ready() -> void:
	super();
	if !Engine.is_editor_hint():
		lazor.action_finished.connect(lazor_action_finished_emit);
		toggle_trail(false);
	if right:
		$Hit_Box_Slam.scale.x *= -1;
		$Slam_right.scale.x *= -1;
		$Slam_left.scale.x *= -1;
		
		$Sprite2D/Pupil.flip_h = true;

func set_boxes(health_monitor : HealthMonitor, alignment : HurtBox.ALIGNMENT) -> Signal:
	$hurt_box.health_monitor = health_monitor;
	$hurt_box.alignment = alignment;
	$Hit_Box_Slam.alignment = alignment;
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

func player_aim(charge_time : float, blast_time) -> void:
	z_index = -11;
	set_lerp_co(0.1);
	change_move_type(STATE.STATIONARY);
	_state_overhead.change_state("main", "aim_lazor");
	
	var white : Material = $Sprite2D.material;
	var tw : Tween = create_tween();
	tw.tween_property(white, "shader_parameter/replace_with", Color(1, 1, 0), charge_time);
	tw.tween_property(white, "shader_parameter/replace_with", Color.WHITE, blast_time);

func enact_idle() -> void:
	_state_overhead.change_state("main", "idle");
func _enact_idle() -> void:
	set_lerp_co(0.03, 0.1, 1.0);
	z_index = -12;
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

func slam_hand() -> void:
	z_index = 1;
	_state_overhead.change_state("main", "slam");

func activate_lazor() -> void:
	lazor.activate_lazor(0.1);
	
	change_move_type(STATE.STATIONARY);
	_state_overhead.change_state("main", "stationary");
func close_lazor() -> void:
	lazor.close_lazor(0.1);
func lazor_action_finished_emit() -> void:
	lazor_action_finished.emit();

func shink_shadow_height(max_height : float, time : float) -> void:
	var tw : Tween = create_tween();
	tw.tween_method(_shink_shadow_height.bind(max_height), -1.0, 1.0, time);

func _shink_shadow_height(interval : float, max_height : float) -> void:
	_shadow.global_position = global_position + Vector2.DOWN * max_height * ((interval * interval) - 1);

func get_hold_position() -> Vector2:
	match _slam_type:
		SLAM_TYPE.PLAYER_SLAM:
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

func hurt() -> void:
	$AnimationPlayer.play("hurt");
	$AnimationPlayer.queue("idle");

func set_outline(out : float) -> void:
	material.set_shader_parameter("width", out);
func set_white_out(out : float) -> void:
	material.set_shader_parameter("white_out", out);

func toggle_trail(toggle : bool) -> void:
	$trail.emitting = toggle;
