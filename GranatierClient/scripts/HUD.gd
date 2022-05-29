extends CanvasLayer

var time = 300

signal lose()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func countdown():
	if time >= 0:
		var minutes = time / 60
		var seconds = fmod(time, 60)
	
		$TimerLabel.text = "%02d:%02d" % [minutes, seconds]
		time -= 1
	elif time == -1:
		emit_signal("lose")
		#queue_free()

func hud_display_player():
	$PlayerList.clear()
	var i = 1
	
	for child in $Players.get_children():
		var sprite = child.get_node("AnimatedSprite")
		$PlayerList.add_item("Player " + i, sprite.get_frame())
		i += 1
