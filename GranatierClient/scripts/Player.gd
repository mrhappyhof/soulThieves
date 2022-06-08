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

var powerups = []


func set_animation(player_no):
	$AnimatedSprite.animation = "player" + str(player_no)

func destroy():
	stats.is_dead = true
	$DieSound.play()
	$AnimatedSprite.animation = $AnimatedSprite.animation + "_dead"
