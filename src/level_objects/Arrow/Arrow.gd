@tool
extends Node2D

@onready var sprite: Sprite2D = $Sprite;

@export var follow : Node2D;
@export var offset : Vector2;
@export var auto_start : bool = false;

func _ready() -> void:
	if Engine.is_editor_hint() || !auto_start:
		set_process(false);

func toggle_arrow(toggle : bool) -> void:
	set_process(toggle);

func _process(_delta: float) -> void:
	point_to(PlayerInfo.player.global_position, (follow.global_position + offset), 40, 10);

func point_to(src : Vector2, dst : Vector2, inner : float, pad : float) -> void:
	var viewport_rect : Rect2 = get_viewport_rect() * get_viewport_transform();
	var delta_cords : Vector2 = dst - src;
	var vl : float = delta_cords.length();	
	var vector_coords : Vector2 = delta_cords / vl if (vl != 0) else Vector2.ZERO;
	
	if (vl > inner * 2):
		vl -= inner;
		modulate.a = 1;
	else:
		modulate.a = max(0, (vl - inner) / inner);
		vl /= 2;
	
	if (vector_coords.y < 0):
		vl = min(vl, ((viewport_rect.position.y + pad) - src.y) / vector_coords.y);
	elif (vector_coords.y > 0):
		vl = min(vl, ((viewport_rect.end.y - pad) - src.y) / vector_coords.y);
	
	if (vector_coords.x < 0):
		vl = min(vl, ((viewport_rect.position.x + pad) - src.x) / vector_coords.x);
	elif (vector_coords.x > 0):
		vl = min(vl, ((viewport_rect.end.x - pad) - src.x) / vector_coords.x);
	
	global_position = src + (vector_coords * vl);
	global_rotation = src.angle_to_point(dst);
