extends KinematicBody2D


#var screen_size

#func _ready():
	#screen_size = get_viewport_rect().size

func set_animation(player_no):
	$AnimatedSprite.animation = "player" + str(player_no)

