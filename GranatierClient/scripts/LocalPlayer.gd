extends "res://scripts/Player.gd"

export var speed = 100
func _physics_process(delta):
	var motion = Vector2.ZERO 
	if Input.is_action_pressed("move_right"):
		motion.x = 1
		rotation = 0
	if Input.is_action_pressed("move_left"):
		motion.x = -1
		rotation = PI
	if Input.is_action_pressed("move_down"):
		motion.y = 1
		rotation = PI/2
	if Input.is_action_pressed("move_up"):
		motion.y = -1
		rotation = 1.5*PI

	if motion.length() > 0:
		#motion = motion.normalized() * speed
		Server.MovePlayer(motion)
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
	
	
	#move_and_slide(motion * speed, Vector2.UP)
