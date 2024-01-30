extends Control

const MAIN_SCENE : PackedScene = preload("res://rooms/main_menu/pages/main_screen.tscn");
const SETTINGS_SCENE : PackedScene = preload("res://rooms/main_menu/pages/settings.tscn");
const CREDITS_SCENE : PackedScene = preload("res://rooms/main_menu/pages/credits.tscn");

const GAME_SCENE_PATH : String = "res://rooms/rooms/Walk way/In-between.tscn";

var game_scene : PackedScene;
var _current_scene : Control;

func _ready() -> void:
	ResourceLoader.load_threaded_request(GAME_SCENE_PATH);
	
	_current_scene = MAIN_SCENE.instantiate();
	add_child(_current_scene);
	
	_current_scene.play.connect(on_play);
	_current_scene.settings.connect(on_settings);
	_current_scene.credits.connect(on_credits);
	
	$fireplace.volume_db = -40;
	$Music.volume_db = -40;
	
	$fireplace.play();
	$Music.play();
	
	var tw : Tween = create_tween().set_parallel();
	tw.set_trans(Tween.TRANS_QUART);
	tw.tween_property($Music, "volume_db", 0, 4.0).set_delay(0.2);
	tw.tween_property($fireplace, "volume_db", 10, 0.5).set_delay(0.2);

func on_play() -> void:
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(GAME_SCENE_PATH));

func on_main() -> void:
	_current_scene.queue_free();
	_current_scene = MAIN_SCENE.instantiate();
	add_child(_current_scene);
	
	_current_scene.play.connect(on_play);
	_current_scene.settings.connect(on_settings);
	_current_scene.credits.connect(on_credits);

func on_settings() -> void:
	_current_scene.queue_free();
	_current_scene = SETTINGS_SCENE.instantiate();
	add_child(_current_scene);
	
	_current_scene.main.connect(on_main);

func on_credits() -> void:
	_current_scene.queue_free();
	_current_scene = CREDITS_SCENE.instantiate();
	add_child(_current_scene);
	
	_current_scene.main.connect(on_main);
