extends "res://scripts/Player.gd"

var bomb_scene = preload("res://scenes/Bomb.tscn")


var placed_bomb_count = 0
var motion = Vector2.ZERO

var last_pressed
var invert_rot

var died = false

var settings_open = false

func update_stats(newStats, timestamp):
	stats = newStats
	var hud = get_node("../../HUD")
	if newStats.has_shield:
		hud.hud_enable_powerup(Powerup.Types.SHIELD)
	else:
		hud.hud_disable_powerup(Powerup.Types.SHIELD)
	if newStats.can_kick:
		hud.hud_enable_powerup(Powerup.Types.KICK)
	else:
		hud.hud_disable_powerup(Powerup.Types.KICK)
	if newStats.can_throw:
		hud.hud_enable_powerup(Powerup.Types.THROW)
	else:
		hud.hud_disable_powerup(Powerup.Types.THROW)
		
	if newStats.is_scatty:
		hud.hud_enable_powerup(Powerup.Types.BAD_SCATTY)
	elif newStats.is_restrained:
		hud.hud_enable_powerup(Powerup.Types.BAD_RESTRAIN)
	elif newStats.has_mirror:
		hud.hud_enable_powerup(Powerup.Types.BAD_MIRROR)
	elif newStats.hyperactive:
		hud.hud_enable_powerup(Powerup.Types.BAD_HYPERACTIVE)
	elif newStats.slow:
		hud.hud_enable_powerup(Powerup.Types.BAD_SLOW)
	else:
		hud.hud_disable_powerup(Powerup.Types.BAD_SCATTY)

func _physics_process(_delta):
	#if stats.is_dead or can_move:
	if stats.is_dead or settings_open:
		return
	if Input.is_action_just_pressed("move_right"):
		last_pressed = "move_right"
		motion = Vector2.RIGHT
		rotation = 0
		invert_rot = fmod(rotation + PI, 2 * PI)
	elif Input.is_action_just_pressed("move_down"):
		last_pressed = "move_down"
		motion = Vector2.DOWN
		rotation = PI/2
		invert_rot = fmod(rotation + PI, 2 * PI)
	elif Input.is_action_just_pressed("move_left"):
		last_pressed = "move_left"
		motion = Vector2.LEFT
		rotation = PI
		invert_rot = fmod(rotation + PI, 2 * PI)
	elif Input.is_action_just_pressed("move_up"):
		last_pressed = "move_up"
		motion = Vector2.UP
		rotation = 1.5*PI
		invert_rot = fmod(rotation + PI, 2 * PI)
	elif Input.is_action_just_pressed("place_bomb"):
		if stats.layable_bombs > 0 and !stats.is_restrained:
			var bomb = bomb_scene.instance()
			var tilemap = get_node("../../TileMap")
			bomb.position = tilemap.map_to_world(tilemap.world_to_map(position - tilemap.position)) + tilemap.position + Vector2(20,20)
			bomb.name = str(get_tree().get_network_unique_id()) + "-" + str(placed_bomb_count)
			bomb.bomb_range = stats.bomb_blast_range
			placed_bomb_count += 1
			get_node("../../Bombs").add_child(bomb, true)
			#stats.layable_bombs -= 1
			print("layable:" + str(stats.layable_bombs))
			bomb.player = self
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
			rotation = invert_rot
			
		var _v = move_and_slide(motion * stats.speed * amplifier)
		Server.move_player(motion)
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
	

func start_bad_powerup_timer():
	$BadPowerupTimer.start()

func _on_BadPowerupTimer_timeout():
	var hud  = get_node("../../HUD")
	hud.hud_disable_powerup(Powerup.Types.BAD_HYPERACTIVE) # spielt keine Rolle welches Powerup deaktiviert wird da nur ein "Bad Powerup" aktiv sein kann 

func destroy():
	if !stats.has_shield:
		stats.is_dead = true
		#print(stats.can_move)
		if not died:
			$DieSound.play()
			$AnimatedSprite.animation = $AnimatedSprite.animation + "_dead"
			died = true
	else:
		stats.has_shield = false 
