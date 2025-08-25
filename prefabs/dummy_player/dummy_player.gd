extends CharacterBody3D

# Signals
signal toggle_inventory()

@export var inventory_data:InventoryData
@export var equip_inventory_data:InventoryDataEquip

# Node
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_3d: Camera3D = $Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	if not is_multiplayer_authority(): return
	camera_3d.make_current()
	Global.set_player(self)

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("forward"):
		animation_player.play("back")
	if event.is_action_pressed("backward"):
		animation_player.play("front")
	if event.is_action_pressed("left"):
		animation_player.play("left")
	if event.is_action_pressed("right"):
		animation_player.play("right")
	if Input.is_action_just_pressed("inventory"):
		print("inventory")
		toggle_inventory.emit()
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if not is_multiplayer_authority(): return
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
