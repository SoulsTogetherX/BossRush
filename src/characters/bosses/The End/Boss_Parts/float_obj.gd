@tool
extends FloatObjectControl

func set_outline(out : float) -> void:
	material.set_shader_parameter("width", out);
	$Hallo.material.set_shader_parameter("width", out);
func set_white_out(out : float) -> void:
	material.set_shader_parameter("white_out", out);
	$Hallo.material.set_shader_parameter("white_out", out);

func move_all_compoents(diff : Vector2) -> void:
	position += diff;
	$Hallo.position += diff;

func get_hallo() -> FloatObjectControl:
	return $Hallo;
