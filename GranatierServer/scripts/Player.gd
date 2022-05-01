extends KinematicBody2D
var speed = 100

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func move(motion):
# warning-ignore:return_value_discarded
	move_and_slide(motion * speed, Vector2.UP);

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
