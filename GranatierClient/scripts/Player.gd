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
	"is_dead": false,
}

#var can_move = true
var powerups = []

func _ready():
	set_physics_process(false)

func set_animation(player_no):
	$AnimatedSprite.animation = "player" + str(player_no)

func destroy():
	if !stats.has_shield:
		stats.is_dead = true
		#print(stats.can_move)
		$DieSound.play()
		$AnimatedSprite.animation = $AnimatedSprite.animation + "_dead"
	else:
		stats.has_shield = false 
