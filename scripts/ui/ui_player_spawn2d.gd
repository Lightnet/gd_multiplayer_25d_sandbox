extends CenterContainer

@onready var ui_player_spawn: CenterContainer = $"."
@export var spawn_point: Node3D

const DUMMY_PLAYER = preload("res://prefabs/dummy_player/dummy_player.tscn")

#func _ready() -> void:
	#pass

#func _process(delta: float) -> void:
	#pass

func _on_btn_spawn_pressed() -> void:
	request_spawn()
	ui_player_spawn.hide()
	#pass

func request_spawn():
	if multiplayer.is_server():
		spawn.rpc(multiplayer.get_unique_id())
	else:
		remote_spawn.rpc_id(1)
	#pass
	
@rpc("any_peer","call_remote")
func remote_spawn():
	spawn.rpc(multiplayer.get_remote_sender_id())
	#pass
	
@rpc("authority", "call_local")
func spawn(pid: int):
	print("spawn id:", pid)
	var players = get_tree().get_nodes_in_group("player")
	# Check if a player with the given peer ID already exists
	for player in players:
		if player.get_multiplayer_authority() == pid:
			return  # Player already exists, so exit early
	
	# If no player with the peer ID exists, spawn a new one
	var new_player = DUMMY_PLAYER.instantiate()
	new_player.set_multiplayer_authority(pid)  # Set the peer ID as the multiplayer authority
	#new_player.add_to_group("player")  # Add to the player group
	get_tree().current_scene.add_child(new_player)  # Add to the scene tree
	new_player.global_position = spawn_point.global_position
