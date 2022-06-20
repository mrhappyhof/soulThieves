extends KinematicBody2D

var stats = { 
	"speed": 100,
	"can_kick": false,
	"can_throw": false,
	"has_shield": false,
	"layable_bombs": 1,
	"bomb_blast_range": 1,
	"is_scatty": false,
	"is_restrained": false,
	"has_mirror": false,
	"has_teleport": false,
	"hyperactive": false,
	"slow": false,
	"is_dead": false
}

var in_bomb = null

var used_spawn

var motion = Vector2.ZERO
var viewing_direction = Vector2.ZERO
#var speed = 100
#var can_kick = false
#var can_throw = false
#var has_shield = false
#var layable_bombs = 1
#var bomb_blast_range = 1
#var is_scatty = false
#var is_restrained = false
#var has_mirror = false
#var has_teleport = false
var has_bad_powerup = false
#var hyperactive = false
#var slow = false
#
#var is_dead = false

func _ready():
	set_physics_process(false)

func _physics_process(_delta):
	if not stats.is_dead and motion != Vector2.ZERO:
		var amplifier = 1
		if stats.has_mirror:
			amplifier = -1
		elif stats.hyperactive:
			amplifier = 4
		elif stats.slow:
			amplifier = 0.5
		move_and_slide(motion * stats.speed * amplifier);
		motion = Vector2.ZERO

func move(v):
	motion = v
	if v != Vector2.ZERO:
		viewing_direction = v

#Decides which Powerup was picked up and changes the attributes of the player
func pick_up_powerup(type):
	match type:
		Powerup.Types.BAD_HYPERACTIVE:
			if not has_bad_powerup:
				stats.hyperactive = true
				has_bad_powerup = true
				$Timer.start()
				print("BAD_HYPERACTIVE, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.Types.BAD_MIRROR: 
			if not has_bad_powerup:
				stats.has_mirror = true
				has_bad_powerup = true
				$Timer.start()
				print("BAD_MIRROR, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.Types.BAD_RESTRAIN:
			if not has_bad_powerup:
				stats.is_restrained = true
				has_bad_powerup = true
				$Timer.start()
				print("BAD_RESTRAIN, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.Types.BAD_SCATTY: 
			if not has_bad_powerup:
				stats.is_scatty = true
				has_bad_powerup = true
				$Timer.start()
				$ScattyTimer.start()
				print("BAD_SCATTY, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.Types.BAD_SLOW:
			if not has_bad_powerup:
				stats.slow = true
				has_bad_powerup = true
				$Timer.start()
				print("BAD_SLOW, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.Types.BOMB: 
			stats.layable_bombs += 1
			print("BOMB, LAYABLE_BOMS: " + str(stats.layable_bombs))
		Powerup.Types.KICK: 
			stats.can_kick = true
			print("KICK, CAN_KICK " + str(stats.can_kick))
		Powerup.Types.POWER: 
			stats.bomb_blast_range += 1
			print("POWER, BOMB_BLAST_RANGE: " + str(stats.bomb_blast_range))
		Powerup.Types.SHIELD: 
			if not stats.has_shield:
				stats.has_shield = true
				print("SHIELD, HAS_SHIELD " + str(stats.has_shield))
		Powerup.Types.SPEED: 
			stats.speed += 20
			print("SPEED")
		Powerup.Types.THROW: 
			stats.can_throw = true
			print("THROW, CAN_THROW " + str(stats.can_throw))
		Powerup.Types.NEUTRAL_TELEPORT: 
			stats.has_teleport = true
			get_node("/root/Server").teleport_player(int(name))
		Powerup.Types.NEUTRAL_PANDORA:
			var randomizer = RandomNumberGenerator.new()
			randomizer.randomize()
			var randomNumber = randomizer.randi_range(0, Powerup.Types.size() - 3) #-3 because the last two are neutral
			print("NEUTRAL_PANDORA, RANDOMNUMBER: " + str(randomNumber))
			pick_up_powerup(randomNumber)

#Called, when the timer of the bad Powerup runs out and resets 
#some attributes of the player
func _on_bad_powerup_timer_timeout():
	stats.has_mirror = false
	stats.is_restrained = false
	stats.is_scatty = false
	stats.hyperactive = false
	stats.slow = false
	$ScattyTimer.stop()
	has_bad_powerup = false
	
	print("HAS_BAD_POWERUP: " + str(has_bad_powerup))

func destroy():
	if !stats.has_shield:
		stats.is_dead = true
		print("Im dieing")
		get_parent().get_parent().players_alive.erase(int(name))
	else:
		stats.has_shield = false 
#TODO: If player was hit by the bomb and has_shield, has_shield = false


func _on_ScattyTimer_timeout():
	get_node("/root/Server").place_bomb(int(name))
