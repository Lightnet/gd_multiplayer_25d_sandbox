extends Node

# Network configuration
const DEFAULT_IP = "127.0.0.1"  # Localhost for testing
const DEFAULT_PORT = 4242
const MAX_PLAYERS = 32

# Mock user database for demonstration (replace with real auth system)
const USER_DATABASE = {
	"player1": "pass123",
	"player2": "pass456"
}

# Player data storage
var players: Dictionary = {}  # Key: peer_id (int), Value: player_info (Dictionary)
var local_player_id: int = 0  # Local peer ID

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.

# team_id
# ally_id
var player_info = {"name": "Name"}

# Signals for game logic
signal player_connected(peer_id: int, player_info: Dictionary)
signal player_failed_connected
signal player_disconnected(peer_id: int)
signal server_disconnected()

# Signals for login events
signal login_succeeded(peer_id: int, token: String)
signal login_failed(peer_id: int, reason: String)

func _ready() -> void:
	# Connect multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	# Initialize local player ID
	local_player_id = multiplayer.get_unique_id()
	
func _network_host(port: int = DEFAULT_PORT, max_players: int = MAX_PLAYERS) -> bool:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_players)
	if error != OK:
		print("Failed to start server: %s" % error)
		return false
	
	multiplayer.multiplayer_peer = peer
	var team_id = 0
	var ally_id = 0
	if player_info.has("team_id"):
		team_id = player_info["team_id"]
		#pass
	if player_info.has("ally_id"):
		ally_id = player_info["ally_id"]
	_add_player(local_player_id, {
		#"username": "Server",
		"username": player_info["name"],
		"team_id": team_id,
		"ally_id": ally_id,
		# player_info
		"position": Vector2.ZERO
	})
	print("Server started on port %d" % port)
	return true
	#pass

func _network_join(ip: String = DEFAULT_IP, port: int = DEFAULT_PORT) -> bool:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if error != OK:
		print("Failed to join server: %s" % error)
		return false
	var team_id = 0
	var ally_id = 0
	if player_info.has("team_id"):
		team_id = player_info["team_id"]
	if player_info.has("ally_id"):
		ally_id = player_info["ally_id"]
	
	multiplayer.multiplayer_peer = peer
	local_player_id = multiplayer.get_unique_id()
	_add_player(local_player_id, {
		#"username": "Player_%d" % local_player_id,
		"username": player_info["name"],
		"team_id": team_id,
		"ally_id": ally_id,
		"position": Vector2.ZERO
	})
	print("Attempting to join server at %s:%d" % [ip, port])
	return true

# Add player to the players dictionary
func _add_player(peer_id: int, info: Dictionary):
	players[peer_id] = info
	emit_signal("player_connected", peer_id, info)

# Remove player from the players dictionary
func _remove_player(peer_id: int):
	if players.has(peer_id):
		players.erase(peer_id)
		emit_signal("player_disconnected", peer_id)

# RPC to sync player removal to all peers
@rpc("authority", "call_local", "reliable")
func sync_remove_player(peer_id: int):
	_remove_player(peer_id)

# RPC to request player info from a newly connected peer
@rpc("authority", "call_remote", "reliable")
func request_player_info():
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id == 1:  # Only respond to server
		var info = players[local_player_id]
		send_player_info.rpc_id(1, local_player_id, info)

# RPC to send player info to the server
@rpc("any_peer", "call_remote", "reliable")
func send_player_info(peer_id: int, info: Dictionary):
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id()
		if sender_id != peer_id:
			print("Warning: Sender ID mismatch for peer %d" % sender_id)
			return
		_add_player(peer_id, info)
		# Sync new player to all clients
		sync_player_info.rpc(peer_id, info)
		
# RPC to sync player info to all peers
@rpc("authority", "call_local", "reliable")
func sync_player_info(peer_id: int, info: Dictionary):
	print("authority > call_local > sync_player_info")
	_add_player(peer_id, info)
	
# Signal handlers
func _on_peer_connected(peer_id: int):
	if multiplayer.is_server():
		print("Peer %d connected" % peer_id)
		# Request player info from the new peer
		request_player_info.rpc_id(peer_id)
		Global.notify_message("Peer %d connected" % peer_id)
		
func _on_peer_disconnected(peer_id: int):
	if multiplayer.is_server():
		print("Peer %d disconnected" % peer_id)
		_remove_player(peer_id)
		# Notify all clients to remove the player
		sync_remove_player.rpc(peer_id)
		Global.notify_message("Peer %d disconnected" % peer_id)
		
func _on_connected_to_server():
	print("Connected to server, local peer ID: %d" % local_player_id)
	Global.hide_connection_status()
	Global.sent_notify_message(local_player_id, "Connected to server, local peer ID: %d" % local_player_id)

func _on_connection_failed():
	print("Connection to server failed")
	multiplayer.multiplayer_peer = null
	Global.hide_connection_status()
	Global.sent_notify_message(local_player_id, "Connection to server failed")
	player_failed_connected.emit()
	
func _on_server_disconnected():
	print("Disconnected from server")
	players.clear()
	multiplayer.multiplayer_peer = null
	emit_signal("server_disconnected")
	Global.notify_message("server_disconnected")

func get_id_player_name(id:int):
	var _name:String = ""
	for i in players:
		if i == id:
			_name = players[i]["username"]
			break
	return _name
	#pass
