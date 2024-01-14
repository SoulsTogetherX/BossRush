class_name MovementExchangable extends Exchangable

@export var animation : String;

func enact_move(_delta : float, _actor : ExchangeType, _from : Vector2, _to : Vector2) -> bool:
	return false;
