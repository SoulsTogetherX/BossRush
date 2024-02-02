extends Node2D

@export var wave_time : float = 1.0;
@export var fade_time : float = 0.1;
@export var radius : float = 1.0;
@export var width : float = 10.0;

@export var alignment : HurtBox.ALIGNMENT;
@export var amount : int = -1;

@onready var _shape : CircleShape2D = $hit_box/CollisionShape2D.shape;

var _curr_radius : float = 0.0;
var _wave_speed : float = 0.0;

func _ready() -> void:
	_wave_speed = radius / wave_time;
	get_tree().create_timer(wave_time - fade_time).timeout.connect(fade_start);
	
	$hit_box.alignment = alignment;
	$hit_box.amount = amount;
func _draw() -> void:
	draw_arc(Vector2.ZERO, _curr_radius, 0, TAU, 100, Color.WHITE * modulate, width);
func _physics_process(delta: float) -> void:
	_curr_radius += _wave_speed * delta;
	queue_redraw();
	
	var rad : float = _curr_radius + width;
	$hit_box.toggle_hitbox(PlayerInfo.player.global_position.distance_squared_to(global_position) > rad * rad);
	_shape.radius = rad;

func fade_start() -> void:
	var tw : Tween = create_tween();
	tw.tween_property(self, "modulate:a", 0.0, fade_time);
	tw.tween_callback(queue_free);
