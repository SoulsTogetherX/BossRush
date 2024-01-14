extends ExchangeType

@export var attack_speed : float = 0.5;

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var _target : ExchangeType;
var _dead : bool = false;
var _knock_back : Vector2;
var _knockback_tween : Tween;

const PUDDLE : CompressedTexture2D = preload("res://assets/sprites/characters/bosses/shaka boom/slime_trail.png");

func _ready() -> void:
	super();
	
	if alignment == HurtBox.ALIGNMENT.ENEMY:
		_target = PlayerInfo.player;
	else:
		_target = PlayerInfo.boss;
	
	$hurt_box.alignment = alignment;
	$hitbox.alignment = alignment;

func die() -> void:
	if $trail == null:
		return;
	
	var particle : CPUParticles2D = $trail;
	particle.reparent(get_tree().current_scene);
	get_tree().create_timer(5.0).timeout.connect(particle.queue_free);
	particle.emitting = false;
	
	_animation_player.play("dead");
	_dead = true;

func toggle_trail(toggle : bool) -> void:
	$trail.emitting = toggle;

func create_puddle() -> void:
	var puddle1 : Sprite2D = Sprite2D.new();
	puddle1.texture = PUDDLE;
	get_tree().current_scene.add_child(puddle1);
	
	puddle1.global_position = global_position;
	puddle1.scale = Vector2(1.5, 1.5);
	puddle1.z_index = -2;
	puddle1.rotation = randf() * TAU;
	
	var puddle2 : Sprite2D = Sprite2D.new();
	puddle2.texture = PUDDLE;
	get_tree().current_scene.add_child(puddle2);
	
	puddle2.global_position = global_position;
	puddle2.scale = Vector2(1.5, 1.5);
	puddle2.z_index = -2;
	puddle2.rotation = randf() * TAU;
	
	var tw : Tween = puddle1.create_tween();
	tw.tween_property(puddle1, "modulate", Color(1, 1, 1, 0), 3.0);
	tw.tween_callback(puddle1.queue_free);
	
	tw = puddle2.create_tween();
	tw.tween_property(puddle2, "modulate", Color(1, 1, 1, 0), 3.0);
	tw.tween_callback(puddle2.queue_free);

func _on_hit(hitbox: HitBox) -> void:
	if !_dead && _animation_player.current_animation != "hurt":
		_animation_player.play("hurt");
		set_physics_process(true);
	
	var target_pos : Vector2 = _target.global_position if hitbox == null else hitbox.global_position;
	var dir : Vector2 = (global_position - target_pos).normalized();
	_knock_back = dir * 100;
	
	if _knockback_tween:
		_knockback_tween.kill();
	_knockback_tween = create_tween().set_parallel();
	
	_knockback_tween.tween_property($Sprite2D, "modulate", Color.RED, 0.15);
	_knockback_tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.05).set_delay(0.15);
	
	_knockback_tween.tween_property($Sprite2D, "scale", Vector2(0.5, 0.5), 0.1);
	_knockback_tween.tween_property($Sprite2D, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.1);
	
	_knockback_tween.chain().tween_callback(stop_knockback);

func stop_knockback() -> void:
	_knock_back = Vector2.ZERO;

func _physics_process(delta: float) -> void:
	if _knock_back == Vector2.ZERO:
		_handle_movement(delta, self, global_position, (_target.global_position - global_position).normalized());
	else:
		velocity = _knock_back;
		move_and_slide();

func _on_player_hit(_hurtbox: HurtBox) -> void:
	var box : HitBox = $hitbox;
	remove_child(box);
	await get_tree().create_timer(attack_speed).timeout;
	add_child(box);
