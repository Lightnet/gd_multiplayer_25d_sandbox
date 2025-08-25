extends Node

const PICKUP = preload("res://item/pickUp/pick_up.tscn")

var target:Vector3
var count:int = 100
var counter_unit:int = 100
var counter_building:int = 100

@rpc("any_peer", "call_remote", "reliable")
func notify_message(_message:String)->void:
	var notifies = get_tree().get_nodes_in_group("notify")
	if len(notifies) == 1:
		notifies[0].add_message(_message)
	pass

# testing if the authority server is for remote not other peers
func sent_notify_message(pid:int, _message:String)->void:
	print("sent_notify_message id: ", pid)
	print("multiplayer.is_server(): ", multiplayer.is_server())
	if multiplayer.is_server():
		if pid == 0:
			notify_message(_message)
		else: 
			notify_message.rpc_id(pid,_message)
	else:
		notify_message(_message)

func show_connection_status()-> void:
	#connectionstatus
	var connectionstatuses = get_tree().get_nodes_in_group("connectionstatus")
	if len(connectionstatuses) == 1:
		connectionstatuses[0].show()
	#pass

func hide_connection_status()-> void:
	#connectionstatus
	var connectionstatuses = get_tree().get_nodes_in_group("connectionstatus")
	if len(connectionstatuses) == 1:
		connectionstatuses[0].hide()
	#pass

func generate_random_name(min_length: int = 3, max_length: int = 8) -> String:
	var vowels = ["a", "e", "i", "o", "u"]
	var consonants = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "w", "y"]
	var name_length = randi_range(min_length, max_length)
	var _name = ""
	var use_vowel = randi() % 2 == 0
	
	for i in range(name_length):
		if use_vowel:
			_name += vowels[randi() % vowels.size()]
		else:
			_name += consonants[randi() % consonants.size()]
		use_vowel = !use_vowel
	
	# Capitalize first letter
	_name = _name.capitalize()
	
	return _name

func get_add_name() -> String:
	count+=1
	return "obj_"+ str(count)

func get_count_unit_name() -> String:
	counter_unit+=1
	return "unit_"+ str(counter_unit)

func get_count_building_name() -> String:
	counter_building+=1
	return "building_"+ str(counter_building)

var player
var state_menu:String = "none"
#var res_player_path = "user://player_res.tres"

func set_player(entity):
	player = entity
	if player:
		connect_player()
	else:
		disconnect_player()
		pass
	
func get_player():
	return player

func connect_player():
	#delay due other ui not load for scene...
	await get_tree().create_timer(0.1).timeout
	var inventory_interface = get_tree().get_first_node_in_group("inventoryinterface")
	var hot_bar_inventory = get_tree().get_first_node_in_group("hotbarinventory")
	if player and inventory_interface and hot_bar_inventory:
		#print("player: ", player)
		player.toggle_inventory.connect(toggle_inventory_interface)
		
		#print("player.inventory_data:", player.inventory_data)
		inventory_interface.drop_slot_data.connect(_on_inventory_interface_drop_slot_data)
		inventory_interface.set_player_inventory_data(player.inventory_data)
		# inventory
		inventory_interface.set_equip_inventory_data(player.equip_inventory_data)
		inventory_interface.force_close.connect(toggle_inventory_interface)
		hot_bar_inventory.set_inventory_data(player.inventory_data)
	
	#chest
	#for node in get_tree().get_nodes_in_group("external_inventory"):
		#node.toggle_inventory.connect(toggle_inventory_interface)
	#pass
	
func disconnect_player():
	var inventory_interface = get_tree().get_first_node_in_group("inventoryinterface")
	var hot_bar_inventory = get_tree().get_first_node_in_group("hotbarinventory")
	
	player.toggle_inventory.disconnect(toggle_inventory_interface)
	inventory_interface.force_close.disconnect(toggle_inventory_interface)
	pass

func toggle_inventory_interface(external_inventory_owner = null) -> void:
	var inventory_interface = get_tree().get_first_node_in_group("inventoryinterface")
	
	inventory_interface.visible = not inventory_interface.visible
	print("inventory_interface.visible: ", inventory_interface.visible)
	
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#PlayerManager.enable_menu()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#PlayerManager.disable_menu()
	
	if external_inventory_owner and inventory_interface.visible:
		print("external_inventory_owner")
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()

func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	var pick_up = PICKUP.instantiate()
	pick_up.slot_data = slot_data
	#pick_up.position = Vector3.UP
	pick_up.position = player.get_drop_position()
	get_tree().current_scene.add_child(pick_up)
	#pass


#================================================
# SLOT
#================================================

func use_slot_data(slot_data:SlotData) -> void:
	slot_data.item_data.use(player)
	#pass

func get_global_position() -> Vector3:
	return player.global_position

#================================================
# MENU
#================================================

func disable_menu():
	state_menu = "none"

func enable_menu():
	state_menu = "menu"

func is_enable_controller() -> bool:
	if state_menu == "menu":
		return false
	return true
