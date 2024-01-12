extends Control

const MAIN_SCENE : PackedScene = preload("res://rooms/main_menu/pages/main_screen.tscn");
const SETTINGS_SCENE : PackedScene = preload("res://rooms/main_menu/pages/settings.tscn");
const CREDITS_SCENE : PackedScene = preload("res://rooms/main_menu/pages/credits.tscn");

const GAME_SCENE_PATH : String ="res://rooms/test_room/test_room.tscn";

var game_scene : PackedScene;

func _ready() -> void:
	ResourceLoader.load_threaded_request(GAME_SCENE_PATH);
	
	var scene : Control = MAIN_SCENE.instantiate();
	add_child(scene);
	
	scene.play.connect(on_play);
	scene.settings.connect(on_settings);
	scene.credits.connect(on_credits);

func on_play() -> void:
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(GAME_SCENE_PATH));

func on_main() -> void:
	get_child(0).queue_free();
	var scene : Control = MAIN_SCENE.instantiate();
	add_child(scene);
	
	scene.play.connect(on_play);
	scene.settings.connect(on_settings);
	scene.credits.connect(on_credits);

func on_settings() -> void:
	get_child(0).queue_free();
	var scene : Control = SETTINGS_SCENE.instantiate();
	add_child(scene);
	
	scene.main.connect(on_main);

func on_credits() -> void:
	get_child(0).queue_free();
	var scene : Control = CREDITS_SCENE.instantiate();
	add_child(scene);
	
	scene.main.connect(on_main);
