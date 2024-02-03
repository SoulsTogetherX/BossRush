extends Control

@onready var texture_rect: TextureRect = $TextureRect;
@onready var sprite_2d: Sprite2D = $Sprite2D;

func _ready() -> void:
	DeathSounds.stop_slience();
	DeathSounds.stop_music();
	set_process_input(false);
	get_tree().create_timer(0.05).timeout.connect(set_process_input.bind(true));
	
	LocationManager.room_ready.emit();
	
	$music.volume_db = -40.0;
	var tw : Tween = create_tween();
	tw.set_trans(Tween.TRANS_QUART);
	tw.tween_property($music, "volume_db", 0.0, 4.0);

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_switch"):
		LocationManager.reload();
