extends "res://scripts/Player.gd"

var next_positions = []
var new_stats = []

var pos_reached = false

func add_position(pos, time):
	if next_positions.size() == 0 or next_positions[next_positions.size() - 1].position != pos:
		next_positions.push_back({"position": pos, "time": time})
	else:
		next_positions[next_positions.size() - 1] = {"position": pos, "time": time}

func teleport(pos):
	next_positions.clear()
	position = pos

func update_stats(stats, timestamp):
	new_stats.push_back({"stats": stats, "timestamp": timestamp})

func _physics_process(_delta):
	if new_stats.size() > 0  and new_stats[0].timestamp <= Server.get_time() - 50 and pos_reached:
		stats = new_stats.pop_front().stats
	
	if stats.is_dead and not died:
		if not stats.fallen:
			$AnimatedSprite.animation = $AnimatedSprite.animation + "_dead"
			$DieSound.play()
			died = true
			
	if stats.fallen and not died:
		$AnimatedSprite.get_node("FallAnimation").play("fall")
		died = true
	
	if next_positions.size() > 0 and next_positions[0].time <= Server.get_time() - 50:
		pos_reached = false
		$AnimatedSprite.play()
		var motion = (next_positions[0].position - position).normalized()
		
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
		if position.distance_squared_to(next_positions[0].position) < 16:
			position = next_positions[0].position
			next_positions.pop_front()
			pos_reached = true
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
		


func _on_FallAnimation_animation_finished(anim_name):
	if stats.fallen:
		hide()
