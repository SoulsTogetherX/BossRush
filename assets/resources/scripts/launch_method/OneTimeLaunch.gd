class_name OneTimeLaunch extends Resource

@export var protectile : PackedScene;
@export var range : float;

func fire_protectile(parent : Node, from : Vector2, _angle : float, rotate : bool) -> OneTimeHit:
	var pro : OneTimeHit = protectile.instantiate();
	parent.add_child(pro);
	pro.set_radius(range);
	pro.global_position = from;
	
	return pro;
