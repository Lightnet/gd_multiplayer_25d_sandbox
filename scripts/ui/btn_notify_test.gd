extends Button

func _ready() -> void:
	pressed.connect(sent_test)
	#pass

#func _process(delta: float) -> void:
	#pass
	
func sent_test():
	Global.notify_message("test")
	#pass
