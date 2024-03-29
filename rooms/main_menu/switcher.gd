extends Control

const MAIN_SCENE : PackedScene = preload("res://rooms/main_menu/pages/main_screen.tscn");
const SETTINGS_SCENE : PackedScene = preload("res://rooms/main_menu/pages/settings.tscn");
const CREDITS_SCENE : PackedScene = preload("res://rooms/main_menu/pages/credits.tscn");

const GAME_SCENE_PATH : String = "res://rooms/rooms/Walk way/In-between.tscn";

var _current_scene : Control;

func _ready() -> void:
	_current_scene = MAIN_SCENE.instantiate();
	add_child(_current_scene);
	
	_current_scene.play.connect(on_play);
	_current_scene.settings.connect(on_settings);
	_current_scene.credits.connect(on_credits);
	_current_scene.quit.connect(on_quit);
	
	$fireplace.volume_db = -40;
	
	$fireplace.play();
	$Music.play();
	
	var tw : Tween = create_tween().set_parallel();
	tw.set_trans(Tween.TRANS_EXPO);
	tw.tween_property($fireplace, "volume_db", 10, 0.5);

func on_play() -> void:
	$Start.play();
	
	await get_tree().create_timer(1.0).timeout;
	$Background.paused = true;
	
	$Background.stop();
	LocationManager.request_transfer(GAME_SCENE_PATH, "0");

func on_main() -> void:
	_current_scene.queue_free();
	_current_scene = MAIN_SCENE.instantiate();
	add_child(_current_scene);
	
	_current_scene.play.connect(on_play);
	_current_scene.settings.connect(on_settings);
	_current_scene.credits.connect(on_credits);
	_current_scene.quit.connect(on_quit);
	
	$"De-confrim".play();

func on_settings() -> void:
	_current_scene.queue_free();
	_current_scene = SETTINGS_SCENE.instantiate();
	add_child(_current_scene);
	
	_current_scene.main.connect(on_main);
	
	$Confrim.play_random();

func on_credits() -> void:
	_current_scene.queue_free();
	_current_scene = CREDITS_SCENE.instantiate();
	add_child(_current_scene);
	
	_current_scene.main.connect(on_main);
	
	$Confrim.play_random();

func on_quit() -> void:
	$Confrim.play_random();
	await get_tree().create_timer(0.6).timeout;
	get_tree().quit();
