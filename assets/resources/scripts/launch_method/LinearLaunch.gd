class_name LinearLaunch extends Resource

@export var protectile : PackedScene;
@export var speed : float;
@export var range : float;

func fire_protectile(parent : Node, from : Vector2, angle : float, rotate : bool) -> Projectile:
	var pro : Projectile = protectile.instantiate();
	parent.add_child(pro);
	pro.global_position = from;
	
	var tween : Tween = parent.create_tween();
	tween.tween_property(pro, "global_position", from + (Vector2(cos(angle), sin(angle)) * range), range / speed);
	tween.tween_callback(pro.on_dissipate);
	pro._movement = tween;
	
	if rotate:
		pro.global_rotation = angle;
	
	return pro;
