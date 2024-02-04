extends Control

const MAIN_SWITCH = "res://rooms/main_menu/switcher.tscn";

func _ready() -> void:
	ResourceLoader.load_threaded_request(MAIN_SWITCH);

func switch_to_main() -> void:
	PlayerInfo.flag = false;
	PlayerInfo.force_idle = false;
	PlayerInfo.player = null;
	PlayerInfo.weapon = null;
	LocationManager._last_health = 4;
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(MAIN_SWITCH));
