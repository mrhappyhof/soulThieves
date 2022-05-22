extends KinematicBody2D
const base_speed = 100
var speed = base_speed

enum Powerup{
	BAD_HYPERACTIVE,
	BAD_MIRROR,
	BAD_RESTRAIN,
	BAD_SCATTY,
	BAD_SLOW,
	BOMB,
	KICK,
	POWER,
	SHIELD,
	SPEED,
	THROW,
	NEUTRAL_TELEPORT,
	NEUTRAL_PANDORA,
}

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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func move(motion):
# warning-ignore:return_value_discarded
	if has_mirror:
		motion = motion * -1
	move_and_slide(motion * speed, Vector2.UP);

#Decides which Powerup was picked up and changes the attributes of the player
func pick_up_powerup(type):
	match type:
		Powerup.BAD_HYPERACTIVE:
			if not has_bad_powerup:
				speed *= 4
				has_bad_powerup = true
				$Timer.start(5)
				print("BAD_HYPERACTIVE, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.BAD_MIRROR: 
			if not has_bad_powerup:
				has_mirror = true
				has_bad_powerup = true
				$Timer.start(5)
				print("BAD_MIRROR, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.BAD_RESTRAIN:
			if not has_bad_powerup:
				is_restrained = true
				has_bad_powerup = true
				$Timer.start(5)
				print("BAD_RESTRAIN, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.BAD_SCATTY: 
			if not has_bad_powerup:
				is_scatty = true
				has_bad_powerup = true
				$Timer.start(5)
				print("BAD_SCATTY, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.BAD_SLOW:
			if not has_bad_powerup:
				speed = 20
				has_bad_powerup = true
				$Timer.start(5)
				print("BAD_SLOW, HAS_BAD_POWERUP: " + str(has_bad_powerup))
		Powerup.BOMB: 
			layable_bombs += 1
			print("BOMB, LAYABLE_BOMS: " + str(layable_bombs))
		Powerup.KICK: 
			can_kick = true
			print("KICK, CAN_KICK " + str(can_kick))
		Powerup.POWER: 
			bomb_blast_range += 1
			print("POWER, BOMB_BLAST_RANGE: " + str(bomb_blast_range))
		Powerup.SHIELD: 
			if not has_shield:
				has_shield = true
				print("SHIELD, HAS_SHIELD " + str(has_shield))
		Powerup.SPEED: 
			speed += 20
			print("SPEED")
		Powerup.THROW: 
			can_throw = true
			print("THROW, CAN_THROW " + str(can_throw))
		Powerup.NEUTRAL_TELEPORT: 
			has_teleport = true
			print("NEUTRAL_TELEPORT, HAS_TELEPORT " + str(has_teleport))
		Powerup.NEUTRAL_PANDORA:
			var randomizer = RandomNumberGenerator.new()
			randomizer.randomize()
			var randomNumber = randomizer.randi_range(0, Powerup.size() - 3) #-3 because the last two are neutral
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
	
#TODO: If player was hit by the bomb and has_shield, has_shield = false
