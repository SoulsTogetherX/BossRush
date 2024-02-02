extends Node2D

@export var _step_type : int = 0;

func _ready() -> void:
	LocationManager.room_ready.emit();
	LocationManager.step_type(_step_type);
	DeathSounds.slience() 
