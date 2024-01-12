class_name LinearLaunch extends Resource

@export var protectile : PackedScene;
@export var fire_range : float;
@export var speed : float;

func fire_protectile(parent : Node, from : Vector2, angle : float, rotate : bool) -> Projectile:
	var pro : Projectile = protectile.instantiate();
	parent.add_child(pro);
	pro.global_position = from;
	
	var tween : Tween = parent.create_tween();
	var end_pos : Vector2 = from + (Vector2(cos(angle), sin(angle)) * fire_range);
	tween.tween_property(pro, "global_position", end_pos, fire_range / speed);
	tween.tween_callback(pro.on_dissipate);
	pro._movement = tween;
	
	if rotate:
		pro.global_rotation = angle;
	if end_pos.y > from.y:
		pro.z_index = 1;
	
	return pro;
