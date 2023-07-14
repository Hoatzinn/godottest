extends StaticBody3D

@export var button_activated = false
var button_down = false
const BUTTON_DOWN = 0.023
const BUTTON_UP = 0.264
@onready var b:MeshInstance3D = $untitled/Circle_001

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if button_activated and not b.position.y <= BUTTON_DOWN:
		b.position.y -= 0.01
	elif not button_activated and not b.position.y >= BUTTON_UP:
		b.position.y += 0.01
