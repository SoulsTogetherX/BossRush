extends CanvasLayer

signal intro_start_finished;
signal intro_finished;

func start_intro() -> void:
	$ColorRect.visible = true;
	PlayerInfo.force_idle = true;
	
	if !$AnimationPlayer.is_node_ready():
		await $AnimationPlayer.ready;
	
	$AnimationPlayer.play("start");
	$AnimationPlayer.animation_finished.connect(finish_start_intro, CONNECT_ONE_SHOT);

func finish_start_intro(_anim_name: StringName) -> void:
	PlayerInfo.force_idle = false;
	intro_start_finished.emit();
	
	$Timer.timeout.connect(finish_end_intro, CONNECT_ONE_SHOT);
	$Timer.start();

func finish_end_intro(_anim_name: StringName = "") -> void:
	PlayerInfo.force_idle = false;
	
	$AnimationPlayer.play("end");
	$AnimationPlayer.animation_finished.connect(finish_intro, CONNECT_ONE_SHOT);

func finish_intro(_anim_name: StringName = "") -> void:
	intro_finished.emit();

func _input(event: InputEvent) -> void:
	if !(event is InputEventMouse) && !$Timer.is_stopped():
		$Timer.stop();
		$AnimationPlayer.play("end");
		finish_intro("");
