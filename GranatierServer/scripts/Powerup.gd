extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():		
	pass

#Signal that is called, when the Player picks up a Powerup
func _on_Powerup_body_entered(body):
	print(body.name)
	if body is KinematicBody2D:
		body.pick_up_powerup(12)
		queue_free()
