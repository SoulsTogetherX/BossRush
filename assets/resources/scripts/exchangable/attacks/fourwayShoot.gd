class_name FourWayAttack extends AttackRange

var timer1 : SceneTreeTimer = null;
var timer2 : SceneTreeTimer = null;

func reset() -> void:
	super();
	if is_instance_valid(timer1) && timer1:
		timer1.timeout.disconnect(four_fire);
	if is_instance_valid(timer2) && timer2:
		timer2.timeout.disconnect(four_fire);
	
	timer1 = null;
	timer2 = null;

func _on_attack(from : Node2D, target : Vector2, alignment : HurtBox.ALIGNMENT) -> void:
	var angle : float = (target - from.global_position).angle();
	four_fire(from.get_tree().current_scene, from.global_position, angle, alignment);
	
	timer1 = from.get_tree().create_timer(0.4);
	timer1.timeout.connect(four_fire.bind(from.get_tree().current_scene, from.global_position, angle + (PI / 4), alignment));
	
	timer2 = from.get_tree().create_timer(0.8);
	timer2.timeout.connect(four_fire.bind(from.get_tree().current_scene, from.global_position, angle, alignment));

func four_fire(parent : Node2D, pos : Vector2, angle : float, alignment : HurtBox.ALIGNMENT) -> void:
	var pro := launch.fire_protectile(parent, pos, angle, true);
	pro.set_alignment(alignment);
	pro.set_delta(delta);
	
	pro = launch.fire_protectile(parent, pos, angle + PI, true);
	pro.set_alignment(alignment);
	pro.set_delta(delta);
	
	pro = launch.fire_protectile(parent, pos, angle + (PI/2), true);
	pro.set_alignment(alignment);
	pro.set_delta(delta);
	
	pro = launch.fire_protectile(parent, pos, angle - (PI/2), true);
	pro.set_alignment(alignment);
	pro.set_delta(delta);
