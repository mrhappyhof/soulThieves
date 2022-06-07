extends KinematicBody2D
const base_speed = 100
var speed = base_speed

var can_kick = false
var can_throw = false
var has_shield = false
var layable_bombs = 1
var bomb_blast_range = 1
var is_scatty = false
var is_restrained = false
var has_mirror = false
var has_teleport = false
var has_bad_powerup = false

var is_dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func move(motion):
# warning-ignore:return_value_discarded
	if not is_dead:
		if has_mirror:
			motion = motion * -1
		move_and_slide(motion * speed, Vector2.UP);

#Decides which Powerup was picked up and changes the attributes of the player
func pick_up_powerup(type):
	match type:
		Powerup.Types.BAD_HYPERACTIVE:
			if not has_bad_powerup:
				speed *= 4
				has_bad_powerup = true
				$Timer.start(5)
				print("BAD_HYPERACTIVE, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.Types.BAD_MIRROR: 
			if not has_bad_powerup:
				has_mirror = true
				has_bad_powerup = true
				$Timer.start(5)
				print("BAD_MIRROR, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.Types.BAD_RESTRAIN:
			if not has_bad_powerup:
				is_restrained = true
				has_bad_powerup = true
				$Timer.start(5)
				print("BAD_RESTRAIN, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.Types.BAD_SCATTY: 
			if not has_bad_powerup:
				is_scatty = true
				has_bad_powerup = true
				$Timer.start(5)
				print("BAD_SCATTY, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.Types.BAD_SLOW:
			if not has_bad_powerup:
				speed = 20
				has_bad_powerup = true
				$Timer.start(5)
				print("BAD_SLOW, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.Types.BOMB: 
			layable_bombs += 1
			print("BOMB, LAYABLE_BOMS: " + str(layable_bombs))
		Powerup.Types.KICK: 
			can_kick = true
			print("KICK, CAN_KICK " + str(can_kick))
		Powerup.Types.POWER: 
			bomb_blast_range += 1
			print("POWER, BOMB_BLAST_RANGE: " + str(bomb_blast_range))
		Powerup.Types.SHIELD: 
			if not has_shield:
				has_shield = true
				print("SHIELD, HAS_SHIELD " + str(has_shield))
		Powerup.Types.SPEED: 
			speed += 20
			print("SPEED")
		Powerup.Types.THROW: 
			can_throw = true
			print("THROW, CAN_THROW " + str(can_throw))
		Powerup.Types.NEUTRAL_TELEPORT: 
			has_teleport = true
			print("NEUTRAL_TELEPORT, HAS_TELEPORT " + str(has_teleport))
		Powerup.Types.NEUTRAL_PANDORA:
			var randomizer = RandomNumberGenerator.new()
			randomizer.randomize()
			var randomNumber = randomizer.randi_range(0, Powerup.Types.size() - 3) #-3 because the last two are neutral
			print("NEUTRAL_PANDORA, RANDOMNUMBER: " + str(randomNumber))
			pick_up_powerup(randomNumber)

#Called, when the timer of the bad Powerup runs out and resets 
#some attributes of the player
func _on_bad_powerup_timer_timeout():
	has_mirror = false
	is_restrained = false
	is_scatty = false
	has_bad_powerup = false
	speed = base_speed
	print("HAS_BAD_POWERUP: " + str(has_bad_powerup))

func destroy():
	is_dead = true
	print("Im dieing")
#TODO: If player was hit by the bomb and has_shield, has_shield = false
