extends Node2D

const MAX_RADUS : float = 20.0;

@onready var image : Line2D = $Lazor;
@onready var hurt_box_shape: CapsuleShape2D = $Hit_Box_Lazor/CollisionShape2D.shape;

@onready var lazor_beam_part: GPUParticles2D = $lazor_beam_part;

var lazor_tween : Tween;

signal action_finished;

func _ready() -> void:
	image.width = 0;
	hurt_box_shape.radius = 0.0;
	
	await get_parent().ready;
	if get_parent().right:
		scale.x *= -1;
	
	$Hit_Box_Lazor.toggle_hitbox(false);

func activate_lazor(time : float) -> void:
	if lazor_tween:
		lazor_tween.kill();
	lazor_tween = create_tween().set_parallel();
	
	lazor_tween.tween_property(image, "width", MAX_RADUS * 2, time);
	lazor_tween.tween_property(hurt_box_shape, "radius", MAX_RADUS, time);
	lazor_tween.chain().tween_callback(action_finished_emit);
	
	$Hit_Box_Lazor.toggle_hitbox(true);
	
	lazor_beam_part.emitting = true;

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
