extends Boss

@export var bushes : Node;

@onready var _animation_player: AnimationPlayer = $AnimationPlayer;
@onready var dash_sound: Emitter = $dash_sound;
@onready var idle_sound: Emitter = $idle_sound;

var _move_direction : Vector2;
var _dash_distance : float;

var _waiting : bool = true;

func _ready() -> void:
	super();
	set_physics_process(false);
	if PlayerInfo.hard_mode:
		_add_to_sequence(dash_hard, 0.6);
		_add_to_sequence(dash_hard, 0.6);
		_add_to_sequence(dash_hard, 0.6);
		_add_to_sequence(spin_attack_hard, 2.3);
		_add_to_sequence(dash_hard, 0.6);
		_add_to_sequence(dash_hard, 0.6);
		_add_to_sequence(dash_hard, 0.6);
		_add_to_sequence(spin_attack_hard, 2.3);
		_add_to_sequence(dash_hard, 0.6);
		_add_to_sequence(_idle, 0.3);
		_add_to_sequence(hide_self.bind("bush_hard", 0.25), 2.5);
		_add_to_sequence(show_self_hard, 0.75);
		
		$dash_timer.timeout.connect(create_after_image.bind(Color(1.0, 1.0, 1.0, 0.1)));
		$hitbox/CollisionShape2D.disabled = false;
	else:
		_add_to_sequence(dash, 0.6);
		_add_to_sequence(dash, 0.6);
		_add_to_sequence(dash, 0.6);
		_add_to_sequence(spin_attack, 2.3);
		_add_to_sequence(dash, 0.6);
		_add_to_sequence(dash, 0.6);
		_add_to_sequence(dash, 0.6);
		_add_to_sequence(_idle, 0.6);
		_add_to_sequence(hide_self.bind("bush", 0.3), 5.6);
		_add_to_sequence(show_self, 2.0);
		
		$dash_timer.timeout.connect(create_after_image.bind(Color(1.0, 1.0, 1.0, 0.3)));
		$hitbox/CollisionShape2D.disabled = true;
	
	call_deferred("_calculate_distance");
	call_deferred("_set_up_tweens");
	
	for bush in bushes.get_children():
		bush.scale = Vector2.ZERO;
		bush.visible = false;
		bush.get_node("StaticBody2D").collision_layer = 0;
	
	before_swap.connect(before_change);
	$light_holder.visible = false;

func _set_up_tweens() -> void:
	var tw : Tween = create_tween().set_loops();
	tw.tween_property($light_holder, "scale", Vector2(0.9, 0.9), 1.5);
	tw.tween_property($light_holder, "scale", Vector2(1.1, 1.1), 1.5);
	
	tw = create_tween().set_loops();
	tw.tween_property(_sprite.material, "shader_parameter/width", 1.0, 0.8);
	tw.tween_property(_sprite.material, "shader_parameter/width", 4.0, 0.8);

func _calculate_distance() -> void:
	_dash_distance = primary_movement.speed * primary_movement.duration;

func dance() -> void:
	_animation_player.play("spin_start");

func spin_attack_hard() -> void:
	spin_attack_base();
	primary_attack.handle_attack(self, PlayerInfo.player.global_position, get_alignment());

func spin_attack() -> void:
	spin_attack_base();
	primary_attack.handle_attack(self, global_position + Vector2.LEFT, get_alignment());

func spin_attack_base() -> void:
	$hurt_box.toggle_hurtbox(false);
	_animation_player.play("spin_start");
	$spin_sound_start.play();
	await get_tree().create_timer(0.2).timeout;
	$spin_sound_continue.play();
	
	await get_tree().create_timer(0.3).timeout;

var _shown_bushed : Array[Node2D] = []
func hide_self(animate : String, delay : float) -> void:
	_animation_player.play("hide");
	var num : int;
	if delay == 0.3:
		num = randi_range(9, 14);
	else:
		num = randi_range(18, 22);
		$hitbox/CollisionShape2D.disabled = true;
	
	var shuffel = bushes.get_children();
	shuffel.shuffle();
	for idx in num:
		_shown_bushed.append(shuffel[idx]);
	
	var self_pos = shuffel[num];
	
	var tw : Tween = create_tween().set_parallel();
	for bush in _shown_bushed:
		bush.visible = true;
		bush.get_node("StaticBody2D").collision_layer = 64;
		tw.tween_property(bush, "scale", Vector2(1.0, 1.0), 0.2);
	
	self_pos.visible = true;
	tw.tween_property(self_pos, "scale", Vector2(1.0, 1.0), delay);
	await _animation_player.animation_finished;
	
	$light_holder.visible = false;
	lower_shield();
	global_position = self_pos.get_child(0).global_position;
	global_position.y += 49.3333;
	_animation_player.play(animate);
	
	self_pos.scale = Vector2.ZERO;
	self_pos.visible = false;
	
	swap(true);
	await get_tree().create_timer(0.05).timeout;
	$hurt_box.toggle_hurtbox(true);

