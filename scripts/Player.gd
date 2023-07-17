extends CharacterBody3D

@export var speed = 4
@export var inairspeed = 6
@export var jump_velocity = 8
@export var look_sensitivity =  0.0015
@export var is_sneaking = false
var gravity = 9.81
var velocity_y = 0
var speedonground = Vector3.ZERO
@onready var camera:Camera3D = $Camera3D
@onready var raycast:RayCast3D = $Camera3D/RayCast3D

func _process(delta):
	
	# movement
	var horizontal_velocity = Input.get_vector("move_left","move_right","move_forward","move_backward").normalized() # normalized makes it so you dont move faster when you are strafing
	
	# jumping
	if is_on_floor():
		
		if Input.is_action_pressed("sneak_and_slide"):
			is_sneaking = true
			velocity.z = velocity.z * 0.996
			velocity.x = velocity.x * 0.996
		else:
			is_sneaking = false
			velocity = velocity.lerp((horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z)*speed, delta*8) # lerp smoothes movement
		
		
		velocity_y = 0
		
		if Input.is_action_just_pressed("jump"):
			if Input.is_action_pressed("sneak_and_slide"):
				speedonground = velocity
			velocity_y = jump_velocity
	else:
		if not is_sneaking:
			velocity = velocity.lerp((horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z)*inairspeed, delta*5) # lerp smoothes movement
		else:
			velocity = velocity.lerp((horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z)*inairspeed, delta*10)+ speedonground*0.05
		
		if not position.y < -3:
			velocity_y -= gravity * delta # falling
		else: 
			speedonground = Vector3.ZERO
			velocity_y = 20
	velocity.y = velocity_y # update y
	
	move_and_slide() # start moving
	
	if is_sneaking and camera.position.y >= 1.0:
		camera.position.y -= 4 * delta
	elif (not is_sneaking) and camera.position.y <= 1.537:
		camera.position.y += 4 * delta
	
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
			
