extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

## DECLARATIONS
#Current input direction
var input_dir : Vector2 = Vector2.ZERO
#Camera controls
@onready var cameraController = get_tree().get_nodes_in_group("CameraController")[0]
#Animation state machine
@onready var animation_tree : AnimationTree = $AnimationTree




## REMOVE CAMERA LOOKAT AND USE CAMERA CONTROLLER ROTATION INSTEAD
var cameraLookAt


var lastLookAtDirection: Vector3

func _ready(): 
	animation_tree.active = true
	
	cameraLookAt = cameraController.get_node("LookAt")

func _process(delta):
	update_animation_parameters(input_dir)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("left", "right", "forward", "backward")
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

	move_and_slide()

func update_animation_parameters(input_dir):
	print(input_dir)
	if is_idle(input_dir):
		print("is_idle")
		animation_tree["parameters/conditions/is_idle"] = true;
		animation_tree["parameters/conditions/is_walking"] = false;
	
	if is_walking(input_dir):
		print("is_walking")
		animation_tree["parameters/conditions/is_idle"] = false;
		animation_tree["parameters/conditions/is_walking"] = true;
	
	if (input_dir != Vector2.ZERO):
		animation_tree["parameters/Walk/blend_position"] = input_dir

# DECLARE LOGIC TO DETERMINE IF PLAYER IS IDLE
func is_idle(input_dir):
	if input_dir != Vector2.ZERO: 
		return false
	return is_on_floor()
	
func is_walking(input_dir):
	if input_dir == Vector2.ZERO: 
		return false
	return is_on_floor()
	
