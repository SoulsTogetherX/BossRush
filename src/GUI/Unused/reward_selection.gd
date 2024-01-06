extends Control

const OPTION_CARD : PackedScene = preload("res://src/GUI/Reward/option_card.tscn");

@onready var option_list: HBoxContainer = $VBoxContainer/CenterContainer/MarginContainer/OptionList;

func add_reward(exchange : Exchangable) -> void:
	var option : PanelContainer = OPTION_CARD.instantiate();
	option.set_reward(exchange);
	option_list.add_child(option);
