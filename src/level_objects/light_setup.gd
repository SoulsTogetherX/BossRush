extends PointLight2D

func _ready() -> void:
	visible = PlayerInfo.lights_on;
	PlayerInfo.lights_set.connect(set_lights);

func set_lights(light : bool) -> void:
	visible = light;
