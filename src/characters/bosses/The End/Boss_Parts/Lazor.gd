extends Node2D

const MAX_RADUS : float = 20.0;

@onready var image : Line2D = $Lazor;
@onready var hurt_box_shape: CapsuleShape2D = $Hit_Box_Lazor/CollisionShape2D.shape;

@onready var lazor_beam_part: GPUParticles2D = $lazor_beam_part;

const LAZOR_COLORS : Array[Color] = [Color(0.92549020051956, 0.91764706373215, 0), Color(0.92549020051956, 0.16470588743687, 0)];

var lazor_tween : Tween;

signal action_finished;

func _ready() -> void:
	image.width = 0;
	hurt_box_shape.radius = 0.0;
	
	await get_parent().ready;
	if get_parent().right:
		scale.x *= -1;
	
	$Hit_Box_Lazor.toggle_hitbox(false);

func change_color(color : bool = false) -> void:
	$lazor_beam_part.process_material.color = LAZOR_COLORS[int(color)];
	$Charging.process_material.color = LAZOR_COLORS[int(color)];
	$Lazor.default_color = LAZOR_COLORS[int(color)];

func charge(toggle : bool = false) -> void:
	$Charging.emitting = toggle;
	
	if toggle:
		$Pre.play();

func activate_lazor(time : float) -> void:
	if lazor_tween:
		lazor_tween.kill();
	lazor_tween = create_tween().set_parallel();
	
	lazor_tween.tween_property(image, "width", MAX_RADUS * 2, time);
	lazor_tween.tween_property(hurt_box_shape, "radius", MAX_RADUS, time);
	lazor_tween.chain().tween_callback(action_finished_emit);
	
	$Hit_Box_Lazor.toggle_hitbox(true);
	
	lazor_beam_part.emitting = true;
	
	$Pre.stop();
	
	if $Lazor.default_color == LAZOR_COLORS[0]:
		$"Post-Holy".play();
	else:
		$Post.play();

func close_lazor(time : float) -> void:
	if lazor_tween:
		lazor_tween.kill();
	lazor_tween = create_tween().set_parallel();
	
	lazor_tween.tween_property(image, "width", 0.0, time);
	lazor_tween.tween_property(hurt_box_shape, "radius", 0.0, time);
	lazor_tween.chain().tween_callback(action_finished_emit);
	
	$Hit_Box_Lazor.toggle_hitbox(false);
	
	lazor_beam_part.emitting = false;

func action_finished_emit() -> void:
	action_finished.emit();
