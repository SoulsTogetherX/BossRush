extends CanvasLayer

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
			get_tree().paused = false;
			$PlayerGUI/GameGUI.visible = true;
			$PlayerGUI/PauseScreen.visible = false;
			$PlayerGUI/blur.material.set_shader_parameter("amount", 0.0);
			$PlayerGUI/blur.material.set_shader_parameter("darken", 1.0);
			$PlayerGUI/darken.visible = false;
		else:
			get_tree().paused = true;
			$PlayerGUI/GameGUI.visible = false;
			$PlayerGUI/PauseScreen.visible = true;
			$PlayerGUI/blur.material.set_shader_parameter("amount", 1.5);
			$PlayerGUI/blur.material.set_shader_parameter("darken", 0.2);
			$PlayerGUI/darken.visible = true;

func update_max_health(amount : int) -> void:
	_health_display.set_max_health(amount);
func update_health(amount : int) -> void:
	_health_display.set_health(amount);

