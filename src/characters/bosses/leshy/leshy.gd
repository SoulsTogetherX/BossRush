extends Boss

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var _move_direction : Vector2;
var _dash_distance : float;

func _ready() -> void:
	super();
	set_physics_process(false);
	_add_to_sequence(dash, 0.6);
	_add_to_sequence(dash, 0.6);
	_add_to_sequence(dash, 0.6);
	_add_to_sequence(spin_attack, 1.8);
	_add_to_sequence(dash, 0.6);
	_add_to_sequence(dash, 0.6);
	_add_to_sequence(dash, 0.6);
	_add_to_sequence(_idle, 1.8);
	
	_next_sequence();
	
	_dash_distance = primary_movement.speed * primary_movement.duration;

func dance() -> void:
	_animation_player.play("spin_start");

func spin_attack() -> void:
	_animation_player.play("spin_start");
	primary_attack.handle_attack(self, global_position + Vector2.LEFT, get_alignment());

func dash() -> void:
	while true:
		var rand : int = randi_range(0, 7);
		_move_direction = Vector2.RIGHT.rotated((PI / 4) * rand);
		if can_move_here((_move_direction * _dash_distance) + global_position):
			break;
	
	_animation_player.play("dash_" + get_animation_modifer_4(_move_direction.angle(), $Sprite2D));
	set_physics_process(true);

func _idle() -> void:
	_animation_player.play("idle");

func _unlock() -> void:
	_lock = false;
	set_physics_process(false);

func _physics_process(_delta: float) -> void:
	_handle_movement(self, global_position, _move_direction);

func die() -> void:
	queue_free();

func _on_hit(hitbox: HitBox) -> void:
	var tween = create_tween();
	tween.tween_property(self, "modulate", Color.RED, 0.1);
	tween.tween_property(self, "modulate", Color.WHITE, 0.1);
