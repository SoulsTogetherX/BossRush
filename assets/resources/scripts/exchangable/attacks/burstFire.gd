class_name BurstAttack extends AttackRange

@export var spawn_delay : float;
@export var projectiles : int = 4;
@export var aimable : bool = false;

var timers : Array[SceneTreeTimer];

func reset() -> void:
	super();
	clear_timers();

func clear_timers() -> void:
	for timer in timers:
		if is_instance_valid(timer) && timer:
			timer.timeout.disconnect(fire_projectile);
	timers.clear();

func _on_attack(from : Node2D, target : Vector2, alignment : HurtBox.ALIGNMENT) -> void:
	if projectiles <= 0:
		return;
	clear_timers();
	
	if spawn_delay > 0:
		if aimable:
			timers.append(from.get_tree().create_timer(spawn_delay));
			
			for idx in projectiles:
				fire_projectile(from.get_tree().current_scene, from.get_center(), (from.get_global_mouse_position() - from.get_center()).angle(), alignment);
				await timers[0].timeout;
				timers[0] = from.get_tree().create_timer(spawn_delay);
		else:
			var angle : float = (target - from.get_center()).angle();
			var delay : float = 0;
			for idx in projectiles:
				timers.append(from.get_tree().create_timer(delay));
				timers.back().timeout.connect(fire_projectile.bind(from.get_tree().current_scene, from.get_center(), angle, alignment));
				delay += spawn_delay;
	else:
		var angle : float = (target - from.get_center()).angle();
		fire_projectile(from.get_tree().current_scene, from.get_center(), angle, alignment);

func fire_projectile(parent : Node2D, pos : Vector2, angle : float, alignment : HurtBox.ALIGNMENT) -> void:
	var pro := launch.fire_protectile(parent, pos, offset, angle, true);
	pro.set_alignment(alignment);
	pro.set_delta(delta);
	pro.activate();
