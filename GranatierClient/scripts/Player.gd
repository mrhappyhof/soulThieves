extends KinematicBody2D

var speed = 100
#var screen_size

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

var powerups = []


func set_animation(player_no):
	$AnimatedSprite.animation = "player" + str(player_no)

func destroy():
	is_dead = true
	$AnimatedSprite.animation = $AnimatedSprite.animation + "_dead"
	print("Im dieing")
