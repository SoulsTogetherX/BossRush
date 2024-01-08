extends Node

# String -> Location
var _locations : Dictionary = {};

func _enter_tree() -> void:
	await ready; await ready;
	PlayerInfo.player.set_up_weapon();

func _ready() -> void:
	for loc in _locations:
		loc.monitoring = true;

func add_location(location : Location) -> void:
	_locations[location.get_id()] = location;

func request_transfer(scene : String, id : String) -> void:
	TransitionManager.fade_in();
	
	await TransitionManager.load_transition;
	
	get_tree().change_scene_to_file(scene);
	
	await ready;
	
	_position_player(id, PlayerInfo.player);
	PlayerInfo.cam.port_onto();
	
	TransitionManager.fade_out();

func _position_player(id : String, player : Player) -> void:
	var loc : Location = _locations[id];
	player.global_position = loc.global_position;
	
	match loc.direction:
		SIDE_RIGHT:
			player.set_direction("_move", 0);
		SIDE_TOP:
			player.set_direction("_move", PI / 2);
		SIDE_LEFT:
			player.set_direction("_move", PI);
		SIDE_BOTTOM:
			player.set_direction("_move", -(PI / 2));
	
	player.set_up_weapon();
