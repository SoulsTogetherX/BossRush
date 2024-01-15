extends Boss

const CROSS_HAIR_TEXTURE : CompressedTexture2D = preload("res://assets/sprites/characters/bosses/shaka boom/cross_hairs.png");

@export var slime_summon_area : CollisionShape2D;
@export var fly_nodes : Node;
@export var center_node : Sprite2D;

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var _current_node : Sprite2D;
var _waiting : bool = true;
var _float_tween : Tween;
var _cross_hair : Sprite2D;

func _ready() -> void:
	_current_node = center_node;
	super();
	
	$float_timer.timeout.connect(create_after_image.bind(Color(0.5, 0.5, 1.0, 1.0), 0.3));
	
	if PlayerInfo.hard_mode:
		call_deferred("pick_float");
		pass;
	else:
		_add_to_sequence(summon_slimes_start_check, 0.8 + 5);
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
		_add_to_sequence(pick_float.bind(true), 2.4);
		_add_to_sequence(idle, 2.2);
	
	var tw = create_tween().set_loops();
	tw.tween_property($Sprite2D.material, "shader_parameter/width", 1.0, 0.8);
	tw.tween_property($Sprite2D.material, "shader_parameter/width", 4.0, 0.8);
	
	primary_attack.summoned.connect(register_slime);

var _death : bool = false;
func die() -> void:
	_death = true;
	$slime_timer.stop();
	if !$attack_timer.is_stopped():
		forward_atttack_end();
	$scared_timer.stop();
	$float_timer.stop();
	
	_play_hurt();
	_animation_player.queue("dead");

func _on_hit(_hitbox: HitBox) -> void:
	$Confetti_hit.rotation = (global_position - PlayerInfo.player.global_position).angle();
	$scared_timer.stop();
	if _waiting:
		_force_move(_play_hurt, 0.6, 0);
		_waiting = false;
		up_shield();
	elif !_death:
		$sequence_timer.stop();
		_stun();
		up_shield();

func _stun() -> void:
	if !_death:
		_play_hurt();
		await get_tree().create_timer(0.5).timeout;
		mad_hit_start();

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

func pick_float(center : bool = false) -> void:
	if center:
		if _current_node != center_node:
			_float_over(center_node.global_position);
			_current_node = center_node;
	else:
		var new_node : Sprite2D;
		while true:
			new_node = fly_nodes.get_children().pick_random();
			if _current_node != new_node:
				break;
		
		_current_node = new_node;
		_float_over(new_node.global_position);

var float_height : float = 10;
func _float_over(pos : Vector2) -> void:
	$float_timer.start();
	
	pos += Vector2(0, 10);
	
	_animation_player.play("float_start");
	if _float_tween:
		_float_tween.finished.emit();
		_float_tween.kill();
	
	_float_tween = create_tween();
	_float_tween.tween_property(self, "global_position", global_position + (Vector2.UP * float_height), 0.5);
	_float_tween.tween_property(self, "global_position", pos + (Vector2.UP * float_height), 1.0).set_delay(0.2);
	_float_tween.tween_property(self, "global_position", pos, 0.5).set_delay(0.2);
	_float_tween.tween_callback(_animation_player.play.bind("float_end"));
	_float_tween.tween_callback($float_timer.stop);
	_float_tween.tween_property($land_particles, "emitting", true, 0.0).set_delay(0.2);
	
	const up : Vector2 = Vector2(0, -28);
	const down : Vector2 = Vector2(0, -36);
	const stand : Vector2 = Vector2(0, -32);
	
	var sprite : Sprite2D = $Sprite2D;
	var tween = create_tween();
	tween.tween_property(sprite, "position", up, 0.2).set_delay(0.7);
	tween.tween_property(sprite, "position", down, 0.2);
	tween.tween_property(sprite, "position", up, 0.2);
	tween.tween_property(sprite, "position", down, 0.2);
	tween.tween_property(sprite, "position", up, 0.2);
	tween.tween_property(sprite, "position", down, 0.2);
	tween.tween_property(sprite, "position", stand, 0.5);

func forward_atttack_start() -> void:
	if !$scared_timer.is_stopped():
		return;
	spawn_crosshair();
	await get_tree().create_timer(0.3).timeout;
	$attack_timer.start();
