extends HBoxContainer

@onready var user: Label = $User
@onready var message: Label = $Message

func set_message(_name,_message):
	user.text = _name
	message.text = _message
	#pass
