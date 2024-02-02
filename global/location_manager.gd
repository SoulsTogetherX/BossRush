extends Node

# String -> Location
var _locations : Dictionary = {};

signal room_ready;

var _last_scene : String = "res://rooms/test_room/test_room.tscn";
var _death_scene : PackedScene = preload("res://rooms/death_screen/DeathScreen.tscn");
var _last_id : String = "1";
var _last_health : int = 4;
var _step_type : int = 0;

func step_type(type : int) -> void:
	_step_type = type;

func get_step_type() -> int:
	return _step_type;

func _enter_tree() -> void:
	await room_ready;
	PlayerInfo.assign_player_moves();

func _ready() -> void:
	for loc in _locations:
		loc.monitoring = true;
	process_mode = Node.PROCESS_MODE_ALWAYS;

func add_location(location : Location) -> void:
	_locations[location.get_id()] = location;

func died_switch() -> void:
	PlayerInfo.player = null;
	get_tree().paused = true;
	get_tree().call_deferred("change_scene_to_packed", _death_scene);
	await room_ready;
	get_tree().paused = false;

func reload() -> void:
	request_transfer(_last_scene, _last_id);

func request_transfer(scene : String, id : String) -> void:
	_last_scene = scene;
	_last_id = id;
	
	var saved_health : int;
	if PlayerInfo.player:
		saved_health = PlayerInfo.player.get_health();
		if saved_health == 0:
			saved_health = _last_health;
		else:
			_last_health = saved_health;
	else:
		saved_health = _last_health
	
	ResourceLoader.load_threaded_request(scene);
	
	TransitionManager.fade_in();
	get_tree().paused = true;
	
	await TransitionManager.load_transition;
	
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene));
	
	await room_ready;
	
	_position_player(id, PlayerInfo.player);
	PlayerInfo.assign_player_moves();
	PlayerInfo.cam.port_onto();
	get_tree().paused = false;
	
	TransitionManager.fade_out();
	
	PlayerInfo.player.set_health(saved_health);
	PlayerInfo.health_update();

func _position_player(id : String, player : Player) -> void:
	var loc : Location = _locations[id];
	player.global_position = loc.global_position;
	
	match loc.direction:
		SIDE_RIGHT:
			player.set_direction("idle_", 0);
		SIDE_TOP:
			player.set_direction("idle_", PI / 2);
		SIDE_LEFT:
			player.set_direction("idle_", PI);
		SIDE_BOTTOM:
			player.set_direction("idle_", -(PI / 2));
