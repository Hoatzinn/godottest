extends Node3D
@onready var animationplayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_shoot():
	print("E")
	animationplayer.play("shoot")


func _on_player_not_shoot():
	print("not E")
	animationplayer.play("RESET")
