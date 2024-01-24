@tool
class_name HealthExchangable extends Exchangable

@export var max_health : int = 15:
	set(val):
		max_health = val;
		health = clampi(health, 0, max_health);
var health : int = max_health;
@export var _incincible : Invincibility = null:
	set(val):
		if _incincible:
			_incincible.invincible_start.disconnect(_incincible_on);
			_incincible.invincible_end.disconnect(_incincible_off);
		if val:
			val.invincible_start.connect(_incincible_on);
			val.invincible_end.connect(_incincible_off);
		_incincible = val;

signal toggle_hitable(toggle : bool);

func reset() -> void:
	super();
	if _incincible:
		_incincible.reset();

func _on_damage(amount : int, actor : ExchangeType) -> void:
	health += amount;
	if _incincible:
		_incincible.start(actor.get_tree());

func _incincible_on() -> void:
	toggle_hitable.emit(false);
func _incincible_off() -> void:
	toggle_hitable.emit(true);
