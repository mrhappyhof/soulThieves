extends "res://scripts/Player.gd"

var nextPositions = []

func add_position(pos, time):
	if nextPositions.size() == 0 or nextPositions[nextPositions.size() - 1].position != pos:
		nextPositions.push_back({"position": pos, "time": time})
	else:
		nextPositions[nextPositions.size() - 1] = {"position": pos, "time": time}

func _physics_process(_delta):
	if nextPositions.size() > 0 and nextPositions[0].time <= Server.get_time() - 50:
		$AnimatedSprite.play()
		#print(str(position) + " -> " + str(nextPositions[0].position))
		var motion = nextPositions[0].position - position
		motion = motion.normalized()
		if motion != Vector2.ZERO:
			if motion.y == 0:
				rotation = motion.angle_to(Vector2.RIGHT)
			else:
				rotation = -motion.angle_to(Vector2.RIGHT)
			var amplifier = 1
			if stats.hyperactive:
				amplifier = 4
			elif stats.slow:
				amplifier = 0.5
			elif stats.has_mirror:
				amplifier = -1
			var _v = move_and_slide(motion * stats.speed * amplifier)
		if position.distance_squared_to(nextPositions[0].position) < 1:
			position = nextPositions[0].position
			nextPositions.pop_front()
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
