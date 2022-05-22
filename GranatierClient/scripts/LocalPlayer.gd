extends KinematicBody2D

var bomb_scene = preload("res://scenes/Bomb.tscn")

var speed = 100

func set_animation(player_no):
	$AnimatedSprite.animation = "player" + str(player_no)

func _physics_process(_delta):
	var motion = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		motion = Vector2.RIGHT
		rotation = 0
	if Input.is_action_pressed("move_down"):
		motion = Vector2.DOWN
		rotation = PI/2
	if Input.is_action_pressed("move_left"):
		motion = Vector2.LEFT
		rotation = PI
	if Input.is_action_pressed("move_up"):
		motion = Vector2.UP
		rotation = 1.5*PI
	if Input.is_action_just_pressed("place_bomb"):
		var bomb = bomb_scene.instance()
		var tilemap = get_node("../TileMap")
		bomb.position = tilemap.map_to_world(tilemap.world_to_map(position - tilemap.position)) + tilemap.position + Vector2(20,20)
		print("spawn bomb")
		get_parent().add_child(bomb)

	if motion.length() > 0:
		var _v = move_and_slide(motion * speed)
		Server.MovePlayer(motion)
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
