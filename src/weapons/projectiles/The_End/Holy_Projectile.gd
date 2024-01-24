extends Projectile

func _ready() -> void:
	var tw : Tween = create_tween().set_loops();
	tw.tween_property(self, "rotation", 360, 1.0)
