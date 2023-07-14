extends CharacterBody3D

@export var speed = 10
@export var inairspeed = 15
@export var jump_velocity = 8
@export var look_sensitivity =  0.0015
var gravity = 9.81
var velocity_y = 0
@onready var camera:Camera3D = $Camera3D
@onready var raycast:RayCast3D = $Camera3D/RayCast3D

func _process(delta):
	
	# movement
	var horizontal_velocity = Input.get_vector("move_left","move_right","move_forward","move_backward").normalized() # normalized makes it so you dont move faster when you are strafing
	
	# jumping
	if is_on_floor():
		velocity = velocity.lerp((horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z)*speed, delta*8) # lerp smoothes movement
		velocity_y = 0
		if Input.is_action_just_pressed("jump"):
			velocity_y = jump_velocity
	else:
		velocity = velocity.lerp((horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z)*inairspeed, delta*8) # lerp smoothes movement
		if not position.y < -3:
			velocity_y -= gravity * delta # falling
		else: 
			velocity_y = 20
	velocity.y = velocity_y # update y
	
	move_and_slide() # start moving
	
	# button code
	if Input.is_action_just_pressed("Mouse_Action"):
		if raycast.get_collider() != null:
			var regex = RegEx.new()
			regex.compile("button.*")
			if regex.search(raycast.get_collider().name):
				if raycast.get_collider().button_activated:
					raycast.get_collider().button_activated = false
				else:
					raycast.get_collider().button_activated = true
				
	
	# fullscreen and invisible mouse/cursor
	if Input.is_action_just_pressed("fullscreen"):
		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE # ??
		
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _input(event):
	#camera movement
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x*look_sensitivity) # rotate body
		camera.rotate_x(-event.relative.y*look_sensitivity) # rotate camera up and down (no headshaking)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2) # no moving in the wrong way sir
			
