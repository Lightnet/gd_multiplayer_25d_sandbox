extends CharacterBody3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var place_holder_ground: MeshInstance3D = $place_holder_ground

# Signals
signal toggle_inventory()

@export var inventory_data:InventoryData
@export var equip_inventory_data:InventoryDataEquip

# Node
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_3d: Camera3D = $Camera3D

var face_direction:Vector3 = Vector3.ZERO

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
	if direction.length()>0:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		face_direction = direction
		#print("face_direction:", face_direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	update_face_place()
	detect_floor_place()
	
	move_and_slide()

func update_face_place():
	if face_direction.length() > 0:
		# Normalize the face direction
		face_direction = face_direction.normalized()
		# Position the raycast one grid cell ahead in the facing direction
		var ray_start = global_position + face_direction * 1.0  # Adjust distance as needed
		ray_start.y += 1.0  # Raise the raycast start to avoid starting inside the floor
		ray_cast_3d.global_position = ray_start
		ray_cast_3d.target_position = Vector3(0, -2.0, 0)  # Cast downward to detect floor
		
func detect_floor_place():
	if ray_cast_3d.is_colliding():
		var pos = ray_cast_3d.get_collision_point()
		# Snap to the nearest grid cell center (assuming 1x1 grid)
		var grid_pos = Vector3(
			floor(pos.x), #0.5  # Center of the grid cell
			pos.y + 0.01,        # Slightly above the floor
			floor(pos.z) #+ 0.5   # Center of the grid cell
		)
		place_holder_ground.global_position = grid_pos
	else:
		# Hide placeholder or set to a default position if no collision
		place_holder_ground.global_position = global_position + face_direction * 1.0

# drop item forward position
func get_drop_position() -> Vector3:
	
	# camera 
	#var direction  = -camera_3d.global_transform.basis.z
	#return camera_3d.global_position + direction
	
	# player position and input face direction
	face_direction.x = (face_direction.x * 1.1 )
	face_direction.y = face_direction.y + 0.5
	face_direction.z = (face_direction.z * 1.1 )
	
	return global_position + face_direction
	
