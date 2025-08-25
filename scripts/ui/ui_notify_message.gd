extends PanelContainer

@onready var label: Label = $MarginContainer/HBoxContainer/Label

var tween: Tween
var fade_int:float = 0.5
var message_duration:float = 2.0
var fade_out:float = 0.5

func _ready() -> void:
	modulate.a = 0
	#pass

func show_notification(msg:String, _duration: float = 2.0):
	label.text = msg
	modulate.a = 0
	 # Create a new Tween
	if tween:
		tween.kill()  # Stop any existing tween
	tween = create_tween()
	# Fade in animation
	tween.tween_property(self, "modulate:a", 1.0, fade_int).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	await get_tree().create_timer(message_duration).timeout
	tween = create_tween()
	# Fade out animation
	tween.tween_property(self, "modulate:a", 0.0, fade_out).set_ease(Tween.EASE_IN_OUT)
	await tween.finished # This pauses execution until the tween is done
	remove_notify()

func remove_notify()->void:
	#print("queue_free notify")
	queue_free()
	#pass

func _on_btn_close_pressed() -> void:
	remove_notify()
	#pass
