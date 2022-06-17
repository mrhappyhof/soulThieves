extends "res://scripts/Player.gd"

var nextPositions = []
var newStats = []

func add_position(pos, time):
	if nextPositions.size() == 0 or nextPositions[nextPositions.size() - 1].position != pos:
		nextPositions.push_back({"position": pos, "time": time})
	else:
		nextPositions[nextPositions.size() - 1] = {"position": pos, "time": time}

func update_stats(stats, timestamp):
	newStats.push_back({"stats": stats, "timestamp": timestamp})

func _physics_process(_delta):
	if newStats.size() > 0  and newStats[0].timestamp <= Server.get_time() - 50:
		stats = newStats.pop_front().stats
	
	if nextPositions.size() > 0 and nextPositions[0].time <= Server.get_time() - 50:
		$AnimatedSprite.play()
		#print(str(position) + " -> " + str(nextPositions[0].position))
		var motion = (nextPositions[0].position - position).normalized()
		
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
			var _v = move_and_slide(motion * stats.speed * amplifier)
		if position.distance_squared_to(nextPositions[0].position) < 1:
			position = nextPositions[0].position
			nextPositions.pop_front()
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
