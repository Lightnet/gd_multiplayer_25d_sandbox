extends Label

func  _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		text = "Mouse Mode: Capture"
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		text = "Mouse Mode: Visible"
	#pass

#func _ready() -> void:
	#pass

#func _process(delta: float) -> void:
	#pass
