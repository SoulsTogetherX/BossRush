extends PanelContainer

var _reward : Exchangable;

func set_reward(exchange : Exchangable) -> void:
	_reward = exchange;
	
	$VBoxContainer/MarginContainer/title.text = exchange.name;
	$VBoxContainer/MarginContainer2/description.text = exchange.description;

