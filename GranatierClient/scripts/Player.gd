extends KinematicBody2D

var speed = 100
#var screen_size

#func _ready():
	#screen_size = get_viewport_rect().size
var nextPositions = []

func set_animation(player_no):
	$AnimatedSprite.animation = "player" + str(player_no)

func add_position(pos, time):
	nextPositions.push_back({"position": pos, "time": time})

func _physics_process(_delta):
	if nextPositions.size() > 0 and nextPositions[0].time <= OS.get_system_time_msecs() - 50:
		$AnimatedSprite.play()
		#print(str(position) + " -> " + str(nextPositions[0].position))
		var motion = nextPositions[0].position - position
		motion = motion.normalized()
		if motion != Vector2.ZERO:
			if motion.y == 0:
				rotation = motion.angle_to(Vector2.RIGHT)
			else:
				rotation = -motion.angle_to(Vector2.RIGHT)
			move_and_slide(motion * speed);
		if position.distance_squared_to(nextPositions[0].position) < 1:
			position = nextPositions[0].position
			nextPositions.pop_front()
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
