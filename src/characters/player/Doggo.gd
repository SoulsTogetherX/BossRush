class_name Player extends ExchangeType

#@onready var _state_overhead: StateOverhead = $StateOverhead;

@onready var _animationPlayer : AnimationPlayer = $AnimationPlayer;

func _ready() -> void:
	super();
	PlayerInfo.player = self;
	damaged.connect(PlayerInfo.health_update);
	
	
	# REMOVE THIS
	if primary_attack is SpawnAttack:
		primary_attack.summoned.connect(register_slime);
	if secondary_attack is SpawnAttack:
		secondary_attack.summoned.connect(register_slime);
	
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

func _on_hurt_box_hit(_hitbox: HitBox) -> void:
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
	LocationManager.reload();

func play_step() -> void:
	match LocationManager.get_step_type():
		0:
			$dirt_step.play_random();
		1:
			$stone_step.play_random();

func get_spawn_pos() -> Array[Vector2]:
	return [global_position + Vector2(0, 15)];

var _slime_summoned : Array[ExchangeType] = [];
func register_slime(slime : ExchangeType) -> void:
	_slime_summoned.append(slime);
	slime.killed.connect(slime_killed.bind(slime));
func slime_killed(slime : ExchangeType) -> void:
	_slime_summoned.erase(slime);
func get_minons() -> Array[ExchangeType]:
	return _slime_summoned;
