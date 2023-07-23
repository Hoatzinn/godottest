extends CharacterBody3D

@export var speed = 4
@export var inairspeed = 6
@export var jump_velocity = 7
@export var look_sensitivity =  0.0015
@export var is_sneaking = false
const MAX_AIR_SNEAK_VEL = 20
const DASH_GRAVITY = 2000
const SP_JUMP_STR = 17
var super_jump = false
var gravity = 9.81+2
var velocity_y = 0
var speedonground = Vector3.ZERO
@onready var camera:Camera3D = $Camera3D
@onready var raycast:RayCast3D = $Camera3D/RayCast3D
@onready var axe:Node3D = $Camera3D/axe
var axe_def_rot
var axe_bob = 0


func _ready():
	axe_def_rot = axe.rotation
func _process(delta):
	
	# movement
	var horizontal_velocity = Input.get_vector("move_left","move_right","move_forward","move_backward").normalized() # normalized makes it so you dont move faster when you are strafing
	
	# jumping
	if is_on_floor():
		
		if Input.is_action_pressed("sneak_and_slide"):
			is_sneaking = true
			velocity.z = velocity.z * 0.996
			velocity.x = velocity.x * 0.996
			if Input.is_action_just_pressed("jump"):
				velocity.z = velocity.z * 1.2
				velocity.x = velocity.x * 1.2
				super_jump = true
		else:
			super_jump = false
			is_sneaking = false
			velocity = velocity.lerp((horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z)*speed, delta*8) # lerp smoothes movement
		
		
		velocity_y = 0
		
		if Input.is_action_just_pressed("jump"):
			if not super_jump:
				velocity_y = jump_velocity
			else:
				velocity_y = SP_JUMP_STR
	else:
		is_sneaking=false
		if not super_jump:
			velocity = velocity.lerp((horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z)*inairspeed, delta*5) # lerp smoothes movement
			
			# dashing
			if Input.is_action_pressed("sneak_and_slide") and not super_jump:
				if sqrt(pow(velocity.abs().x,2) + pow(velocity.abs().z,2)) < MAX_AIR_SNEAK_VEL:
					velocity.z = velocity.z * 1.05
					velocity.x = velocity.x * 1.05 
				velocity_y = -DASH_GRAVITY*delta
		else:
			#velocity = velocity.lerp((horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z)*inairspeed, delta*0)
			pass
		
		if not position.y < -3:
			if not super_jump:
				velocity_y -= gravity * delta # falling
			else:
				velocity_y -= 40 * delta
		else: 
			speedonground = Vector3.ZERO
			super_jump= false
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
	elif Input.is_action_pressed("Mouse_Action"):
		axe_bob += delta*20
		axe.rotate(Vector3(sin(axe_bob), 0, 0).normalized(), -0.1)
	else:
		axe.rotation = axe_def_rot
		axe_bob = 0
	
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
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2) # thou may not moveth upsidedown
			
