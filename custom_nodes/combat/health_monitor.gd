@tool
class_name HealthMonitor extends Node

signal damage_taken(amount : int);
signal healed(amount : int);
signal killed;
signal revived;

@export var max_health : int = 10:
	set(val):
		max_health = val;
		_health = clampi(_health, 0, max_health);
var _health : int = 10;
var health : int:
	get:
		return _health;
	set(val):
		update_health(val);

var _invincible : bool = false;

func _get_property_list():
	var properties = [];
	
	properties.append({
		"name": "_health",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_STORAGE
	});
	properties.append({
		"name": "health",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_EDITOR,
	});
	
	return properties;

func health_missing() -> int:
	return max_health - health;

func toggle_invincible(toggle : bool) -> void:
	_invincible = toggle;

func update_health_no_signal(val : int) -> void:
	_health = clampi(val, 0, max_health);

func update_health(val : int) -> void:
	val = clampi(val, 0, max_health);
	if val < _health:
		if _invincible:
			return;
		
		if val == 0:
			killed.emit();
		
		var delta = (_health - val);
		_health = val;
		damage_taken.emit(delta);
	elif val > _health:
		if _health == 0:
			revived.emit();
		
		var delta = (val - _health);
		_health = val;
		healed.emit(delta);

func health_change(amount : int) -> void:
	health += amount;
