extends Projectile

@onready var glow: Sprite2D = $glow

func change_glow() -> void:
	glow.scale = Vector2(10.0, 10.0) * (1.2 - (randf() * 0.4));
