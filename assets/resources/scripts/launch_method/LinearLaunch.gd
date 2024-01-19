class_name LinearLaunch extends Resource

@export var protectile : PackedScene;
@export var fire_range : float;
@export var speed : float;
@export var fade_after : float = -1;
@export var fade_before : float = -1;

func fire_protectile(parent : Node, from : Vector2, offset : float, angle : float, rotate : bool) -> Projectile:
	var pro : Projectile = protectile.instantiate();
	parent.add_child(pro);
	pro.global_position = from + (Vector2(cos(angle), sin(angle)) * offset);
	var tween : Tween = parent.create_tween().set_parallel();
	var end_pos : Vector2 = from + (Vector2(cos(angle), sin(angle)) * fire_range);
	var time : float = fire_range / speed;
	tween.tween_property(pro, "global_position", end_pos, time);
	if fade_before >= 0:
		if fade_after >= 0:
			fade_before = min(fade_before, fade_after);
		pro.modulate.a = 0.0;
		tween.tween_property(pro, "modulate:a", 1.0, (fade_before / speed));
	if fade_after >= 0:
		var delay_time : float = (fire_range - fade_after) / speed;
		tween.tween_property(pro, "modulate:a", 0.0, time - delay_time).set_delay(delay_time);
	tween.tween_callback(pro.on_dissipate).set_delay(time);
	pro._movement = tween;
	
	if rotate:
		pro.global_rotation = angle;
	if end_pos.y > from.y:
		pro.z_index = 1;
	
	return pro;
