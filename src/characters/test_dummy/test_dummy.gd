extends ExchangeType

func _on_health_monitor_killed() -> void:
	queue_free();
