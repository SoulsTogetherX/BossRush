class_name FourWayAttack extends AttackRange

@export var spawn_delay : float;
@export var ring_count : int = 1;
@export var projectiles : int = 4;

var timers : Array[SceneTreeTimer];

func reset() -> void:
	super();
	clear_timers();

func clear_timers() -> void:
	for timer in timers:
		if is_instance_valid(timer) && timer:
			timer.timeout.disconnect(four_fire);
	timers.clear();

func _on_attack(from : Node2D, target : Vector2, alignment : HurtBox.ALIGNMENT) -> void:
	if ring_count <= 0 || projectiles <= 0:
		return;
	clear_timers();
	
	var angle : float = (target - from.get_center()).angle();
	var angle_offset : float = (0.0 if (projectiles == 1) else (PI / projectiles));
	
	if spawn_delay > 0:
		var delay : float = 0;
		for idx in ring_count:
			timers.append(from.get_tree().create_timer(delay));
			timers.back().timeout.connect(four_fire.bind(from.get_tree().current_scene, from.get_center(), angle, alignment));
			delay += spawn_delay;
			angle += angle_offset;
	else:
		four_fire(from.get_tree().current_scene, from.get_center(), angle, alignment);
		if ring_count > 1:
			four_fire(from.get_tree().current_scene, from.get_center(), angle + offset, alignment);

func four_fire(parent : Node2D, pos : Vector2, angle : float, alignment : HurtBox.ALIGNMENT) -> void:
	var angle_offset : float = 0.0 if projectiles <= 0 else TAU / projectiles;
	for idx in projectiles:
		var pro := launch.fire_protectile(parent, pos, offset, angle, true);
		pro.set_alignment(alignment);
		pro.set_delta(delta);
		pro.activate();
		angle += angle_offset;