func show_self_hard() -> void:
	_animation_player.play("jump_hard");
	up_shield();
	await get_tree().create_timer(0.5).timeout;
	$hitbox/CollisionShape2D.disabled = false;
	show_self_base();

func show_self() -> void:
	_animation_player.play("jump");
	await get_tree().create_timer(1.6).timeout;
	up_shield();
	show_self_base();

func show_self_base() -> void:
	hide_bushes();
	swap(false);

func hide_bushes() -> void:
	if _shown_bushed.is_empty():
		return;
	
	var tw : Tween = create_tween().set_parallel();
	for bush in _shown_bushed:
		bush.get_node("StaticBody2D").collision_layer = 0;
		tw.tween_property(bush, "scale", Vector2(0.0, 0.0), 0.2);
		tw.tween_property(bush, "visible", false, 0.0).set_delay(0.2)
	
	_shown_bushed.clear();

func lower_shield() -> void:
	_sprite.material.set_shader_parameter("color", Color("#60ffff00"));
	$hurt_box.toggle_hurtbox(true);

func up_shield() -> void:
	var tw : Tween = create_tween();
	tw.tween_property(_sprite.material, "shader_parameter/color", Color("#60ffff5a"), 0.2);
	$hurt_box.toggle_hurtbox(false);

func dash_hard() -> void:
	_sprite.material.set_shader_parameter("modulate", Color("#ffffff00"));
	
	var pos : Vector2 = PlayerInfo.player.global_position - global_position;
	_move_direction = pos.normalized();
	
	dash_base(_move_direction.angle());

func dash() -> void:
	_sprite.material.set_shader_parameter("modulate", Color("#ffffffff"));
	while true:
		var rand : int = randi_range(0, 7);
		_move_direction = Vector2.RIGHT.rotated((PI / 4) * rand);
		if can_move_here((_move_direction * _dash_distance) + global_position):
			break;
	
	dash_base(_move_direction.angle());

func dash_base(angle : float) -> void:
	$hurt_box.toggle_hurtbox(false);
	$dash_timer.start();
	$spin_particles.emitting = false;
	
	_animation_player.play("dash_" + get_animation_modifer_4(angle));
	dash_sound.play_random();
	set_physics_process(true);

func can_move_here(pos : Vector2) -> bool:
	var pp = PhysicsPointQueryParameters2D.new();
	pp.collide_with_areas = true 
	pp.position = pos;
	pp.collision_mask = 32;
	return !get_world_2d().direct_space_state.intersect_point(pp, 1).is_empty();

func _idle() -> void:
	_animation_player.play("idle");
	idle_sound.play_random();

func _unlock() -> void:
	_lock = false;
	set_physics_process(false);

func _physics_process(delta: float) -> void:
	_handle_movement(delta, self, global_position, _move_direction);

var _death : bool = false;
func die() -> void:
	_death = true;
	_sequence_timer.stop();
	_animation_player.play("RESET");
	await _animation_player.animation_finished;
	$light_holder.visible = false;
	$AnimationPlayer.play("die");
	
	$AnimatableBody2D/CollisionShape2D2.disabled = false;
	$AnimatableBody2D/CollisionShape2D2.global_position = global_position;
	
	await get_tree().create_timer(2.5).timeout;
	
	primary_attack.reset();
	_reward_manager._spawn_orbs(self);
	$hurt_box.visible = false;
	$hit_area.visible = false;

func _on_hit(_hitbox: HitBox) -> void:
	if _waiting:
		_force_move(_stun, 0.5, 0);
		$HealthMonitor.update_health_no_signal($HealthMonitor.max_health);
		$AnimatableBody2D/CollisionShape2D2.disabled = true;
		_waiting = false;
	elif !_death:
		_force_move(_stun, 0.5, (2 if get_sequence_index() == 8 else 1));
	
	if !_death:
		$light_holder.visible = true;
		$hurt_sound.play_random();
		swap(false);

func _stun() -> void:
	hide_bushes();
	up_shield();
	TimeManager.instant_time_scale();
	PlayerInfo.cam.shake_event();
	_animation_player.play("hurt");

func set_light_at_flip(pos : Vector2) -> void:
	pos.x *= -1 if _sprite.flip_h else 1;
	$light_holder.position = pos;

func before_change() -> void:
	_animation_player.play("RESET");
	_sprite.material.set_shader_parameter("modulate", Color("#ffffffff"));
	$dash_timer.stop();
	$spin_sound_continue.stop();

func swap(toggle : bool) -> void:
	$hurt_box/CollisionShape2D.set_deferred("disabled", toggle);
	$hurt_box/CollisionShape2D2.set_deferred("disabled", !toggle);
	
	$hit_area/CollisionShape2D.set_deferred("disabled", toggle);
	$hit_area/CollisionShape2D2.set_deferred("disabled", !toggle);

func get_skills() -> Array[Exchangable]:
	return [primary_attack, health_handle, load("res://assets/resources/instances/exchangable/leshy/Nature Dash_Reward.tres")]
