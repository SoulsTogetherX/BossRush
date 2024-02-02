class_name Slime_Shaka extends ExchangeType

const PUDDLE : CompressedTexture2D = preload("res://assets/sprites/characters/bosses/shaka boom/slime_trail.png");

@export var attack_speed : float = 0.5;
@export var follow_distance : float = 500:
	get:
		return sqrt(follow_distance);
	set(val):
		follow_distance = val * val;

@warning_ignore("unused_private_class_variable")
@onready var _animation_player: AnimationPlayer = $AnimationPlayer;
@onready var _knock_back : Node = $StateOverhead/StateMachine/knock_back;

var _target : ExchangeType;
var _leader : ExchangeType;
var _dead : bool = false;
var _base_color : Color;

func _ready() -> void:
	super();
	
	if alignment == HurtBox.ALIGNMENT.ENEMY:
		_target = PlayerInfo.player;
		_leader = PlayerInfo.boss;
		_base_color = Color.WHITE;
	else:
		_target = PlayerInfo.boss;
		_leader = PlayerInfo.player;
		_base_color = Color(1.0, 1.0, 0, 1.0);
	
	modulate = _base_color;
	$hurt_box.alignment = alignment;
	$hitbox.alignment = alignment;
	
	$StateOverhead.set_process_unhandled_input(false);
	$StateOverhead.set_process(false);

func die() -> void:
	if $trail == null:
		return;
	
	var glow : Sprite2D = $glow;
	glow.reparent(get_tree().current_scene);
	var tw : Tween = glow.create_tween();
	tw.tween_property(glow, "modulate", Color(1.0, 1.0, 1.0, 0.0), 2.0);
	tw.tween_callback(glow.queue_free);
	
	var particle : CPUParticles2D = $trail;
	particle.reparent(get_tree().current_scene);
	get_tree().create_timer(5.0).timeout.connect(particle.queue_free);
	particle.emitting = false;
	
	$StateOverhead.change_state("main", "dead");
	_dead = true;

func toggle_trail(toggle : bool) -> void:
	$trail.emitting = toggle;

func create_puddle() -> void:
	var puddle1 : Sprite2D = Sprite2D.new();
	puddle1.texture = PUDDLE;
	get_tree().current_scene.add_child(puddle1);
	
	puddle1.global_position = global_position;
	puddle1.scale = Vector2(1.5, 1.5);
	puddle1.z_index = -3;
	puddle1.rotation = randf() * TAU;
	
	var puddle2 : Sprite2D = Sprite2D.new();
	puddle2.texture = PUDDLE;
	get_tree().current_scene.add_child(puddle2);
	
	puddle2.global_position = global_position;
	puddle2.scale = Vector2(1.5, 1.5);
	puddle2.z_index = -3;
	puddle2.rotation = randf() * TAU;
	
	var tw : Tween = puddle1.create_tween();
	tw.tween_property(puddle1, "modulate:a", 0.0, 3.0);
	tw.tween_callback(puddle1.queue_free);
	
	tw = puddle2.create_tween();
	tw.tween_property(puddle2, "modulate:a", 0.0, 3.0);
	tw.tween_callback(puddle2.queue_free);

func _on_hit(hitbox: HitBox) -> void:
	_knock_back.set_knock_back(hitbox, _target, _dead);
	$hit_goop.global_rotation = (global_position - _target.global_position).angle();
	$hit_goop.emitting = true;
	
	$hit_towards_part.global_rotation = (_target.global_position - global_position).angle();
	$hit_towards_part.emitting = true;
	
	$hit.play_random();

func _on_player_hit(_hurtbox: HurtBox) -> void:
	if PlayerInfo.player != _target:
		return;
	
	var box : HitBox = $hitbox;
	remove_child(box);
	get_tree().create_timer(attack_speed).timeout.connect(add_child.bind(box));
