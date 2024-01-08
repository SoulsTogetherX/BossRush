@tool
extends CameraFollow2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return;
	
	PlayerInfo.cam = self;
