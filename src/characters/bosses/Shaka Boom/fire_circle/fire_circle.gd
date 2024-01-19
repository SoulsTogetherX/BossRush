extends Area2D

const FIRE_BALL_SCENE : PackedScene = preload("res://src/weapons/projectiles/Shaka Boom/shaka_fire_circle.tscn");

@export var radius : float = 100;
@export var fire_num : int = 40;

var _fires : Array[Projectile] = [];
var _angles : Array[float] = [];
var _angle_additional : float = 0;
var _releashed : bool = false;

var _alignment : HurtBox.ALIGNMENT = HurtBox.ALIGNMENT.ENEMY;
var _delta_health : int = -1;

func _ready() -> void:
	$CollisionShape2D.shape.radius = radius;
	
	var angle_offset : float = TAU / fire_num;
	for i in fire_num:
		create_fire(i * angle_offset);

func create_fire(angle_offset : float) -> void:
	var fire : Projectile = FIRE_BALL_SCENE.instantiate();
	fire.global_position = global_position + Vector2.RIGHT.rotated(angle_offset) * radius;
	add_child(fire);
	
	fire.set_alignment(_alignment);
	fire.set_delta(_delta_health);
	fire.activate();
	
	_fires.append(fire);
	_angles.append(angle_offset);

func _physics_process(_delta: float) -> void:
	for idx in _angles.size():
		_fires[idx].global_position = global_position + Vector2.RIGHT.rotated(_angles[idx] + _angle_additional) * radius;
	_angle_additional += 0.01;

func releash() -> void:
	if _releashed:
		return;
	_releashed = true;
	var tw : Tween = create_tween().set_parallel();
	for fire in _fires:
		tw.tween_property(fire, "modulate:a", 0.0, 2.0);
	tw.tween_property(self, "radius", radius + 800, 2.0);
	tw.chain().tween_callback(queue_free);

func _on_player_exited(body: Player) -> void:
	if body:
		await get_tree().create_timer(0.5).timeout;
		releash();