func forward_atttack() -> void:
	tertiary_attack.force_handle_attack(self,  PlayerInfo.player.global_position, get_alignment());
	if $scared_timer.is_stopped():
		$attack_timer.start();
	else:
		_cross_hair.queue_free();
func forward_atttack_end() -> void:
	_cross_hair.queue_free();
	$attack_timer.stop();

func spawn_crosshair() -> void:
	_cross_hair = Sprite2D.new();
	_cross_hair.texture = CROSS_HAIR_TEXTURE;
	_cross_hair.modulate = Color(1.0, 1.0, 1.0, 0.5);
	PlayerInfo.player.add_child(_cross_hair);
	
	_cross_hair.position = Vector2.RIGHT.rotated(TAU * randf()) * 1000;
	var tw : Tween = create_tween().set_parallel();
	tw.tween_property(_cross_hair, "modulate", Color.WHITE, 0.7);
	tw.tween_property(_cross_hair, "rotation_degrees", -360, 1.4);
	tw.set_trans(Tween.TRANS_ELASTIC);
	tw.set_ease(Tween.EASE_OUT);
	tw.tween_property(_cross_hair, "position", PlayerInfo.player.get_center_local(), 0.5);

func summon_slimes_start() -> void:
	$slime_timer.start();
	_animation_player.play("summoning_start");
func summon_slimes() -> void:
	primary_attack.handle_attack(self, PlayerInfo.player.global_position, get_alignment());
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
	var pp = PhysicsPointQueryParameters2D.new();
	pp.position = pos;
	pp.collision_mask = 256;
	return get_world_2d().direct_space_state.intersect_point(pp, 1).is_empty();

var _slime_summoned : Array[ExchangeType] = [];
func register_slime(slime : ExchangeType) -> void:
	_slime_summoned.append(slime);
	slime.killed.connect(slime_killed.bind(slime));
func slime_killed(slime : ExchangeType) -> void:
	_slime_summoned.erase(slime);
	if _slime_summoned.size() == 0 && $slime_timer.is_stopped():
		if !$float_timer.is_stopped():
			_sequence_timer.timeout.connect(scared_start, CONNECT_ONE_SHOT);
		else:
			scared_start();
func summon_slimes_start_check() -> void:
	if _slime_summoned.size() < 5:
		summon_slimes_start();
	else:
		_next_sequence(1);

func scared_start() -> void:
	$sequence_timer.stop();
	$scared_timer.start();
	if !$attack_timer.is_stopped():
		forward_atttack_end();
	if !$float_timer.is_stopped():
		$float_timer.start();
		_float_tween.kill();
	lower_shield();
	_animation_player.play("scared_start");
	_animation_player.queue("scared");
func end_scared() -> void:
	_reset_all();
	up_shield();

func mad_hit_start() -> void:
	_animation_player.play("angry");
	
	await get_tree().create_timer(1.6).timeout;
	var launch : LinearLaunch = secondary_attack.launch;
	if _current_node == center_node:
		launch.fire_range = 300;
		launch.speed = 200;
	else:
		launch.fire_range = 600;
		launch.speed = 350;
	secondary_attack.handle_attack(self, PlayerInfo.player.global_position, get_alignment());
	
	await get_tree().create_timer(0.2).timeout;
	burn_ground();
	get_tree().create_timer(1.8).timeout.connect(mad_hit_end, CONNECT_ONE_SHOT);
func mad_hit_end() -> void:
	_reset_all();

func burn_ground() -> void:
	_current_node.visible = true;
	_current_node.rotation = TAU * randf();

func lower_shield() -> void:
	$Sprite2D.material.set_shader_parameter("color", Color("#60ffff00"));
	$hurt_box.toggle_hurtbox(true);
func up_shield() -> void:
	var tw : Tween = create_tween();
	tw.tween_property($Sprite2D.material, "shader_parameter/color", Color("#60ffff5a"), 0.2);
	$hurt_box.toggle_hurtbox(false);

func _reset_all() -> void:
	$slime_timer.stop();
	if !$attack_timer.is_stopped():
		forward_atttack_end();
	$scared_timer.stop();
	$float_timer.stop();
	_reset_sequence();

func get_skills() -> Array[Exchangable]:
	return [primary_attack, health_handle, load("res://assets/resources/instances/exchangable/leshy/Nature Dash_Reward.tres")]
