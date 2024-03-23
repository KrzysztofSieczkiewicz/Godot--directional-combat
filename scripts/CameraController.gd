extends Node3D

@onready var camera_3d = $SpringArm3D/Camera3D

var player

@export var horizontal_sensitivity := 5
@export var vertical_sensitivity := 3

@export var invert_x_look = false;
@export var invert_y_look = false;
var x_look_dir = 1;
var y_look_dir = -1;


# Called when the node enters the scene tree for the first time.
func _ready():
	#Assign player
	player = get_tree().get_nodes_in_group("Player")[0]
	
	#Capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	
	if invert_x_look:
		x_look_dir = -1
	if invert_y_look:
		y_look_dir = 1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Assign camera position to the player position
	global_position = player.global_position
	
	# Target camera to look at the point
	camera_3d.look_at( player.get_node("LookAt").global_position )
	
	pass

func _input(event):
		if event is InputEventMouseMotion:
			#rotation.x += event.relative.y / 1000 * vertical_sensitivity * -1
			var tempRotationX = rotation.x - event.relative.y / 1000 * vertical_sensitivity * x_look_dir
			rotation.x = clamp(tempRotationX, -1.5, -0.1)
			
			
			rotation.y += event.relative.x / 1000 * vertical_sensitivity * y_look_dir

