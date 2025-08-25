extends CenterContainer

@onready var ui_multiplayer: CenterContainer = $"."
@onready var label_name: Label = $"../DebugList/HBC_Player/Label_Name"

@onready var hbc_peer_id: HBoxContainer = $"../DebugList/HBC_PeerID"
@onready var hbc_network_status: HBoxContainer = $"../DebugList/HBC_NetworkStatus"

@onready var line_edit_player: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/LineEdit_Player
@onready var ui_player_spawn: CenterContainer = $"../UIPlayerSpawn"
@onready var label_player_name: Label = $"../UIPlayerSpawn/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Label_player_name"

func _ready() -> void:
	line_edit_player.text = Global.generate_random_name()
	ui_player_spawn.hide()
	pass

#func _process(delta: float) -> void:
	#pass

func _on_btn_exit_pressed() -> void:
	
	pass

func _on_btn_settings_pressed() -> void:
	
	pass 

func _on_btn_join_pressed() -> void:
	GameNetwork.player_info["name"] = line_edit_player.text
	label_name.text = line_edit_player.text
	label_player_name.text = line_edit_player.text
	GameNetwork._network_join()
	ui_multiplayer.hide()
	ui_player_spawn.show()
	#pass

func _on_btn_host_pressed() -> void:
	GameNetwork.player_info["name"] = line_edit_player.text
	label_player_name.text = line_edit_player.text
	label_name.text = line_edit_player.text
	GameNetwork._network_host()
	ui_multiplayer.hide()
	ui_player_spawn.show()
	#pass 
