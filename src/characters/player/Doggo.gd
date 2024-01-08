class_name Player extends ExchangeType

@onready var _state_overhead: StateOverhead = $StateOverhead;

func _ready() -> void:
	super();
	PlayerInfo.player = self;

func set_up_weapon() -> void:
	primary_attack._set_up_sprite(self, 30);

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack1"):
		if primary_attack:
			primary_attack.handle_attack(get_local_mouse_position());
	elif event.is_action_pressed("attack2"):
		if secondary_attack:
			secondary_attack.handle_attack(get_local_mouse_position());

func get_input() -> Vector2:
	return Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized();

func get_weapon_info() -> Array[float]:
	return [get_local_mouse_position().angle(), global_position.distance_to(get_global_mouse_position())];
