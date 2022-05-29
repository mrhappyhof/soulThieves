extends "res://scripts/Player.gd"

var bomb_scene = preload("res://scenes/Bomb.tscn")


var placed_bomb_count = 0

func _ready():
	pass

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
		var tilemap = get_node("../../TileMap")
		bomb.position = tilemap.map_to_world(tilemap.world_to_map(position - tilemap.position)) + tilemap.position + Vector2(20,20)
		bomb.name = str(get_tree().get_network_unique_id()) + "-" + str(placed_bomb_count)
		placed_bomb_count += 1
		get_node("../../Bombs").add_child(bomb, true)
		Server.place_bomb()

	if motion.length() > 0:
		var _v = move_and_slide(motion * speed)
		Server.MovePlayer(motion)
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
