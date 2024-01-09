extends Area2D

@onready var _hurt_box: HurtBox = $"../hurt_box";

func damage(amount : int, align : HurtBox.ALIGNMENT) -> bool:
	return _hurt_box._hit_check(align, amount);
