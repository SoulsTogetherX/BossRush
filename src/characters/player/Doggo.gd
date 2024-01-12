class_name Player extends ExchangeType

#@onready var _state_overhead: StateOverhead = $StateOverhead;

@onready var _animationPlayer : AnimationPlayer = $AnimationPlayer;

func _ready() -> void:
	super();
	PlayerInfo.player = self;
	damaged.connect(PlayerInfo.health_update);

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack1"):
		if primary_attack:
			primary_attack.handle_attack((PlayerInfo.weapon as Node2D) if PlayerInfo.weapon else (self as Node2D), get_global_mouse_position(), alignment);
	elif event.is_action_pressed("attack2"):
		if secondary_attack:
			secondary_attack.handle_attack((PlayerInfo.weapon as Node2D) if PlayerInfo.weapon else (self as Node2D), get_global_mouse_position(), alignment);

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
	var animation : String = animationType + get_animation_modifer_4(angle, $main);
	if _animationPlayer.current_animation != animation:
		var pos : float = _animationPlayer.current_animation_position;
		_animationPlayer.play(animation);
		if last_ani_type == animationType:
			_animationPlayer.seek(pos, true);
		else:
			last_ani_type = animationType;
