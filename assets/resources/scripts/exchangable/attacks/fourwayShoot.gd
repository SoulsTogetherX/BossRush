class_name FourWayAttack extends AttackRange

@export var spawn_delay : float;
@export var ring_count : int = 1;

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
	if ring_count <= 0:
		return;
	
	var angle : float = (target - from.get_center()).angle();
	
	if spawn_delay > 0:
		var delay : float = 0;
		for idx in ring_count:
			timers.append(from.get_tree().create_timer(delay));
			timers.back().timeout.connect(four_fire.bind(from.get_tree().current_scene, from.get_center(), angle + ((PI / 4) * float(idx & 1)), alignment));
			delay += spawn_delay;
	else:
		four_fire(from.get_tree().current_scene, from.get_center(), angle, alignment);
		if ring_count > 1:
			four_fire(from.get_tree().current_scene, from.get_center(), angle + (PI / 4), alignment);

func four_fire(parent : Node2D, pos : Vector2, angle : float, alignment : HurtBox.ALIGNMENT) -> void:
	var pro := launch.fire_protectile(parent, pos, angle, true);
	pro.set_alignment(alignment);
	pro.set_delta(delta);
	pro.activate();
	
	pro = launch.fire_protectile(parent, pos, angle + PI, true);
	pro.set_alignment(alignment);
	pro.set_delta(delta);
	pro.activate();
	
	pro = launch.fire_protectile(parent, pos, angle + (PI/2), true);
	pro.set_alignment(alignment);
	pro.set_delta(delta);
	pro.activate();
	
	pro = launch.fire_protectile(parent, pos, angle - (PI/2), true);
	pro.set_alignment(alignment);
	pro.set_delta(delta);
	pro.activate();
