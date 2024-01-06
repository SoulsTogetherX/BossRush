class_name HealthExchangable extends Exchangable

@export var max_health : int = 15;

func _on_damage(amount : int, actor : ExchangeType) -> void:
	prints("ow!", actor, "taken", amount," damage!");
