class_name HitBox extends Area2D

@export var amount : int = -1;

func _init() -> void:
	collision_layer = 2;
	collision_mask = 0;

func set_amount(amount : int) -> void:
	self.amount = amount;

func toggle_hitbox(toggle : bool) -> void:
	monitorable = toggle;
