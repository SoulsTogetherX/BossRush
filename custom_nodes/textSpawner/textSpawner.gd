class_name TextSpawner extends RefCounted

var _settings : LabelSettings;

func _init(settings : LabelSettings) -> void:
	_settings = settings;

func spawn(tree : SceneTree, global_pos : Vector2, text : String, _scale : float = 1., z_set = 2, _color : Color = Color.WHITE, w : float = 50, h_1 : float = -10, h_2 : float = -5) -> TextSpawner:
	var rotation_point : Node2D = Node2D.new();
	var label : Label = Label.new();
	label.z_index = z_set;
	label.label_settings = _settings;
	label.text = text;
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
	
	tree.current_scene.add_child(rotation_point);
	rotation_point.add_child(label);
	
	rotation_point.global_position = global_pos;
	rotation_point.global_position += Vector2((randf() - 0.5), (randf() - 0.5)) * 20;
	label.position = -_settings.font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, _settings.font_size) * 0.5;;
	
	var tw = tree.create_tween().set_parallel();
	var x_reach : float = (randf() - 0.5) * w;
	tw.tween_property(rotation_point, "global_position", Vector2(x_reach * 0.5, h_1) + global_pos, 0.3);
	tw.tween_property(rotation_point, "global_position", Vector2(x_reach, h_2) + global_pos, 0.3).set_delay(0.3);
	tw.tween_property(rotation_point, "modulate:a", 0, 0.4).set_delay(0.2);
	tw.tween_property(rotation_point, "scale", Vector2(1.1, 1.1), 0.2);
	tw.tween_property(rotation_point, "scale", Vector2(0.9, 0.9), 0.4).set_delay(0.2);
	tw.tween_property(rotation_point, "rotation_degrees", (randf() - 0.5) * 20, 0.4);
	tw.tween_callback(rotation_point.queue_free).set_delay(0.6);
	
	return self;
