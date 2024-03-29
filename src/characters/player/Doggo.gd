class_name Player extends ExchangeType

const HIT_PARTICLES : ParticleProcessMaterial = preload("res://assets/resources/instances/gpu_particles/hit_particles.tres");
const HIT_PARTICLES_SCRIPT : Script = preload("res://custom_nodes/signal_burst/single_bust_GPU.gd");

@onready var _animationPlayer : AnimationPlayer = $AnimationPlayer;

func _ready() -> void:
	super();
	PlayerInfo.player = self;
	damaged.connect(PlayerInfo.health_update);
	
	$StateOverhead.set_process_unhandled_input(false);
	$StateOverhead.set_process(false);

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack1"):
		if primary_attack:
			var fire_pos : Node2D = (PlayerInfo.weapon as Node2D) if PlayerInfo.weapon else (self as Node2D);
			primary_attack.handle_attack(fire_pos, fire_pos.get_center(), get_global_mouse_position(), alignment);
	elif event.is_action_pressed("attack2"):
		if secondary_attack:
			secondary_attack.handle_attack((self as Node2D), get_center(), get_global_mouse_position(), alignment);

func get_input() -> Vector2:
	return Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized();

func get_weapon_info() -> Array[float]:
	return [get_local_mouse_position().angle(), global_position.distance_to(get_global_mouse_position())];

func get_max_health() -> int:
	return $HealthMonitor.max_health;

func get_health() -> int:
	return $HealthMonitor.health;

func set_health(amount : int) -> void:
	$HealthMonitor.update_health_no_signal(amount);

var last_ani_type : String = "";
func set_direction(animationType : String, angle : float) -> void:
	var animation : String = animationType + get_animation_modifer_4(angle);
	if _animationPlayer.current_animation != animation:
		var pos : float = _animationPlayer.current_animation_position;
		_animationPlayer.play(animation);
		if last_ani_type == animationType:
			_animationPlayer.seek(pos, true);
		else:
			last_ani_type = animationType;
func change_direction(angle : float) -> void:
	var animation : String;
	if last_ani_type.is_empty():
		animation = "idle_" + get_animation_modifer_4(angle);
	else:
		animation = last_ani_type + get_animation_modifer_4(angle);
	 
	if _animationPlayer.current_animation != animation:
		var pos : float = _animationPlayer.current_animation_position;
		_animationPlayer.play(animation);
		_animationPlayer.seek(pos, true);

func _on_hurt_box_hit(hitbox: HitBox) -> void:
	if hitbox is HitBoxColor:
		var hit_particles = GPUParticles2D.new();
		hit_particles.script = HIT_PARTICLES_SCRIPT;
		hit_particles.process_material = HIT_PARTICLES;
		hit_particles.global_position = get_center();
		
		if hitbox.hit_color_grad:
			hit_particles.process_material.color_ramp = hitbox.hit_color_grad;
		else:
			hit_particles.process_material.color = hitbox.hit_color;
		
		hit_particles.amount = 60;
		hit_particles.one_shot = true;
		hit_particles.explosiveness = 1.0;
		
		get_tree().current_scene.add_child(hit_particles);
	
	modulate = Color.RED;
	var t : Tween = create_tween();
	if t == null:
		return;
	
	t.tween_interval(0.3);
	t.tween_property(self, "modulate", Color.WHITE, 0.2);
	
	$hit.play();
	
	TimeManager.instant_time_scale(0.2);
	PlayerInfo.cam.shake_event(Vector3(0.3, 0.3, 0), Vector3(3., 3., 0));

func died() -> void:
	$HealthMonitor.update_health_no_signal(0);
	LocationManager.died_switch();

func play_step() -> void:
	match LocationManager.get_step_type():
		0:
			$dirt_step.play_random();
		1:
			$stone_step.play_random();

func get_spawn_pos() -> Array[Vector2]:
	return [global_position + Vector2(0, 15)];

var _slime_summoned : Array[Node2D] = [];
func register_slime(slime : ExchangeType) -> void:
	_slime_summoned.append(slime);
	slime.killed.connect(slime_killed.bind(slime));
func slime_killed(slime : ExchangeType) -> void:
	_slime_summoned.erase(slime);
func get_minons() -> Array[Node2D]:
	return _slime_summoned;
