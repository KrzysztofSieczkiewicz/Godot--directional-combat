extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Animation tree
var animationStateMachine

var cameraLookAt
var lastLookAtDirection: Vector3

func _ready():
	var cameraController = get_tree().get_nodes_in_group("CameraController")[0]
	cameraLookAt = cameraController.get_node("LookAt")
	
	# Get animation tree
	animationStateMachine = $AnimationTree

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		# Face camera direction
		var lerpDir = lerp(lastLookAtDirection, Vector3(cameraLookAt.global_position.x, global_position.y, cameraLookAt.global_position.z), 0.05)
		look_at( Vector3(lerpDir.x, global_position.y, lerpDir.z) )
		lastLookAtDirection = lerpDir
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	
	animationStateMachine.set("parameters/conditions/idle", _is_idle(input_dir))
	animationStateMachine.set("parameters/conditions/walk", _is_walking(input_dir))

	move_and_slide()

# DECLARE LOGIC TO DETERMINE IF PLAYER IS IDLE
func _is_idle(input_dir):
	if input_dir != Vector2.ZERO: 
		return false
	return is_on_floor()
	
func _is_walking(input_dir):
	if input_dir == Vector2.ZERO: 
		return false
	return is_on_floor()
	
