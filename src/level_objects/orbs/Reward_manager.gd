extends Node

const BLANK_EXCHANGE : Exchangable = preload("res://assets/resources/instances/exchangable/blank.tres");

@export var orbs : Array[Orb] = [];
var _destroy : Array[Orb] = [];
@export var player : Player;

var radius : Vector2 = Vector2(40, 20);

var _selected : Orb;
var _tween : Tween;
var _angle : float;
var _rot_dir : float;

func _ready() -> void:
	for orb in orbs:
		orb.stage.connect(_stage_orb);
	set_physics_process(false);

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack2"):
		if _selected:
			if _tween:
				_tween.kill();
			
			_selected.disable = false;
			_selected.reset(true, true, true, true);
			_selected = null;
			set_physics_process(false);
			set_process_input(false);

func _stage_orb(orb : Orb) -> void:
	if _selected:
		_selected.disable = false;
		_selected.reset(true, true, true, true);
	orb.disable = true;
	_selected = orb;
	_selected.reset(false, false, true, true);
	
	if _tween:
		_tween.kill();
	_tween = create_tween();
	_tween.set_ease(Tween.EASE_OUT);
	_tween.set_trans(Tween.TRANS_SINE)
	
	_tween.tween_property(_selected, "scale", Vector2(0.6, 0.6), 0.3);
	_tween.tween_method(_approch_staged_orb.bind(_selected.position), 0.0, 1.0, 0.6);
	_tween.tween_callback(set_physics_process.bind(true));
	_tween.tween_callback(set_physics_process.bind(true));
	_selected.toggle_flow_particles(false);
	set_physics_process(false);
	set_process_input(true);

func _destroy_orb(orb : Orb) -> void:
	pass;

func _orbit_staged_orb() -> void:
	_selected.position = _selected.position.lerp(player.position + (Vector2(cos(_angle), sin(_angle)) * radius), 0.1);

func _approch_staged_orb(interval : float, start : Vector2) -> void:
	var goto = MathFunctions.trangent_points_on_ellipse(start, player.position, radius)[1];
	_angle = player.position.angle_to(_selected.position);
	_selected.position = _selected.position.lerp(start.lerp(goto, interval), 0.1);

func _physics_process(delta: float) -> void:
	_orbit_staged_orb();
	_angle += 0.05;
	if _selected.position.y < player.position.y:
		_selected.z_index = -1;
	else:
		_selected.z_index = 1;

func spawn_options() -> void:
	for orbs in _destroy:
		orbs.queue_free();
	_destroy.clear();
	
	var exchange : Exchangable = _selected.exchange;
	var exchanges : Array[Exchangable];
	if exchange is AttackExchangable:
		exchanges = player.get_exchange("attack");
	elif exchange is MovementExchangable:
		exchanges = player.get_exchange("movement");
	else:
		exchanges = player.get_exchange("health");
	
	
