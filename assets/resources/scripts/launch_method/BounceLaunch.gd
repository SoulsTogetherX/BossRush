class_name BounceLaunch extends VelocityLaunch

@export var max_bounces : int = 0;

func fire_protectile(parent : Node, from : Vector2, offset : float, angle : float, rotate : bool) -> Projectile:
	var pro : Projectile = super(parent, from, offset, angle, rotate);
	pro.bounces = max_bounces;
	
	return pro;
