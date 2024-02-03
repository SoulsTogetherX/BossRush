extends CanvasLayer

const MAIN_SWITCH = "res://rooms/main_menu/switcher.tscn";

@onready var _health_display: Control = $PlayerGUI/GameGUI/Bottom/Health_Display

var tween : Tween;

func _ready() -> void:
	PlayerInfo.max_health_changed.connect(update_max_health);
	PlayerInfo.health_changed.connect(update_health);
	
	$PlayerGUI/PauseScreen.visible = false;
	$PlayerGUI/darken.visible = false;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			unpause();
		else:
			pause();

func pause() -> void:
	get_tree().paused = true;
	$PlayerGUI/GameGUI.visible = false;
	$PlayerGUI/PauseScreen.visible = true;
	$PlayerGUI/blur.material.set_shader_parameter("amount", 1.5);
	$PlayerGUI/blur.material.set_shader_parameter("darken", 0.2);
	$PlayerGUI/darken.visible = true;
	
	$PlayerGUI/PauseScreen/MidSection/MainPanel/VBoxContainer/HBoxContainer/CenterContainer/Control/CheckBox.button_pressed = PlayerInfo.lights_on;
	if !PlayerInfo.can_reload:
		$PlayerGUI/PauseScreen/MidSection/MainPanel/VBoxContainer/HBoxContainer/CenterContainer/Control/Control/Restart_Room.self_modulate = Color(0.28485026955605, 0.28485026955605, 0.28485026955605)

func unpause() -> void:
	get_tree().paused = false;
	$PlayerGUI/GameGUI.visible = true;
	$PlayerGUI/PauseScreen.visible = false;
	$PlayerGUI/blur.material.set_shader_parameter("amount", 0.0);
	$PlayerGUI/blur.material.set_shader_parameter("darken", 1.0);
	$PlayerGUI/darken.visible = false;

func update_max_health(amount : int) -> void:
	_health_display.set_max_health(amount);
func update_health(amount : int) -> void:
	_health_display.set_health(amount);

func _lights_toggled(toggled_on: bool) -> void:
	PlayerInfo.lights_on = toggled_on;

func restart_room() -> void:
	if !PlayerInfo.can_reload:
		return;
	
	unpause();
	DeathSounds.slience();
	LocationManager.reload();

func main_menu() -> void:
	unpause();
	PlayerInfo.flag = false;
	PlayerInfo.force_idle = false;
	PlayerInfo.player = null;
	PlayerInfo.weapon = null;
	get_tree().change_scene_to_file(MAIN_SWITCH);
