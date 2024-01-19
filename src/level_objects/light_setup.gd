extends PointLight2D

func _ready() -> void:
	editor_only = !PlayerInfo.lights_on;
