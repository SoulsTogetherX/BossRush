extends Slime_Shaka

func _ready() -> void:
	super();
	PlayerInfo.boss.register_slime(self);
	$hurt_box/CollisionShape2D4.disabled = false;
	$hit_area/CollisionShape2D3.disabled = false;
	$CollisionShape2D2.disabled = false;
