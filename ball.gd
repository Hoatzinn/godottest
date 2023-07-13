extends RigidBody2D



var MousePressed
var mouseinme
var force

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(mouseinme and Input.is_action_pressed("Mouse_Action")):
		force = get_global_mouse_position() - global_position
		print_debug(force.normalized())
		apply_central_impulse(force.normalized()*200)

func _on_mouse_entered():
	mouseinme = true


func _on_mouse_exited():
	mouseinme = false

