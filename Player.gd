extends CharacterBody3D
class_name Player

func _ready():
	Lobby.mp_print("_ready() for %d" % [name.to_int()])
	if name.to_int() == multiplayer.get_unique_id():
		#position = spawn_position
		Lobby.mp_print("spawn @ %s for %d" % [global_position, name.to_int()])
	
	set_physics_process(name.to_int() == multiplayer.get_unique_id())
	
	if name.to_int() == multiplayer.get_unique_id():
		$Camera3D.current = true
		$MeIndicator.visible = true
		$AnimationPlayer.play("IndicatorBob")

func _enter_tree():
	Lobby.mp_print("_enter_tree() for %d" % [name.to_int()])
	$ReplicationSynchronizer.set_multiplayer_authority(name.to_int())

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(_delta):
	if not is_on_floor():
		velocity.y -= gravity * _delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
