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
		apply_central_impulse(force.normalized()*20)
	if(position.y>1000):
		apply_central_impulse(Vector2.UP*3000)

func _on_mouse_entered():
	mouseinme = true


func _on_mouse_exited():
	mouseinme = false

