extends Boss

@export var slime_summon_area : CollisionShape2D;

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var _waiting : bool = true;

func _ready() -> void:
	super();
	
	if PlayerInfo.hard_mode:
		pass;
	else:
		_add_to_sequence(summon_slimes_start_check, 0.8 + 5);
		_add_to_sequence(summon_slimes_end, 0.25);
		_add_to_sequence(idle, 2.2);
		_add_to_sequence(summon_slimes_start_check, 0.8 + 5);
		_add_to_sequence(summon_slimes_end, 0.25);
		_add_to_sequence(idle, 2.2);
		_add_to_sequence(summon_slimes_start_check, 0.8 + 5);
		_add_to_sequence(summon_slimes_end, 0.25);
		#idle laugh
		_add_to_sequence(idle, 2.2);
	
	var tw = create_tween().set_loops();
	tw.tween_property($Sprite2D.material, "shader_parameter/width", 1.0, 0.8);
	tw.tween_property($Sprite2D.material, "shader_parameter/width", 4.0, 0.8);
	
	primary_attack.summoned.connect(register_slime);

var _death : bool = false;
func die() -> void:
	_death = true;
	_animation_player.play("dead");
	#queue_free();

func _on_hit(_hitbox: HitBox) -> void:
	$scared_timer.stop();
	if _waiting:
		_force_move(_play_hurt, 0.5, 0);
		_waiting = false;
		up_shield();
	elif !_death:
		$sequence_timer.stop();
		_stun();
		up_shield();

func _stun() -> void:
	_play_hurt();
	await get_tree().create_timer(1.0).timeout;
	mad_hit_start();

func _play_hurt() -> void:
	$Sprite2D.flip_h = (randf() < 0.5);
	_animation_player.play("hurt");

func idle() -> void:
	if _animation_player.current_animation != "idle":
		_animation_player.play("idle");

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
		$sequence_timer.stop();
		$scared_timer.start();
		lower_shield();
		_animation_player.play("scared_start");
func summon_slimes_start_check() -> void:
	if _slime_summoned.size() == 0:
		summon_slimes_start();
	else:
		_next_sequence(2);

func end_scared() -> void:
	_reset_sequence();
	up_shield();

func mad_hit_start() -> void:
	_animation_player.play("angry");
	
	await get_tree().create_timer(1.6).timeout;
	$mad_timer.start();
	secondary_attack.handle_attack(self, PlayerInfo.player.global_position, get_alignment());
	get_tree().create_timer(2.0).timeout.connect(mad_hit_end, CONNECT_ONE_SHOT);
func mad_hit() -> void:
	print("mad")
	pass;
func mad_hit_end() -> void:
	$mad_timer.stop();
	_reset_sequence();

func lower_shield() -> void:
	$Sprite2D.material.set_shader_parameter("color", Color("#60ffff00"));
	$hurt_box.toggle_hurtbox(true);
func up_shield() -> void:
	var tw : Tween = create_tween();
	tw.tween_property($Sprite2D.material, "shader_parameter/color", Color("#60ffff5a"), 0.2);
	$hurt_box.toggle_hurtbox(false);

func get_skills() -> Array[Exchangable]:
	return [primary_attack, health_handle, load("res://assets/resources/instances/exchangable/leshy/Nature Dash_Reward.tres")]
