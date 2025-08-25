
extends Control

const UI_NOTIFY_MESSAGE = preload("res://scenes/ui/ui_notify_message.tscn")
@onready var vbc_messages: VBoxContainer = $"."

func _ready() -> void:
	clear_messages()
	#pass

func clear_messages()->void:
	for message in vbc_messages.get_children():
		message.queue_free()
		
func add_message(_msg:String, _status:int = 0)->void:
	var message = UI_NOTIFY_MESSAGE.instantiate()
	vbc_messages.add_child(message)
	message.show_notification(_msg)
	#pass
