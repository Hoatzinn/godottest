extends CharacterBody3D

@export var speed = 4
@export var inairspeed = 6
@export var jump_velocity = 14
@export var look_sensitivity := 0.0015
@export var slide_curve:Curve
var time_sneaking := 0.0
var is_sneaking := false
const MAX_AIR_SNEAK_VEL = 20
@export var gravity = 40
var velocity_y = 0
@onready var camera:Camera3D = $Camera3D
@onready var raycast:RayCast3D = $Camera3D/RayCast3D
@onready var axe:Node3D = $Camera3D/Weapons/Axe
var axe_def_rot
var axe_bob = 0
var inair_vel := 0.0

signal shoot

#TODO camera rotation


func _ready():
	axe_def_rot = axe.rotation
func _process(delta):
	
	# movement
	var horizontal_velocity = Input.get_vector("move_left","move_right","move_forward","move_backward").normalized() # normalized makes it so you dont move faster when you are strafing
	
	# jumping
	if is_on_floor():
		if Input.is_action_pressed("sneak_and_slide"):
			is_sneaking = true
			time_sneaking += delta
			velocity.z = inair_vel * slide_curve.sample(time_sneaking)# 0.995
			velocity.x = inair_vel * slide_curve.sample(time_sneaking)#0.995
			velocity = velocity.length()*-global_transform.basis.z
		else:
			inair_vel = 0
			is_sneaking = false
			time_sneaking = 0.0
			velocity = velocity.lerp((horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z)*speed, delta*5) # lerp smoothes movement
		
		
		velocity_y = 0
		
		if Input.is_action_just_pressed("jump"):
			velocity_y = jump_velocity
	# NOT ON FLOOR
	else:
		inair_vel = Vector2(velocity.x, velocity.z).length()
		is_sneaking = false
		time_sneaking = 0.0
		velocity = velocity.lerp((horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z)*inairspeed, delta*8) # lerp smoothes movement
		
		if not position.y < -3:
			velocity_y -= gravity * delta
		else: 
			velocity_y = 40
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
		else:
			emit_signal("shoot")
	elif Input.is_action_pressed("Mouse_Action"):
		'''axe_bob += delta*20
		axe.rotate(Vector3(sin(axe_bob), 0 , 0).normalized(), -0.1)'''
		pass
	else:
		axe.rotation = axe_def_rot
		axe_bob = 0
	
	# fullscreen and invisible mouse/cursor
	if Input.is_action_just_pressed("fullscreen"):
		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
		
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
