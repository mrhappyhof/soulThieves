extends "res://scripts/Player.gd"

var bomb_scene = preload("res://scenes/Bomb.tscn")


var placed_bomb_count = 0
var motion = Vector2.ZERO

var last_pressed

func _ready():
	pass

func _physics_process(_delta):
	if stats.is_dead:
		return
	if Input.is_action_just_pressed("move_right"):
		last_pressed = "move_right"
		motion = Vector2.RIGHT
		rotation = 0
	elif Input.is_action_just_pressed("move_down"):
		last_pressed = "move_down"
		motion = Vector2.DOWN
		rotation = PI/2
	elif Input.is_action_just_pressed("move_left"):
		last_pressed = "move_left"
		motion = Vector2.LEFT
		rotation = PI
	elif Input.is_action_just_pressed("move_up"):
		last_pressed = "move_up"
		motion = Vector2.UP
		rotation = 1.5*PI
	elif Input.is_action_just_pressed("place_bomb"):
		if stats.layable_bombs > 0:
			$PutBombSound.play()
			var bomb = bomb_scene.instance()
			var tilemap = get_node("../../TileMap")
			bomb.position = tilemap.map_to_world(tilemap.world_to_map(position - tilemap.position)) + tilemap.position + Vector2(20,20)
			bomb.name = str(get_tree().get_network_unique_id()) + "-" + str(placed_bomb_count)
			placed_bomb_count += 1
			get_node("../../Bombs").add_child(bomb, true)
			Server.place_bomb()
	elif not last_pressed == null and Input.is_action_just_released(last_pressed):
		motion = Vector2.ZERO

	if motion.length() > 0:
		var amplifier = 1
		if stats.hyperactive:
			amplifier = 4
		elif stats.slow:
			amplifier = 0.5
		elif stats.has_mirror:
			amplifier = -1
		var _v = move_and_slide(motion * stats.speed * amplifier)
		Server.move_player(motion)
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
	
