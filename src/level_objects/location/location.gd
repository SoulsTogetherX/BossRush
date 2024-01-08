class_name Location extends Area2D

@export var move_to : String;
@export var scene_path : String;
@export var location_id : String;
@export var direction : Side;

func get_id() -> String:
	return location_id;

func _ready() -> void:
	LocationManager.add_location(self);

func request_transfer(body : Player) -> void:
	if body:
		LocationManager.request_transfer(scene_path, move_to);
