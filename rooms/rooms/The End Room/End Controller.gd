extends Node

const END_GAME_SCENE = "res://rooms/end_screen/End_Screen.tscn";

func _ready() -> void:
	$Hand.scale = Vector2.ZERO;
	$Hand.rotation_degrees = -150; 

func play_end() -> void:
	PlayerInfo.force_idle = true;
	
	var hand : Node2D = $Hand;
	hand.global_position = PlayerInfo.player.global_position;
	
	ResourceLoader.load_threaded_request(END_GAME_SCENE);
	
	$AnimationPlayer.play("End_Slash");
	var tw : Tween = create_tween().set_parallel();
	tw.tween_property(hand, "global_position", PlayerInfo.player.global_position + Vector2(40, 10), 0.2).set_delay(0.3);
	tw.tween_property(hand, "global_position", PlayerInfo.boss.global_position + Vector2(160, -20), 0.8).set_delay(1.5);
	tw.tween_callback($"../TheEnd/TheEnd".focus_camera).set_delay(1.5);
	tw.tween_property(hand, "global_position", PlayerInfo.boss.global_position + Vector2(100, -40), 0.15).set_delay(5.6);
	tw.tween_property(hand, "global_position", PlayerInfo.boss.global_position + Vector2(20, -50), 0.3).set_delay(5.75);
	
	tw.tween_property($ColorRect, "color:a", 1.0, 0.1).set_delay(5.8);
	tw.tween_property(hand, "visible", false, 0.01).set_delay(5.9);
	tw.tween_property($ColorRect, "color:a", 0.0, 1.5).set_delay(6.2);
	
	tw.chain().tween_interval(5.0);
	tw.chain().tween_property($ColorRect, "color", Color(0.0, 0.0, 0.0, 0.0), 0.001);
	tw.chain().tween_property($ColorRect, "color:a", 1.0, 6.0);
	tw.chain().tween_callback(get_tree().change_scene_to_packed.bind(ResourceLoader.load_threaded_get(END_GAME_SCENE)));
